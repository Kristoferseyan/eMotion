import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'emotion_chart.dart';
import 'custom_layout.dart';
import 'profile_page.dart'; // Import the new profile page

class DashboardLayout extends StatefulWidget {
  final String userName;

  const DashboardLayout({Key? key, required this.userName}) : super(key: key);

  @override
  _DashboardLayoutState createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  String selectedEmotion = 'Happiness';
  final List<String> emotions = [
    'Happiness',
    'Sadness',
    'Anger',
    'Neutral',
    'Surprise',
    'Disgust',
    'Fear',
  ];

  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      body: SafeArea(
        child: DashboardBody(
          userName: widget.userName,
          selectedEmotion: selectedEmotion,
          emotions: emotions,
          onEmotionChanged: (newEmotion) {
            setState(() {
              selectedEmotion = newEmotion;
            });
          },
          getEmotionData: getEmotionData,
          onProfileButtonPressed: () => _navigateToProfilePage(context),
        ),
      ),
    );
  }

  List<FlSpot> getEmotionData(String emotion) {
    switch (emotion) {
      case 'Happiness':
        return [FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3), FlSpot(3, 5), FlSpot(4, 4), FlSpot(5, 3), FlSpot(6, 4)];
      case 'Sadness':
        return [FlSpot(0, 1), FlSpot(1, 2), FlSpot(2, 1), FlSpot(3, 1), FlSpot(4, 2), FlSpot(5, 1), FlSpot(6, 2)];
      case 'Anger':
        return [FlSpot(0, 1), FlSpot(1, 1), FlSpot(2, 1), FlSpot(3, 2), FlSpot(4, 1), FlSpot(5, 2), FlSpot(6, 1)];
      default:
        return [FlSpot(0, 0)];
    }
  }

  void _navigateToProfilePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage(userName: widget.userName)),
    );
  }
}

class DashboardBody extends StatelessWidget {
  final String userName;
  final String selectedEmotion;
  final List<String> emotions;
  final ValueChanged<String> onEmotionChanged;
  final List<FlSpot> Function(String) getEmotionData;
  final VoidCallback onProfileButtonPressed;

  const DashboardBody({
    Key? key,
    required this.userName,
    required this.selectedEmotion,
    required this.emotions,
    required this.onEmotionChanged,
    required this.getEmotionData,
    required this.onProfileButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildHeader(isDarkMode),
            const SizedBox(height: 10),
            _buildGreeting(),
            const SizedBox(height: 10),
            EmotionChart(
              selectedEmotion: selectedEmotion,
              getEmotionData: getEmotionData,
              emotions: emotions,
              onEmotionChanged: onEmotionChanged,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color.fromARGB(255, 23, 57, 61) : const Color(0xFFF3FCFF),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                child: CustomLayout(maxWidth: constraints.maxWidth, userName: userName),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      child: Text(
        'Hello, $userName!',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.account_circle, color: isDarkMode ? Colors.white : Colors.black),
                onPressed: onProfileButtonPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
