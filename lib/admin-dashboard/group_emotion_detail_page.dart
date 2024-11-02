import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class GroupEmotionDetailPage extends StatefulWidget {
  final String groupName;
  final String groupId;
  final String userId;
  final Map<String, double> emotionAverages;

  const GroupEmotionDetailPage({
    Key? key,
    required this.groupName,
    required this.groupId,
    required this.userId,
    required this.emotionAverages,
  }) : super(key: key);

  @override
  _GroupEmotionDetailPageState createState() => _GroupEmotionDetailPageState();
}

class _GroupEmotionDetailPageState extends State<GroupEmotionDetailPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> members = [];
  Map<String, double> currentEmotionData = {};
  Map<String, double> overallEmotionData = {};
  String? selectedMemberId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchMembers();
    await _fetchOverallEmotionData();
    setState(() {
      currentEmotionData = overallEmotionData;
    });
  }

Future<void> _fetchMembers() async {
  final response = await supabase
      .from('group_memberships')
      .select('user_admin(id, fname, lname)')
      .eq('group_id', widget.groupId);  

  if (response is List) {
    setState(() {
      members = List<Map<String, dynamic>>.from(response.map((e) => e['user_admin']));
    });
    

    print("Members in group ${widget.groupId}: ${members.map((m) => m['id']).toList()}");
    
    await _fetchOverallEmotionData();
  }
}



Future<void> _fetchOverallEmotionData() async {
  Map<String, double> emotionTotals = {};
  int totalSessions = 0;

  print("Calculating overall emotion data for members of group ${widget.groupId}: ${members.map((m) => m['id']).toList()}");

  for (var member in members) {
    final memberId = member['id'];
    final sessionResponse = await supabase
        .from('emotion_tracking')
        .select('emotion_distribution')
        .eq('user_id', memberId);

    if (sessionResponse is List) {
      for (var session in sessionResponse) {
        Map<String, dynamic> distribution = jsonDecode(session['emotion_distribution']);
        totalSessions++;

        // Accumulate emotion values with sanitization
        distribution.forEach((emotion, value) {
          final sanitizedEmotion = _sanitizeEmotionName(emotion); // Sanitize emotion names
          emotionTotals[sanitizedEmotion] = (emotionTotals[sanitizedEmotion] ?? 0) + (value as num).toDouble();
        });
      }
    }
  }

  if (totalSessions > 0) {
    emotionTotals.updateAll((emotion, total) => total / totalSessions);
  }

  print("Sanitized Overall Emotion Totals for group ${widget.groupId}: $emotionTotals");

  setState(() {
    overallEmotionData = _sanitizeEmotionData(emotionTotals);
    currentEmotionData = overallEmotionData; // Set this as the default chart data
  });
}

// Ensure emotion names are consistent
String _sanitizeEmotionName(String emotion) {
  final trimmedEmotion = emotion.trim().toLowerCase();

  final corrections = {
    'happyness': 'Happiness',
    'hapiness': 'Happiness',
    'sadnes': 'Sadness',
    'anger ': 'Anger',
    'suprise': 'Surprise',
    'supprise': 'Surprise',
    'disguist': 'Disgust',
    'fear ': 'Fear',
    'neutral ': 'Neutral',
    ' surprise ': 'Surprise', // add cases as needed
  };

  // Capitalize correctly and return corrected names
  return corrections[trimmedEmotion] ?? _capitalize(trimmedEmotion);
}

String _capitalize(String text) {
  return text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';
}

Future<void> _fetchEmotionDataForMember(String memberId) async {
  if (selectedMemberId == memberId) {
    // If the same member is tapped again, revert to overall data
    setState(() {
      currentEmotionData = overallEmotionData;
      selectedMemberId = null;
    });
    return;
  }

  final response = await supabase
      .from('emotion_tracking')
      .select('emotion_distribution')
      .eq('user_id', memberId)
      .limit(1)
      .maybeSingle();

  if (response != null && response['emotion_distribution'] != null) {
    final emotionData = Map<String, double>.from(
      (jsonDecode(response['emotion_distribution']) as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, (value as num).toDouble())),
    );

    setState(() {
      currentEmotionData = _sanitizeEmotionData(emotionData);
      selectedMemberId = memberId;
    });
  } else {
    setState(() {
      currentEmotionData = {}; // Clear the chart if no data is available
    });
  }
}



  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF);
    final appBarColor = isDarkMode ? const Color(0xFF0D2C2D) : const Color(0xFFB6DDF2);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: appBarColor,
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a member to view their emotion distribution:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            _buildMemberList(isDarkMode, subTextColor),
            const SizedBox(height: 20),
              Center(
                child: Text(
                  selectedMemberId == null
                      ? 'Overall Emotion Distribution'
                      : 'Emotion Distribution for ${_getMemberName(selectedMemberId!)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            _buildPieChart(),
            const SizedBox(height: 20),
            _buildLegend(isDarkMode, currentEmotionData, subTextColor),
          ],
        ),
      ),
    );
  }

Widget _buildMemberList(bool isDarkMode, Color subTextColor) {
  return Container(
    height: 60, 
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        final memberId = member['id'];
        final isSelected = memberId == selectedMemberId;

        return GestureDetector(
          onTap: () => _fetchEmotionDataForMember(memberId),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
            margin: const EdgeInsets.symmetric(horizontal: 6), 
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent : const Color.fromARGB(255, 161, 186, 196),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${member['fname']} ${member['lname']}',
                style: TextStyle(
                  color: isSelected ? Colors.white : subTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}


Widget _buildPieChart() {
  List<PieChartSectionData> sections = currentEmotionData.entries.map((entry) {
    final color = _getColor(entry.key);
    final value = entry.value * 100; 

    return PieChartSectionData(
      color: color,
      value: value,
      title: '${value.toStringAsFixed(0)}%', 
      radius: 70,
      titleStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }).toList();

  return SizedBox(
    height: 300,
    child: PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 50,
        borderData: FlBorderData(show: false),
        sectionsSpace: 3,
        startDegreeOffset: 270,
      ),
    ),
  );
}

  Widget _buildLegend(bool isDarkMode, Map<String, double> emotionData, Color subTextColor) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: emotionData.keys.map((emotion) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _getColor(emotion),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              emotion,
              style: TextStyle(
                fontSize: 16,
                color: subTextColor,
              ),
            ),
          ],
        );
      }).toList(),
    );
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

  Map<String, double> _sanitizeEmotionData(Map<String, double> data) {
    final Map<String, double> sanitizedData = {};

    data.forEach((emotion, value) {
      final cleanEmotion = _sanitizeEmotionName(emotion);
      sanitizedData[cleanEmotion] = (sanitizedData[cleanEmotion] ?? 0) + value;
    });

    return sanitizedData;
  }

  String _getMemberName(String memberId) {
    final member = members.firstWhere((member) => member['id'] == memberId, orElse: () => {});
    return '${member['fname'] ?? ''} ${member['lname'] ?? ''}';
  }
}
