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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      appBar: AppBar(
        title: const Text('Theme Settings'),
        backgroundColor: isDarkMode ? const Color(0xFF0D2C2D) : const Color(0xFFB6DDF2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            _buildThemeOption(
              title: 'Light Mode',
              value: 'Light Mode',
              groupValue: _selectedTheme,
              onChanged: (value) {
                _saveThemePreference('Light Mode');
              },
              isDarkMode: isDarkMode,
            ),
            _buildThemeOption(
              title: 'Dark Mode',
              value: 'Dark Mode',
              groupValue: _selectedTheme,
              onChanged: (value) {
                _saveThemePreference('Dark Mode');
              },
              isDarkMode: isDarkMode,
            ),
            _buildThemeOption(
              title: 'System Default',
              value: 'System Default',
              groupValue: _selectedTheme,
              onChanged: (value) {
                _saveThemePreference('System Default');
              },
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String value,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
    required bool isDarkMode,
  }) {
    return Card(
      color: isDarkMode ? const Color.fromARGB(255, 23, 57, 61) : Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: RadioListTile<String>(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: isDarkMode ? Colors.white70 : const Color(0xFF317B85),
      ),
    );
  }
}
