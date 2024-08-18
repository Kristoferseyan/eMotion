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

  Future<Map<String, dynamic>> _fetchData() async {
    Map<String, double> emotionData = {};
    List<Map<String, dynamic>> recentTrackings = [];

    try {
      // Fetch emotion data
      final emotionResponse = await supabase
          .from('emotion_tracking')
          .select('emotion')
          .eq('user_id', widget.userId);

      Map<String, int> emotionCount = {};

      for (var record in emotionResponse as List<dynamic>) {
        String emotion = record['emotion'];
        if (emotionCount.containsKey(emotion)) {
          emotionCount[emotion] = emotionCount[emotion]! + 1;
        } else {
          emotionCount[emotion] = 1;
        }
      }

      int total = emotionCount.values.fold(0, (sum, count) => sum + count);
      emotionData = {
        for (var entry in emotionCount.entries)
          entry.key: (entry.value / total) * 100,
      };

      // Fetch recent trackings
      final trackingResponse = await supabase
          .from('emotion_tracking')
          .select('emotion, timestamp, user_feedback')
          .eq('user_id', widget.userId)
          .order('timestamp', ascending: false);

      recentTrackings = List<Map<String, dynamic>>.from(trackingResponse as List<dynamic>).map((tracking) {
        final DateTime timestamp = DateTime.parse(tracking['timestamp']);
        final String date = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
        final String time = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

        return {
          'emotion': tracking['emotion'],
          'date': date,
          'time': time,
          'user_feedback': tracking['user_feedback'],
        };
      }).toList();

    } catch (error) {
      print('Error fetching data: $error');
    }

    return {
      'emotionData': emotionData,
      'recentTrackings': recentTrackings,
    };
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final emotionData = snapshot.data!['emotionData'] as Map<String, double>;
            final recentTrackings = snapshot.data!['recentTrackings'] as List<Map<String, dynamic>>;

            return SafeArea(
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
                    _buildRecentTrackingList(recentTrackings, isDarkMode),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text('No data available.'));
          }
        },
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

  Widget _buildRecentTrackingList(List<Map<String, dynamic>> recentTrackings, bool isDarkMode) {
    return Expanded( // This ensures the list takes up the available space without causing overflow
      child: Container(
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
        child: ListView.builder(
          itemCount: recentTrackings.length,
          itemBuilder: (context, index) {
            final tracking = recentTrackings[index];
            return ListTile(
              title: Text(
                tracking['emotion'],
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
              subtitle: Text(
                '${tracking['date']} ${tracking['time']}',
                style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
              ),
            );
          },
        ),
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
