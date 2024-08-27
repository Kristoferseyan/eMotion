import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../graph/pie_chart_widget.dart';
import 'tracking_detail_page.dart'; // Import the new page

class AnalyticsPage extends StatefulWidget {
  final String userId;

  const AnalyticsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final supabase = Supabase.instance.client;
  String _selectedEmotion = 'All'; // Default filter

  Future<Map<String, dynamic>> _fetchData() async {
    Map<String, double> emotionData = {};
    List<Map<String, dynamic>> recentTrackings = [];

    try {
      // Fetch emotion data
      final emotionResponse = await supabase
          .from('emotion_tracking')
          .select('emotion, emotion_distribution, timestamp, user_feedback')
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
      recentTrackings = List<Map<String, dynamic>>.from(emotionResponse).map((tracking) {
        final DateTime timestamp = DateTime.parse(tracking['timestamp']);
        final String date = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
        final String time = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

        return {
          'emotion': tracking['emotion'],
          'emotion_distribution': tracking['emotion_distribution'],
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

            // Apply filter to recentTrackings
            final filteredTrackings = _selectedEmotion == 'All'
                ? recentTrackings
                : recentTrackings.where((tracking) => tracking['emotion'] == _selectedEmotion).toList();

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle('Recent Tracking History', isDarkMode),
                          _buildEmotionFilterDropdown(isDarkMode),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildRecentTrackingList(filteredTrackings, isDarkMode),
                    ],
                  ),
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

  Widget _buildEmotionFilterDropdown(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButton<String>(
        value: _selectedEmotion,
        icon: Icon(Icons.filter_list, color: isDarkMode ? Colors.white : Colors.black),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        underline: Container(
          height: 2,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        onChanged: (String? newValue) {
          setState(() {
            _selectedEmotion = newValue ?? 'All';
          });
        },
        items: ['All', 'Happiness', 'Sadness', 'Anger', 'Surprise', 'Disgust', 'Fear']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentTrackingList(List<Map<String, dynamic>> recentTrackings, bool isDarkMode) {
    return Container(
      height: 300, // Fixed height for the recent tracking list
      decoration: BoxDecoration(
        color: isDarkMode ? Color.fromARGB(255, 23, 57, 61) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
            spreadRadius: 4,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: recentTrackings.length,
        itemBuilder: (context, index) {
          final tracking = recentTrackings[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrackingDetailPage(
                      emotion: tracking['emotion'],
                      date: tracking['date'],
                      time: tracking['time'],
                      emotionDistributionJson: tracking['emotion_distribution'], // Pass the JSON string directly
                    ),
                  ),
                );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isDarkMode ? Color.fromARGB(255, 28, 66, 71) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(
                  tracking['emotion'],
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                ),
                subtitle: Text(
                  '${tracking['date']} ${tracking['time']}',
                  style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                ),
              ),
            ),
          );
        },
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
