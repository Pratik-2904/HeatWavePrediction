import 'dart:convert';

import 'package:demo_application/consts/presentation/weatherScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import the http package

import 'AlertSettings.dart';
import 'Insights.dart';
import 'Settings.dart';
// import 'consts/presentation/weatherScreen.dart'; // Correct import

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String heatWaveProbability = 'N/A'; // Default value for heat wave probability
  String apiKey = 'fwTo7XbF1xxvIEDrU4wr2tvTU51lIfTF'; // API key
  double? latitude;
  double? longitude;
  bool showHeatWaveAlert = false;

  // Fetch heatwave probability based on latitude and longitude
  Future<void> heatWaveProb() async {
    if (latitude == null || longitude == null)
      return; // Check if location data is available

    final url = Uri.parse(
        'https://heliosphere.up.railway.app/?lat=$latitude&long=$longitude');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final probability = data['probability'];

        setState(() {
          heatWaveProbability = (probability * 100).toStringAsFixed(2);
        });

        // Show notification or update UI after fetching the probability
        _showHeatWaveNotification();
      } else {
        setState(() {
          heatWaveProbability = 'Failed to fetch data';
        });
      }
    } catch (e) {
      setState(() {
        heatWaveProbability = 'Error occurred: $e';
      });
    }
  }

  // Placeholder function for showing heatwave alert (e.g., toast or modal)
  void _showHeatWaveAlert() {
    setState(() {
      showHeatWaveAlert = true;
    });

    // Hide alert after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        showHeatWaveAlert = false;
      });
    });

    // Fetch the probability of heatwave when alert is shown
    heatWaveProb();
  }

  // Function to simulate a notification
  void _showHeatWaveNotification() {
    // You can integrate flutter_local_notifications here for system notifications
    print('Heat wave notification: $heatWaveProbability%');
  }

  // List of screens for bottom navigation
  final List<Widget> _screens = [
    const WeatherApp(), // Ensure that WeatherApp() is correct
    DataDrivenInsights(),
    AlertSettingsScreen(),
    SettingsScreen(),
  ];

  // Function to handle bottom navigation tap
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Switch between screens
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show a modal bottom sheet with the heatwave prediction
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 200, // Adjust height as needed
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.0),
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'Heat Wave Prediction: There\'s a $heatWaveProbability% chance of a heat wave today. '
                      'Stay hydrated and avoid prolonged sun exposure.',
                      style: const TextStyle(
                        color: Colors
                            .black, // Changed text color to improve visibility
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center, // Center text
                    ),
                  ),
                ),
              );
            },
          );
        },
        elevation: 6.0,
        // Custom elevation
        backgroundColor: const Color(0xFFFFD700),
        // Gold color for the FAB
        icon: const Icon(Icons.waves),
        // Icon for heat wave
        label: const Text('Predict'), // Text next to the icon
      ),

      bottomNavigationBar: Material(
        elevation: 8.0, // Add elevation to the BottomNavigationBar
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          // Handle tap on navigation items
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFFFD700),
          // Gold for active icons
          unselectedItemColor: Colors.blueGrey,
          // const Color(0xFFD1D5DB),
          // Cool Gray for inactive icons
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights),
              label: 'Insights',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
