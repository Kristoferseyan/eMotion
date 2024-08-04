import 'package:fix_emotion/settings-modules/privacy_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:fix_emotion/auth-modules/authentication_service.dart';
import 'package:fix_emotion/settings-modules/edit_profile_page.dart';

import 'notification_settings_page.dart';

class SettingsPage extends StatelessWidget {
  final AuthenticationService _authService = AuthenticationService();

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildHeader(isDarkMode),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(16.0),
                    children: [
                      _buildSectionHeader('Profile', isDarkMode),
                      _buildSettingsTile(Icons.person, 'Edit Profile', isDarkMode, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditProfilePage()),
                        );
                      }),
                      _buildSettingsTile(Icons.lock, 'Change Password', isDarkMode, () {
                        // Navigate to Change Password Page
                      }),
                      SizedBox(height: 20),
                      _buildSectionHeader('Notifications', isDarkMode),
                      _buildSettingsTile(Icons.notifications, 'Notification Settings', isDarkMode, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationSettingsPage()));
                      }),
                      SizedBox(height: 20),
                      _buildSectionHeader('Privacy', isDarkMode),
                      _buildSettingsTile(Icons.lock, 'Privacy Settings', isDarkMode, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacySettingsPage()));
                      }),
                      _buildSettingsTile(Icons.delete, 'Delete Data', isDarkMode, () {
                        // Navigate to Data Deletion Page
                      }),
                      SizedBox(height: 20),
                      _buildSectionHeader('Application', isDarkMode),
                      _buildSettingsTile(Icons.brightness_6, 'Theme', isDarkMode, () {
                        // Navigate to Theme Settings Page
                      }),
                      _buildSettingsTile(Icons.language, 'Language', isDarkMode, () {
                        // Navigate to Language Settings Page
                      }),
                      SizedBox(height: 20),
                      _buildSectionHeader('Security', isDarkMode),
                      _buildSettingsTile(Icons.security, 'Two-Factor Authentication', isDarkMode, () {
                        // Navigate to Two-Factor Authentication Page
                      }),
                      _buildSettingsTile(Icons.history, 'Login Activity', isDarkMode, () {
                        // Navigate to Login Activity Page
                      }),
                      SizedBox(height: 20),
                      _buildSectionHeader('About', isDarkMode),
                      _buildSettingsTile(Icons.info, 'App Version', isDarkMode, () {
                        // Show App Version Dialog
                      }),
                      _buildSettingsTile(Icons.developer_mode, 'Developer Info', isDarkMode, () {
                        // Show Developer Info Dialog
                      }),
                      _buildSettingsTile(Icons.description, 'Open Source Licenses', isDarkMode, () {
                        // Show Open Source Licenses Dialog
                      }),
                      SizedBox(height: 20),
                      _buildLogOutButton(context, isDarkMode),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        'Settings',
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, bool isDarkMode, VoidCallback onTap) {
    return Card(
      color: isDarkMode ? const Color.fromARGB(255, 23, 57, 61) : Colors.white,
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: isDarkMode ? Colors.white70 : const Color(0xFF317B85)),
        title: Text(
          title,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: isDarkMode ? Colors.white70 : Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogOutButton(BuildContext context, bool isDarkMode) {
    return ElevatedButton(
      onPressed: () {
        _handleLogOut(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? Colors.redAccent : Colors.red, // Background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(vertical: 16.0),
      ),
      child: Center(
        child: Text(
          'Log Out',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _handleLogOut(BuildContext context) async {
    try {
      await _authService.signOut();

      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: ${e.toString()}')),
      );
    }
  }
}
