import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrivacySettingsPage extends StatefulWidget {
  final String userId;

  const PrivacySettingsPage({
    Key? key, 
    required this.userId, 
    required Null Function(String setting, bool value) onSettingsChanged
  }) : super(key: key);

  @override
  _PrivacySettingsPageState createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _cameraAccess = false;
  bool _motionDataSharing = false;
  bool _anonymousDataCollection = false;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadUserPermissions();
  }

  Future<void> _loadUserPermissions() async {
    try {
      final response = await supabase
          .from('user_permissions')
          .select()
          .eq('user_id', widget.userId)
          .single();

      if (response != null) {
        setState(() {
          _cameraAccess = response['camera_access'];
          _motionDataSharing = response['motion_data_sharing'];
          _anonymousDataCollection = response['anonymous_data_collection'];
        });
      }
    } catch (error) {
      print('Error loading user permissions: $error');
    }
  }

  Future<void> _updateUserPermission(String field, bool value) async {
    try {
      await supabase
          .from('user_permissions')
          .update({field: value})
          .eq('user_id', widget.userId);
    } catch (error) {
      print('Error updating user permissions: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using Theme.of(context).brightness to check for dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      appBar: AppBar(
        title: const Text('Privacy Settings'),
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
                _updateUserPermission('camera_access', value);
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
                _updateUserPermission('motion_data_sharing', value);
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
                _updateUserPermission('anonymous_data_collection', value);
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
