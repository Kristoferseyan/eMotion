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
      itemCount: recentTrackings.length,
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(), // Enables scrolling within the list
      itemBuilder: (context, index) {
        final tracking = recentTrackings[index];
        return Card(
          color: isDarkMode ? Color.fromARGB(255, 23, 57, 61) : Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getColor(tracking['emotion']),
              child: Text(
                _getEmoji(tracking['emotion']),
                style: const TextStyle(fontSize: 24),
              ),
            ),
            title: Text(
              tracking['emotion'],
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            subtitle: Text(
              '${tracking['date']} | ${tracking['time']}',
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

  String _getEmoji(String emotion) {
    switch (emotion) {
      case 'Happiness':
        return '😊';
      case 'Sadness':
        return '😢';
      case 'Anger':
        return '😡';
      case 'Surprise':
        return '😲';
      case 'Disgust':
        return '🤢';
      case 'Fear':
        return '😨';
      default:
        return '😐';
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
