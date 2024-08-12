import 'package:fl_chart/fl_chart.dart';
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
        'details': 'Happiness is a state of well-being and contentment. It involves positive emotions and life satisfaction.',
        'description': 'Feeling happy about recent achievements.',
      },
      {
        'emotion': 'Sadness',
        'date': '2024-07-18',
        'details': 'Sadness is an emotional pain associated with, or characterized by, feelings of disadvantage, loss, despair, grief, helplessness, disappointment and sorrow.',
        'description': 'Feeling sad due to recent losses.',
      },
    ];

    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDarkMode),
                const SizedBox(height: 20),
                _buildSectionTitle('Dominant Emotion in a Week', isDarkMode),
                const SizedBox(height: 10),
                _buildCard(
                  context,
                  child: PieChartWidget(emotionData: emotionData),
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Recent Tracking History', isDarkMode),
                const SizedBox(height: 10),
                _buildCard(
                  context,
                  child: RecentTrackingList(recentTrackings: recentTrackings),
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.analytics, color: isDarkMode ? Colors.white : Colors.black, size: 28),
        const SizedBox(width: 10),
        Text(
          'Analytics',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : const Color.fromARGB(255, 49, 123, 136),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child, required bool isDarkMode}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Color.fromARGB(255, 23, 57, 61) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
