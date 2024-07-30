import 'package:flutter/material.dart';
import 'tracking_detail_page.dart';

class RecentTrackingList extends StatelessWidget {
  final List<Map<String, dynamic>> recentTrackings;

  RecentTrackingList({required this.recentTrackings});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: recentTrackings.length,
      itemBuilder: (context, index) {
        final tracking = recentTrackings[index];
        return Card(
          color: isDarkMode ? Color.fromARGB(255, 23, 57, 61) : Colors.white,
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getColor(tracking['emotion']),
              child: Icon(
                _getIcon(tracking['emotion']),
                color: Colors.white,
              ),
            ),
            title: Text(
              tracking['emotion'],
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            subtitle: Text(
              tracking['date'],
              style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrackingDetailPage(tracking: tracking),
                ),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getIcon(String emotion) {
    switch (emotion) {
      case 'Happiness':
        return Icons.sentiment_satisfied;
      case 'Sadness':
        return Icons.sentiment_dissatisfied;
      case 'Anger':
        return Icons.sentiment_very_dissatisfied;
      case 'Surprise':
        return Icons.sentiment_very_satisfied;
      case 'Disgust':
        return Icons.sentiment_neutral;
      case 'Fear':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Color _getColor(String emotion) {
    switch (emotion) {
      case 'Happiness':
        return Colors.amber; 
      case 'Sadness':
        return Colors.blueAccent;
      case 'Anger':
        return Colors.redAccent;
      case 'Surprise':
        return Colors.orangeAccent;
      case 'Disgust':
        return Colors.green;
      case 'Fear':
        return Colors.deepPurpleAccent;
      default:
        return Colors.grey;
    }
  }
}
