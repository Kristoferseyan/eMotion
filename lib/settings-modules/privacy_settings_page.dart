import 'package:flutter/material.dart';
class PrivacySettingsPage extends StatefulWidget {
  @override
  _PrivacySettingsPageState createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _cameraAccess = false;
  bool _motionDataSharing = false;
  bool _anonymousDataCollection = false;

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      appBar: AppBar(
        title: Text('Privacy Settings'),
        backgroundColor: isDarkMode ? const Color(0xFF0D2C2D) : const Color(0xFFB6DDF2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            _buildSwitchListTile(
              title: 'Camera Access',
              value: _cameraAccess,
              onChanged: (value) {
                setState(() {
                  _cameraAccess = value;
                });
              },
              isDarkMode: isDarkMode,
            ),
            _buildSwitchListTile(
              title: 'Motion Data Sharing',
              value: _motionDataSharing,
              onChanged: (value) {
                setState(() {
                  _motionDataSharing = value;
                });
              },
              isDarkMode: isDarkMode,
            ),
            _buildSwitchListTile(
              title: 'Anonymous Data Collection',
              value: _anonymousDataCollection,
              onChanged: (value) {
                setState(() {
                  _anonymousDataCollection = value;
                });
              },
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchListTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDarkMode,
  }) {
    return Card(
      color: isDarkMode ? const Color.fromARGB(255, 23, 57, 61) : Colors.white,
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: isDarkMode ? Colors.white70 : const Color(0xFF317B85),
      ),
    );
  }
}
