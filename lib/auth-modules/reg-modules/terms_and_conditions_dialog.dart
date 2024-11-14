import 'package:flutter/material.dart';

class TermsAndConditionsDialog extends StatefulWidget {
  const TermsAndConditionsDialog({Key? key}) : super(key: key);

  @override
  _TermsAndConditionsDialogState createState() => _TermsAndConditionsDialogState();
}

class _TermsAndConditionsDialogState extends State<TermsAndConditionsDialog> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      title: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Text(
            _currentPage == 0 ? 'Terms and Conditions' : 'Data Privacy Act',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
        ],
      ),
      content: SizedBox(
        height: 400, 
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _currentPage == 0
                  ? _buildTermsAndConditionsContent()
                  : _buildDataPrivacyContent(),
            ),
          ),
        ),
      ),
      actions: [
        if (_currentPage == 1)
          TextButton(
            onPressed: () {
              setState(() {
                _currentPage = 0;
              });
            },
            child: const Text('Previous'),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
        if (_currentPage == 0)
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentPage = 1;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('Next'),
          ),
      ],
    );
  }

  List<Widget> _buildTermsAndConditionsContent() {
    return [
      const Text(
        'Welcome to eMotion. By accessing or using our services you agree to the following terms and conditions. Please read them carefully before proceeding.',
        style: TextStyle(fontSize: 16, height: 1.5),
      ),
      const SizedBox(height: 10),
      const Text(
        'Data Collection:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
      ),
      const Text(
        'We collect personal information including your Name, Surname, Username, and Email to enhance your experience and provide personalized services. This information allows us to:\n'
        '- Identify and authenticate your account.\n'
        '- Provide you with personalized content and features.\n'
        '- Communicate important updates and notifications.\n'
        '- Ensure account security and prevent unauthorized access.',
        style: TextStyle(fontSize: 15, height: 1.5),
      ),
      const SizedBox(height: 10),
      const Text(
        'Use of Emotional Data:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
      ),
      const Text(
        'Our app collects and stores emotional data for analytics purposes. This data is strictly confidential and is used to improve our services and provide insights into emotional patterns. We assure you that:\n'
        '- Your emotional data will only be accessible to you.\n'
        '- The data will be securely stored and protected from unauthorized access.\n'
        '- We will not share your emotional data with any third parties without your explicit consent.',
        style: TextStyle(fontSize: 15, height: 1.5),
      ),
      const SizedBox(height: 10),
      const Text(
        'Data Security:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
      ),
      const Text(
        'We prioritize the security of your personal and emotional data. We implement industry-standard security measures to protect your information from unauthorized access, disclosure, or misuse.',
        style: TextStyle(fontSize: 15, height: 1.5),
      ),
      const SizedBox(height: 10),
      const Text(
        'User Responsibilities:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
      ),
      const Text(
        'As a user, you are responsible for maintaining the confidentiality of your account information, including your password. You agree to notify us immediately of any unauthorized use of your account.',
        style: TextStyle(fontSize: 15, height: 1.5),
      ),
      const SizedBox(height: 10),
      const Text(
        'Changes to Terms and Conditions:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
      ),
      const Text(
        'We may update these terms and conditions from time to time. Any changes will be communicated to you, and your continued use of the app will constitute your acceptance of the revised terms.',
        style: TextStyle(fontSize: 15, height: 1.5),
      ),
      const SizedBox(height: 10),
      const Text(
        'Contact Information:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
      ),
      const Text(
        'If you have any questions or concerns regarding these terms and conditions, please contact us at emotionthesis@googlegroups.com.',
        style: TextStyle(fontSize: 15, height: 1.5),
      ),
      const SizedBox(height: 10),
      const Text(
        'By proceeding with the registration, you acknowledge that you have read, understood, and agree to these terms and conditions.',
        style: TextStyle(fontSize: 15, height: 1.5),
      ),
    ];
  }

  List<Widget> _buildDataPrivacyContent() {
    return [
      const Text(
        'Data Privacy Act Notice',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
      const SizedBox(height: 10),
      const Text(
        'We are committed to protecting your personal data in accordance with the Philippine Data Privacy Act of 2012. By using this application, you agree to the collection and processing of your data, including information related to your emotions, poses, and session data. The data is stored securely and will only be used for the purpose of enhancing your experience within the app.\n\n'
        'You have the right to access, correct, or delete your data at any time. For more information, please refer to our Privacy Policy.',
        style: TextStyle(fontSize: 15, height: 1.5),
      ),
    ];
  }
}
