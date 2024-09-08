import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fix_emotion/main.dart';

class ThemeSettingsPage extends StatefulWidget {
  @override
  _ThemeSettingsPageState createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  String? _selectedTheme;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String theme = prefs.getString('theme') ?? 'System Default';

    setState(() {
      _selectedTheme = theme;
    });
  }

  Future<void> _saveThemePreference(String theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);

    setState(() {
      _selectedTheme = theme;
    });

    // Apply the selected theme immediately using setTheme from MyApp
    switch (theme) {
      case 'Light Mode':
        MyApp.of(context)?.setTheme(ThemeMode.light);
        break;
      case 'Dark Mode':
        MyApp.of(context)?.setTheme(ThemeMode.dark);
        break;
      default:
        MyApp.of(context)?.setTheme(ThemeMode.system);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Theme Settings'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Light Mode'),
            trailing: Radio(
              value: 'Light Mode',
              groupValue: _selectedTheme,
              onChanged: (value) {
                _saveThemePreference('Light Mode');
              },
            ),
          ),
          ListTile(
            title: Text('Dark Mode'),
            trailing: Radio(
              value: 'Dark Mode',
              groupValue: _selectedTheme,
              onChanged: (value) {
                _saveThemePreference('Dark Mode');
              },
            ),
          ),
          ListTile(
            title: Text('System Default'),
            trailing: Radio(
              value: 'System Default',
              groupValue: _selectedTheme,
              onChanged: (value) {
                _saveThemePreference('System Default');
              },
            ),
          ),
        ],
      ),
    );
  }
}
