import 'package:fix_emotion/analytics-modules/tacking_list.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../graph/pie_chart_widget.dart';

class AnalyticsPage extends StatefulWidget {
  final String userId;

  const AnalyticsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final supabase = Supabase.instance.client;
  String _selectedEmotion = 'All';

  Future<Map<String, dynamic>> _fetchData() async {
    Map<String, double> emotionData = {};
    List<Map<String, dynamic>> recentTrackings = [];

    try {
      final emotionResponse = await supabase
          .from('emotion_tracking')
          .select('session_id, emotion, emotion_distribution, timestamp, user_feedback, duration')
          .eq('user_id', widget.userId);

      if (emotionResponse.isEmpty) {
        print("No data found for user: ${widget.userId}");
        return {};
      }

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

      recentTrackings = List<Map<String, dynamic>>.from(emotionResponse).map((tracking) {
        final DateTime timestamp = DateTime.parse(tracking['timestamp']);
        final String date = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
        final String time = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

        return {
          'session_id': tracking['session_id'], // Ensure session_id is available
          'emotion': tracking['emotion'],
          'emotion_distribution': tracking['emotion_distribution'],
          'date': date,
          'time': time,
          'user_feedback': tracking['user_feedback'],
          'duration': tracking['duration']?.toString() ?? 'Unknown duration', // Add duration field here
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

  void _refreshData() {
    setState(() {
      _fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final emotionData = snapshot.data!['emotionData'] as Map<String, double>;
            final recentTrackings = snapshot.data!['recentTrackings'] as List<Map<String, dynamic>>;

            return SafeArea(
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
                      TrackingList(
                        recentTrackings: recentTrackings,
                        selectedEmotion: _selectedEmotion,
                        onEmotionChanged: (newValue) {
                          setState(() {
                            _selectedEmotion = newValue ?? 'All';
                          });
                        },
                        isDarkMode: isDarkMode,
                        userId: widget.userId,
                        onItemDeleted: _refreshData, // Pass the refresh function
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available.'));
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

  Widget _buildCard(BuildContext context, {required Widget child, required bool isDarkMode}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color.fromARGB(255, 23, 57, 61) : Colors.white,
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
