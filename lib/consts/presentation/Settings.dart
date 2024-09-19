import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkTheme = false;
  Locale _selectedLocale = Locale('en');
  bool _isDataSharingEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('darkTheme') ?? false;
      _selectedLocale = Locale(prefs.getString('locale') ?? 'en');
      _isDataSharingEnabled = prefs.getBool('dataSharing') ?? true;
    });
  }

  void _toggleTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = value;
      prefs.setBool('darkTheme', value);
    });
  }

  void _changeLanguage(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLocale = locale;
      prefs.setString('locale', locale.languageCode);
    });
  }

  void _toggleDataSharing(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDataSharingEnabled = value;
      prefs.setBool('dataSharing', value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //todo add multitheme
      theme: _isDarkTheme ? ThemeData.light() : ThemeData.light(),
      locale: _selectedLocale,
      supportedLocales: [
        const Locale('en', ''),
        const Locale('es', ''),
        // Add more locales here
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        appBar: AppBar(title: Text("Settings")),
        body: ListView(
          children: [
            ListTile(
              title: Text("Dark Mode"),
              trailing: Switch(
                value: _isDarkTheme,
                onChanged: (value) {
                  _toggleTheme(value);
                },
              ),
            ),
            ListTile(
              title: Text("Language"),
              subtitle: Text("Select your language"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Choose Language"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text("English"),
                            onTap: () {
                              _changeLanguage(Locale('en'));
                              Navigator.of(context).pop();
                            },
                          ),
                          ListTile(
                            title: Text("Español"),
                            onTap: () {
                              _changeLanguage(Locale('es'));
                              Navigator.of(context).pop();
                            },
                          ),
                          // Add more language options here
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            ListTile(
              title: Text("Enable Data Sharing"),
              trailing: Switch(
                value: _isDataSharingEnabled,
                onChanged: (value) {
                  _toggleDataSharing(value);
                },
              ),
            ),
            // Add more settings options here
          ],
        ),
      ),
    );
  }
}
