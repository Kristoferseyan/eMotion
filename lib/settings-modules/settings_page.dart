import 'package:fix_emotion/settings-modules/app_version_page.dart';
import 'package:fix_emotion/settings-modules/change_password_page.dart';
import 'package:fix_emotion/settings-modules/delete_data_page.dart';
import 'package:fix_emotion/settings-modules/developer_info_page.dart';
import 'package:fix_emotion/settings-modules/feedback_page.dart';
import 'package:fix_emotion/settings-modules/login_activity_page.dart';
import 'package:fix_emotion/settings-modules/privacy_settings_page.dart';
import 'package:fix_emotion/settings-modules/theme_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:fix_emotion/auth-modules/authentication_service.dart';
import 'package:fix_emotion/settings-modules/edit_profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_settings_page.dart';

class SettingsPage extends StatefulWidget {
  final String userId;
  final String userEmail;

  const SettingsPage({Key? key, required this.userId, required this.userEmail}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthenticationService _authService = AuthenticationService();

  @override
  Widget build(BuildContext context) {
    // Use the current theme's brightness instead of MediaQuery
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildSectionHeader('Profile', isDarkMode),
                      _buildSettingsTile(Icons.person, 'Edit Profile', isDarkMode, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditProfilePage(userId: widget.userId)),
                        );
                      }),
                      _buildSettingsTile(Icons.lock, 'Change Password', isDarkMode, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChangePasswordPage(userId: widget.userId)),
                        );
                      }),
                      const SizedBox(height: 20),
                      _buildSectionHeader('Notifications', isDarkMode),
                      _buildSettingsTile(Icons.notifications, 'Notification Settings', isDarkMode, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationSettingsPage()));
                      }),
                      const SizedBox(height: 20),
                      _buildSectionHeader('Privacy', isDarkMode),
                      _buildSettingsTile(Icons.lock, 'Privacy', isDarkMode, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacySettingsPage()));
                      }),
                      _buildSettingsTile(Icons.delete, 'Delete Data', isDarkMode, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DeletePage(
                          userId: widget.userId,
                          onDeleteConfirmed: () {
                            Navigator.pop(context);
                          },
                        )));
                      }),
                      const SizedBox(height: 20),
                      _buildSectionHeader('Application', isDarkMode),
                      _buildSettingsTile(Icons.brightness_6, 'Theme', isDarkMode, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ThemeSettingsPage()),
                        );
                      }),
                       _buildSettingsTile(Icons.feedback, 'Send Feedback', isDarkMode, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FeedbackPage(userId: widget.userId, userEmail: widget.userEmail,)),
                        );
                      }),

                      _buildSectionHeader('Security', isDarkMode),
                      _buildSettingsTile(Icons.history, 'Login Activity', isDarkMode, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginActivityPage(userId: widget.userId)),
                        );
                      }),
                      const SizedBox(height: 20),
                      _buildSectionHeader('About', isDarkMode),
                      _buildSettingsTile(Icons.info, 'App Version', isDarkMode, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AppVersionPage()),
                        );
                      }),
                      _buildSettingsTile(Icons.developer_mode, 'Developer Info', isDarkMode, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DeveloperInfoPage()),
                        );
                      }),
                      const SizedBox(height: 20),
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
      margin: const EdgeInsets.symmetric(vertical: 8.0),
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
        _showLogOutConfirmationDialog(context, isDarkMode);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? Colors.redAccent : Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                _handleLogOut(context);
              },
            ),
          ],
          backgroundColor: isDarkMode ? const Color(0xFF122E31) : Colors.white,
        );
      },
    );
  }

  void _handleLogOut(BuildContext context) async {
    try {
      await _authService.signOut();

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: ${e.toString()}')),
      );
    }
  }

  Future<void> _updatePrivacySettings(String setting, bool value) async {
    try {
      final userId = await _authService.getCurrentUserId();

      await Supabase.instance.client
          .from('user_permissions')
          .update({setting: value})
          .eq('user_id', userId!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$setting updated successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating $setting: ${error.toString()}')),
      );
    }
  }
}
