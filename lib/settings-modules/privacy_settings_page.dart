import 'package:flutter/material.dart';

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
        backgroundColor: isDarkMode ? const Color(0xFF0D2C2D) : const Color(0xFFB6DDF2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            _buildExpandableSection(
              context: context,
              icon: Icons.person,
              title: 'Data Collection',
              content: 'We collect personal information such as your name, surname, username, and email address to enhance your experience and provide personalized services. This data enables us to: \n'
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
              content: 'Our application collects and stores emotional data for analytical purposes. This information is treated as strictly confidential and is used to improve our services and provide insights into emotional patterns. We assure you of the following: \n'
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
              content: 'For any questions or concerns regarding these terms and conditions, please contact us at emotionthesis@googlegroups.com.',
              isDarkMode: isDarkMode,
            ),
            _buildFinalAcknowledgment(context, isDarkMode),
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
      color: isDarkMode
          ? const Color(0xFF1D4D4F) // Dark mode card color
          : const Color(0xFFFFFFFF), // Light mode card color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // Hide the divider line
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
          backgroundColor: isDarkMode
              ? const Color(0xFF284A4F) // Dark mode expanded background
              : const Color(0xFFFAFAFA), // Light mode expanded background
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF284A4F) // Expanded container dark color
                    : const Color(0xFFFAFAFA), // Expanded container light color
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

  Widget _buildFinalAcknowledgment(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: isDarkMode ? const Color(0xFF1D4D4F) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: RichText(
            text: TextSpan(
              text: 'By proceeding with the registration, you acknowledge that you have read, understood, and agree to these ',
              style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: 'Terms and Conditions',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
