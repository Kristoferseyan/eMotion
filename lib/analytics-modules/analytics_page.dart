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

  
  Future<Map<String, dynamic>> _fetchPieChartData() async {
    final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));
    final formattedDate = oneWeekAgo.toIso8601String();

    
    final response = await supabase
        .from('emotion_tracking')
        .select('emotion')
        .eq('user_id', widget.userId)
        .gte('timestamp', formattedDate); 

    if (response.isEmpty) {
      print('No data found for the past week.');
      return {};
    }

    Map<String, int> emotionCount = {};

    for (var record in response) {
      String emotion = record['emotion'];
      emotionCount[emotion] = (emotionCount[emotion] ?? 0) + 1;
    }

    int total = emotionCount.values.fold(0, (sum, count) => sum + count);
    final emotionData = {
      for (var entry in emotionCount.entries)
        entry.key: (entry.value / total) * 100,
    };

    return {
      'emotionData': emotionData,
    };
  }

  
  Future<List<Map<String, dynamic>>> _fetchAllTrackingData() async {
    final response = await supabase
        .from('emotion_tracking')
        .select('session_id, emotion, timestamp, user_feedback, duration, emotion_distribution')
        .eq('user_id', widget.userId);

    if (response.isEmpty) {
      print('No data found.');
      return [];
    }

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchPieChartData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final emotionData = snapshot.data!['emotionData'] as Map<String, double>;

            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchAllTrackingData(),
              builder: (context, trackingSnapshot) {
                if (trackingSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (trackingSnapshot.hasError) {
                  return Center(child: Text('Error: ${trackingSnapshot.error}'));
                } else if (trackingSnapshot.hasData && trackingSnapshot.data!.isNotEmpty) {
                  final recentTrackings = trackingSnapshot.data!;

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
                              onItemDeleted: _refreshData,
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
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }

  void _refreshData() {
    setState(() {
      
    });
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
