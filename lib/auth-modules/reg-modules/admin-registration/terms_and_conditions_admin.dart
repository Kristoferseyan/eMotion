import 'package:flutter/material.dart';

class AdminTermsAndConditionsDialog extends StatelessWidget {
  final VoidCallback onAccept; 

  const AdminTermsAndConditionsDialog({Key? key, required this.onAccept}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Admin Terms and Conditions'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Welcome to the Admin Portal of eMotion. By accessing or using the admin features, you agree to the following terms and conditions. Please read them carefully before proceeding...\n\n'
              '1. **Role and Responsibilities**\n'
              'As an admin, you are granted special privileges to manage and oversee the data and activities of users. You agree to:\n'
              '- Use your administrative access responsibly.\n'
              '- Ensure the confidentiality and security of user data.\n'
              '- Respect the privacy of all users and act in accordance with data protection laws.\n'
              '- Not misuse administrative privileges for unauthorized actions.\n\n'
              '2. **Data Management**\n'
              'You are entrusted with access to certain user data, including emotional analytics. As part of your responsibilities, you agree to:\n'
              '- Handle user data with integrity and protect it from unauthorized access.\n'
              '- Use the data only for legitimate administrative purposes.\n'
              '- Refrain from sharing user data with any third party unless authorized by the user or the organization.\n\n'
              'By proceeding with admin registration, you acknowledge that you have read, understood, and agree to these terms and conditions.',
            ),
            
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onAccept, 
          child: const Text('Accept'),
        ),
      ],
    );
  }
}
