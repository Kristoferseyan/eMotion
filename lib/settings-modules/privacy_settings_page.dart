import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrivacySettingsPage extends StatefulWidget {
  final String userId;

  const PrivacySettingsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _PrivacySettingsPageState createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _isVisibleToAdmin = true;
  bool _loading = true; 

  @override
  void initState() {
    super.initState();
    _loadVisibilitySetting(); 
  }

  
  Future<void> _loadVisibilitySetting() async {
    try {
      
      final response = await Supabase.instance.client
          .from('user_settings')
          .select()
          .eq('user_id', widget.userId)
          .single(); 

      if (response != null) {
        setState(() {
          _isVisibleToAdmin = response['is_visible_to_admin'] ?? true; 
        });
      }
    } catch (error) {
      
      if (error.toString().contains("multiple (or no) rows")) {
        await _createVisibilitySetting();
      } else {
        print('Error loading visibility setting: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading settings: $error')),
        );
      }
    } finally {
      setState(() {
        _loading = false; 
      });
    }
  }

  
  Future<void> _createVisibilitySetting() async {
    try {
      await Supabase.instance.client
          .from('user_settings')
          .insert({
            'user_id': widget.userId,
            'is_visible_to_admin': true, 
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

      setState(() {
        _isVisibleToAdmin = true; 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Default visibility settings created')),
      );
    } catch (error) {
      print('Error creating visibility setting: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating settings: $error')),
      );
    }
  }

  
  Future<void> _updateVisibilitySetting(bool newValue) async {
    try {
      await Supabase.instance.client
          .from('user_settings')
          .update({
            'is_visible_to_admin': newValue,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', widget.userId);

      setState(() {
        _isVisibleToAdmin = newValue; 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visibility setting updated')),
      );
    } catch (error) {
      print('Error updating visibility setting: $error');
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
        title: const Text('Privacy Settings'),
        backgroundColor: isDarkMode ? const Color(0xFF0D2C2D) : const Color(0xFFB6DDF2),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _updateVisibilitySetting(_isVisibleToAdmin),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator()) 
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: <Widget>[
                  
                  _buildExpandableSection(
                    context: context,
                    icon: Icons.person,
                    title: 'Data Collection',
                    content: 'We collect personal information such as your name, surname, username, and email address to enhance your experience and provide personalized services. This data enables us to:\n'
                        '• Verify and authenticate your account.\n'
                        '• Provide personalized content and features.\n'
                        '• Communicate important updates and notifications.\n'
                        '• Ensure account security and prevent unauthorized access.',
                    isDarkMode: isDarkMode,
                  ),

                  
                  _buildExpandableSection(
                    context: context,
                    icon: Icons.insights,
                    title: 'Use of Emotional Data',
                    content: 'Our application collects and stores emotional data for analytical purposes. This information is treated as strictly confidential and is used to improve our services and provide insights into emotional patterns. We assure you of the following:\n'
                        '• Your emotional data will only be accessible to you.\n'
                        '• The data will be securely stored and protected from unauthorized access.\n'
                        '• We will not share your emotional data with third parties without your explicit consent.',
                    isDarkMode: isDarkMode,
                  ),

                  
                  _buildExpandableSection(
                    context: context,
                    icon: Icons.security,
                    title: 'Data Security',
                    content: 'We place great emphasis on protecting your personal and emotional data. We implement industry-standard security measures to ensure your information is safe from unauthorized access, disclosure, or misuse.',
                    isDarkMode: isDarkMode,
                  ),

                  
                  _buildExpandableSection(
                    context: context,
                    icon: Icons.lock,
                    title: 'User Responsibilities',
                    content: 'You are responsible for maintaining the confidentiality of your account information, including your password. You agree to notify us immediately in case of unauthorized use of your account.',
                    isDarkMode: isDarkMode,
                  ),

                  
                  _buildExpandableSection(
                    context: context,
                    icon: Icons.update,
                    title: 'Changes to Terms and Conditions',
                    content: 'We may update these terms and conditions periodically. Any changes will be communicated to you, and by continuing to use the application, you accept the revised terms.',
                    isDarkMode: isDarkMode,
                  ),

                  
                  _buildExpandableSection(
                    context: context,
                    icon: Icons.contact_mail,
                    title: 'Contact Information',
                    content: 'For any questions or concerns, please contact us at emotionthesis@googlegroups.com.',
                    isDarkMode: isDarkMode,
                  ),

                  
                  SwitchListTile(
                    title: const Text('Visible to Admins'),
                    subtitle: const Text('Enable whether you appear on the admin\'s dashboard'),
                    value: _isVisibleToAdmin,
                    onChanged: (bool value) {
                      _updateVisibilitySetting(value); 
                    },
                  ),
                ],
              ),
            ),
    );
  }

  
  Widget _buildExpandableSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
    required bool isDarkMode,
  }) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: isDarkMode ? const Color(0xFF1D4D4F) : const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          collapsedIconColor: isDarkMode ? Colors.white : const Color(0xFF317B85),
          iconColor: isDarkMode ? Colors.white : const Color(0xFF317B85),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF317B85),
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF284A4F) : const Color(0xFFFAFAFA),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
