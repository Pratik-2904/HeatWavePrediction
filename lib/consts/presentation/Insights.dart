import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Climate Insights',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DataDrivenInsights(),
    );
  }
}

class DataDrivenInsights extends StatefulWidget {
  @override
  _DataDrivenInsightsState createState() => _DataDrivenInsightsState();
}

class _DataDrivenInsightsState extends State<DataDrivenInsights> {
  List<FlSpot> temperatureSpots = [];
  bool isLoading = true;
  bool locationLoading = true;
  bool newsLoading = true;
  double? latitude;
  double? longitude;
  List<dynamic> newsArticles = [];

  final Color primaryBlue = Color(0xFF1E88E5);
  final Color secondaryBlue = Color(0xFF64B5F6);
  final Color accentBlue = Color(0xFF0D47A1);

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          throw Exception('Location permissions are denied');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        locationLoading = false;
      });

      await fetchWeatherData();
      await fetchClimateNews();
    } catch (e) {
      print(e);
      setState(() {
        locationLoading = false;
        isLoading = false;
      });
    }
  }

  Future<void> fetchWeatherData() async {
    if (latitude == null || longitude == null) return;

    final url =
        'https://api.tomorrow.io/v4/weather/forecast?location=$latitude,$longitude&apikey=fwTo7XbF1xxvIEDrU4wr2tvTU51lIfTF';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final minutely = data['timelines']['minutely'];

        setState(() {
          temperatureSpots = minutely.map<FlSpot>((item) {
            final time = DateTime.parse(item['time']);
            final temperature = item['values']['temperature'];
            return FlSpot(time.hour.toDouble() + time.minute / 60,
                temperature.toDouble());
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchClimateNews() async {
    final url =
        'https://newsapi.org/v2/everything?q=climate&apiKey=c1e6df5e095847ddbe3bc6e6d44b7ca0';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          newsArticles = data['articles'];
          newsLoading = false;
        });
      } else {
        throw Exception('Failed to load news data');
      }
    } catch (e) {
      print(e);
      setState(() {
        newsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Climate Insights", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryBlue,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryBlue, secondaryBlue],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            if (locationLoading)
              Center(child: Center())
            else if (latitude != null && longitude != null)
              Card(
                elevation: 4.0,
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Current Location: Lat ${latitude!.toStringAsFixed(2)}, Lon ${longitude!.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 16, color: accentBlue),
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            if (isLoading)
              const Center(
                  child: CircularProgressIndicator(color: Colors.white))
            else
              buildTemperatureTrendCard(),
            SizedBox(height: 16.0),
            buildAIInsightsCard(),
            SizedBox(height: 16.0),
            buildClimateNewsCard(),
          ],
        ),
      ),
    );
  }

  Widget buildTemperatureTrendCard() {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Temperature Trends",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: accentBlue),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: temperatureSpots,
                      isCurved: true,
                      color: primaryBlue,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: secondaryBlue.withOpacity(0.3),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${value.toInt()}°',
                              style: TextStyle(color: accentBlue, fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 4,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${value.toInt()}:00',
                              style: TextStyle(color: accentBlue, fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAIInsightsCard() {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "AI Insights",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: accentBlue),
            ),
            SizedBox(height: 10),
            Text(
              "Based on current trends, here are some recommendations for mitigating heatwaves:",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 10),
            buildInsightItem("Stay hydrated and drink plenty of water"),
            buildInsightItem("Use energy-efficient cooling systems"),
            buildInsightItem("Plant trees to increase urban green spaces"),
          ],
        ),
      ),
    );
  }

  Widget buildInsightItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.eco, color: accentBlue),
          SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget buildClimateNewsCard() {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.white.withOpacity(0.9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Latest Climate News",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: accentBlue),
            ),
          ),
          if (newsLoading)
            Center(child: CircularProgressIndicator(color: primaryBlue))
          else
            Container(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: newsArticles.length,
                itemBuilder: (context, index) {
                  final article = newsArticles[index];
                  return SingleChildScrollView(
                    child: Container(
                      width: 280,
                      margin: EdgeInsets.only(left: 16.0, bottom: 16.0),
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12.0)),
                              child: article['urlToImage'] != null
                                  ? Image.network(
                                      article['urlToImage'],
                                      height: 140,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 140, color: Colors.grey[300]),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article['title'] ?? 'No title available',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    article['description'] ??
                                        'No description available',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black87),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
