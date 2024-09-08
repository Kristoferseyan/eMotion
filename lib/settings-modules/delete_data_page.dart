import 'package:fix_emotion/auth-modules/authentication_service.dart';
import 'package:flutter/material.dart';

class DeletePage extends StatefulWidget {
  final String userId;
  final VoidCallback onDeleteConfirmed;

  const DeletePage({
    Key? key,
    required this.userId,
    required this.onDeleteConfirmed,
  }) : super(key: key);

  @override
  _DeletePageState createState() => _DeletePageState();
}

class _DeletePageState extends State<DeletePage> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      appBar: AppBar(
        title: const Text('Delete Tracking Data'),
        backgroundColor: isDarkMode ? const Color(0xFF0D2C2D) : const Color(0xFFB6DDF2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Are you sure you want to delete all your tracking data?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'This action is irreversible and will permanently remove all your tracking data from our servers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _showConfirmationDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Delete My Tracking Data',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you absolutely sure you want to delete all your tracking data?'),
          backgroundColor: isDarkMode ? const Color(0xFF122E31) : Colors.white,
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTrackingData();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTrackingData() async {
    try {
      final authService = AuthenticationService();
      await authService.deleteTrackingData(widget.userId);

      if (!mounted) return;

      widget.onDeleteConfirmed();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tracking data deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      print('Error deleting tracking data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete tracking data. Please try again later.')),
      );
    }
  }
}
