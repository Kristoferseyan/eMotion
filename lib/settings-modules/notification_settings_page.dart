import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationSettingsPage extends StatefulWidget {
  final String userId;

  const NotificationSettingsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _NotificationSettingsPageState createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _emailNotifications = false;
  bool _pushNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  // Fetch or create the notification settings for the user
  Future<void> _loadNotificationSettings() async {
    try {
      // Check if the user already has notification settings
      final response = await Supabase.instance.client
          .from('user_settings')
          .select()
          .eq('user_id', widget.userId)
          .single(); // Fetch the user's notification settings

      if (response != null) {
        // If the settings exist, load them into the UI
        setState(() {
          _emailNotifications = response['email_notifications'] ?? false;
          _pushNotifications = response['push_notifications'] ?? false;
        });
      }
    } catch (error) {
      // If no settings exist, insert default settings for the user
      if (error.toString().contains("multiple (or no) rows")) {
        await _createNotificationSettings();
      } else {
        print('Error loading settings: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading settings: $error')),
        );
      }
    }
  }

  // Create default notification settings for the user if they don't exist
  Future<void> _createNotificationSettings() async {
    try {
      // Insert the default notification settings
      await Supabase.instance.client
          .from('user_settings')
          .insert({
            'user_id': widget.userId,
            'email_notifications': false, // Default value
            'push_notifications': false, // Default value
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

      // Update the UI with default values
      setState(() {
        _emailNotifications = false;
        _pushNotifications = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Default notification settings created')),
      );
    } catch (error) {
      print('Error creating settings: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating settings: $error')),
      );
    }
  }

  // Update the notification settings in the database
  Future<void> _updateNotificationSettings() async {
    try {
      await Supabase.instance.client
          .from('user_settings')
          .update({
            'email_notifications': _emailNotifications,
            'push_notifications': _pushNotifications,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', widget.userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification settings updated')),
      );
    } catch (error) {
      print('Error updating settings: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating settings: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: isDarkMode ? const Color(0xFF0D2C2D) : const Color(0xFFB6DDF2),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateNotificationSettings, // Save changes when pressing this button
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            _buildSwitchListTile(
              title: 'Email Notifications',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
              isDarkMode: isDarkMode,
            ),
            _buildSwitchListTile(
              title: 'Push Notifications',
              value: _pushNotifications,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value;
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
      margin: const EdgeInsets.symmetric(vertical: 8.0),
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
