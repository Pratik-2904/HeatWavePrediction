import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission handler

class AlertSettingsScreen extends StatefulWidget {
  @override
  _AlertSettingsScreenState createState() => _AlertSettingsScreenState();
}

class _AlertSettingsScreenState extends State<AlertSettingsScreen> {
  double _temperatureThreshold = 35.0;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    // Initialize the notification plugin
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Request notification permissions for Android 13+
  Future<void> _requestNotificationPermissions() async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      // Request the permission if not granted
      status = await Permission.notification.request();
    }

    if (status.isGranted) {
      // Permissions granted
      _scheduleWaterReminder();
    } else {
      // Show a message to the user if permission is denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Notification permissions are required to schedule reminders."),
        ),
      );
    }
  }

  // Function to schedule water reminder
  Future<void> _scheduleWaterReminder() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'drink_water_channel_id', // Channel ID
      'Drink Water Reminder', // Channel name
      channelDescription: 'Reminder to drink water every half hour',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Schedule a periodic notification every 30 minutes
    await flutterLocalNotificationsPlugin.periodicallyShow(
      0, // Notification ID
      'Drink Water', // Notification title
      'It\'s time to drink some water!', // Notification body
      RepeatInterval
          .everyMinute, // For demo purposes use everyMinute, use .halfHour for real case
      platformChannelSpecifics,
      androidAllowWhileIdle: true, // Allows notification even when app is idle
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Alert Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Set Temperature Threshold", style: TextStyle(fontSize: 18)),
            Slider(
              value: _temperatureThreshold,
              min: 20,
              max: 50,
              divisions: 30,
              label: "$_temperatureThreshold°C",
              onChanged: (value) {
                setState(() {
                  _temperatureThreshold = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Placeholder for saving threshold to local storage or a database
              },
              child: Text("Save Settings"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Ask for notification permissions when this button is pressed
                await _requestNotificationPermissions();
              },
              child: Text("Set Drink Water Reminder"),
            ),
          ],
        ),
      ),
    );
  }
}
