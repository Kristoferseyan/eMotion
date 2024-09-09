import 'package:flutter/material.dart';

class DeveloperInfoPage extends StatelessWidget {
  final List<Map<String, String>> developers = [
    {
      'name': 'Catubig, Jae Rowel',
      'role': 'Lead Developer',
      'status': 'College Student',
      'institution': 'STI College General Santos Inc.',
      'photoUrl': 'https://via.placeholder.com/150', // Placeholder for photo URL
    },
    {
      'name': 'Cerita, John Christopher',
      'role': 'Lead Developer',
      'status': 'College Student',
      'institution': 'STI College General Santos Inc.',
      'photoUrl': 'https://via.placeholder.com/150', // Placeholder for photo URL
    },
    {
      'name': 'Cornillez, Gemuel',
      'role': 'Project Manager',
      'status': 'College Student',
      'institution': 'STI College General Santos Inc.',
      'photoUrl': 'https://via.placeholder.com/150', // Placeholder for photo URL
    },
    {
      'name': 'Nuevo, Sean Christopher',
      'role': 'Lead Developer',
      'status': 'College Student',
      'institution': 'STI College General Santos Inc.',
      'photoUrl': 'https://via.placeholder.com/150', // Placeholder for photo URL
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      appBar: AppBar(
        title: const Text('Developer Information'),
        backgroundColor: isDarkMode ? const Color(0xFF0D2C2D) : const Color(0xFFB6DDF2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: developers.length,
          itemBuilder: (context, index) {
            final developer = developers[index];
            return Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              color: isDarkMode
                  ? Color.fromARGB(255, 25, 70, 71) // Dark mode card color
                  : const Color(0xFFFFFFFF), // Light mode card color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile photo section
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(developer['photoUrl'] ?? ''),
                      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    ),
                    const SizedBox(width: 16),
                    // Developer details section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            developer['name'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: isDarkMode ? Colors.white : const Color(0xFF317B85),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            developer['role'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            developer['status'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Colors.white54 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            developer['institution'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Colors.white54 : const Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
