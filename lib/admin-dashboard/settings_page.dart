import 'package:flutter/material.dart';
import '../settings-modules/app_version_page.dart';
import 'AdminFeedbackpage.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback onLogout;
  final String userId;
  final String userEmail;

  const SettingsPage({
    Key? key,
    required this.onLogout,
    required this.userId,
    required this.userEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDarkMode), 
            const SizedBox(height: 20),
            _buildSettingsTile(
              context,
              icon: Icons.info,
              title: 'App Version',
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppVersionPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildSettingsTile(
              context,
              icon: Icons.feedback,
              title: 'Send Feedback',
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminFeedbackPage(
                      userId: userId,
                      userEmail: userEmail,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildLogoutTile(context, isDarkMode), 
          ],
        ),
      ),
    );
  }

  
  Widget _buildHeader(bool isDarkMode) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0),
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

  Widget _buildSettingsTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required bool isDarkMode,
        required VoidCallback onTap,
      }) {
    return Card(
      color: isDarkMode ? const Color(0xFF1E4A54) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF317B85)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: isDarkMode ? Colors.white70 : Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutTile(BuildContext context, bool isDarkMode) {
    return Card(
      color: Colors.redAccent,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.logout, color: Colors.white),
        title: Text(
          'Log Out',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          _showLogOutConfirmationDialog(context, isDarkMode);
        },
      ),
    );
  }

  void _showLogOutConfirmationDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Log Out', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                onLogout();
              },
            ),
          ],
          backgroundColor: isDarkMode ? const Color(0xFF122E31) : Colors.white,
        );
      },
    );
  }
}
