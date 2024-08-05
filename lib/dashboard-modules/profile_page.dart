import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String userName;

  const ProfilePage({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: isDarkMode ? Colors.white : Colors.grey[300],
              child: Text(
                userName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 40,
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Username: $userName',
              style: TextStyle(
                fontSize: 20,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            // Add more profile information here
          ],
        ),
      ),
    );
  }
}
