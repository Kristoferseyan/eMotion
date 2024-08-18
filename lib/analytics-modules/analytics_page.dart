import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pie_chart_widget.dart';
import 'recent_tracking_list.dart';

class AnalyticsPage extends StatefulWidget {
  final String userId;

  const AnalyticsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final supabase = Supabase.instance.client;
  Map<String, double> emotionData = {};
  List<Map<String, dynamic>> recentTrackings = [];

  @override
  void initState() {
    super.initState();
    _fetchEmotionData();
    _fetchRecentTrackings();
  }

  Future<void> _fetchEmotionData() async {
    try {
      final response = await supabase
          .from('emotion_tracking')
          .select('emotion')
          .eq('user_id', widget.userId); // Filter by user ID from the emotion_tracking table

      Map<String, int> emotionCount = {};

      // Count the occurrences of each emotion
      for (var record in response as List<dynamic>) {
        String emotion = record['emotion'];
        if (emotionCount.containsKey(emotion)) {
          emotionCount[emotion] = emotionCount[emotion]! + 1;
        } else {
          emotionCount[emotion] = 1;
        }
      }

      // Convert the counts to percentages for the chart
      int total = emotionCount.values.fold(0, (sum, count) => sum + count);
      setState(() {
        emotionData = {
          for (var entry in emotionCount.entries)
            entry.key: (entry.value / total) * 100, // Convert to percentage
        };
      });
    } catch (error) {
      print('Error fetching emotion data: $error');
    }
  }

  Future<void> _fetchRecentTrackings() async {
    try {
      final response = await supabase
          .from('emotion_tracking')
          .select('emotion, timestamp, user_feedback')
          .eq('user_id', widget.userId) // Filter by user ID from the emotion_tracking table
          .order('timestamp', ascending: false)
          .limit(10);

      if (response != null && response.isNotEmpty) {
        setState(() {
          recentTrackings = List<Map<String, dynamic>>.from(response as List<dynamic>).map((tracking) {
            // Parse the timestamp and separate date and time
            final DateTime timestamp = DateTime.parse(tracking['timestamp']);
            final String date = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
            final String time = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

            // Return the tracking data with separated date and time
            return {
              'emotion': tracking['emotion'],
              'date': date, // Store the formatted date
              'time': time, // Store the formatted time
              'user_feedback': tracking['user_feedback'],
            };
          }).toList();
        });
      } else {
        print('No tracking data found.');
      }
    } catch (error) {
      print('Error fetching recent tracking data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
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
