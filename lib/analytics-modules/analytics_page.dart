import 'package:flutter/material.dart';
import 'pie_chart_widget.dart';
import 'recent_tracking_list.dart';

class AnalyticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, double> emotionData = {
      'Happiness': 40,
      'Sadness': 20,
      'Anger': 10,
      'Surprise': 15,
      'Disgust': 5,
      'Fear': 10,
    };

    // Example data for recent tracking
    final List<Map<String, dynamic>> recentTrackings = [
      {
        'emotion': 'Happiness',
        'date': '2024-07-19',
        'details': 'Happiness is a state of well-being and contentment. It involves positive emotions and life satisfaction.'
      },
      {
        'emotion': 'Sadness',
        'date': '2024-07-18',
        'details': 'Sadness is an emotional pain associated with, or characterized by, feelings of disadvantage, loss, despair, grief, helplessness, disappointment and sorrow.'
      },

    ];

    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF), // Match the background color
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildHeader(isDarkMode),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Dominant Emotion in a Week',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Color.fromARGB(255, 49, 123, 136),
                    ),
                  ),
                ),
                PieChartWidget(emotionData: emotionData),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Recent Tracking History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Color.fromARGB(255, 49, 123, 136),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color.fromARGB(255, 23, 57, 61) : const Color(0xFFF3FCFF),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                    child: RecentTrackingList(recentTrackings: recentTrackings),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Analytics',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
