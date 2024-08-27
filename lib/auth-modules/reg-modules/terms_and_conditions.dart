import 'package:flutter/material.dart';

class TermsAndConditionsDialog extends StatelessWidget {
  final VoidCallback onAccept;

  const TermsAndConditionsDialog({Key? key, required this.onAccept}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Terms and Conditions'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Welcome to eMotion. By accessing or using our services you agree to the following terms and conditions. Please read them carefully before proceeding.\n\n'
              'Data Collection:\nWe collect personal information including your Name, Surname, Username, and Email to enhance your experience and provide personalized services. This information allows us to:\n'
              '- Identify and authenticate your account.\n'
              '- Provide you with personalized content and features.\n'
              '- Communicate important updates and notifications.\n'
              '- Ensure account security and prevent unauthorized access.\n\n'
              'Use of Emotional Data:\nOur app collects and stores emotional data for analytics purposes. This data is strictly confidential and is used to improve our services and provide insights into emotional patterns. We assure you that:\n'
              '- Your emotional data will only be accessible to you.\n'
              '- The data will be securely stored and protected from unauthorized access.\n'
              '- We will not share your emotional data with any third parties without your explicit consent.\n\n'
              'Data Security:\nWe prioritize the security of your personal and emotional data. We implement industry-standard security measures to protect your information from unauthorized access, disclosure, or misuse.\n\n'
              'User Responsibilities:\nAs a user, you are responsible for maintaining the confidentiality of your account information, including your password. You agree to notify us immediately of any unauthorized use of your account.\n\n'
              'Changes to Terms and Conditions:\nWe may update these terms and conditions from time to time. Any changes will be communicated to you, and your continued use of the app will constitute your acceptance of the revised terms.\n\n'
              'Contact Information:\nIf you have any questions or concerns regarding these terms and conditions, please contact us at eMotionPH@gmail.com.\n\n'
              'By proceeding with the registration, you acknowledge that you have read, understood, and agree to these terms and conditions.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            onAccept();
            Navigator.of(context).pop();
          },
          child: const Text('Accept'),
        ),
      ],
    );
  }
}
