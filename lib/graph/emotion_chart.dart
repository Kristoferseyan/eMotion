import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmotionChart extends StatefulWidget {
  final String selectedEmotion;
  final List<String> emotions;
  final ValueChanged<String> onEmotionChanged;

  const EmotionChart({
    Key? key,
    required this.selectedEmotion,
    required this.emotions,
    required this.onEmotionChanged,
  }) : super(key: key);

  @override
  _EmotionChartState createState() => _EmotionChartState();
}

class _EmotionChartState extends State<EmotionChart> {
  final supabase = Supabase.instance.client;
  late Future<List<FlSpot>> _emotionDataFuture;

  @override
  void initState() {
    super.initState();
    _emotionDataFuture = _fetchEmotionData(widget.selectedEmotion);
  }

  @override
  void didUpdateWidget(EmotionChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedEmotion != widget.selectedEmotion) {
      setState(() {
        _emotionDataFuture = _fetchEmotionData(widget.selectedEmotion);
      });
    }
  }

  Future<List<FlSpot>> _fetchEmotionData(String emotion) async {
    try {
      final response = await supabase
          .from('emotion_tracking')
          .select('emotion_distribution, timestamp')
          .gte('timestamp', DateTime.now().subtract(Duration(days: 7)).toIso8601String())
          .order('timestamp', ascending: true);

      if (response.isNotEmpty) {
        final firstResponse = response.first;
        if (firstResponse.containsKey('error')) {
          print('Supabase error: ${firstResponse['error']}');
          return [];
        }
      }

      print('Supabase response: $response');  // Debugging output

      // Initialize a map to hold sums and counts for each day of the week
      Map<int, double> dailyEmotionSum = {};
      Map<int, int> dailyEmotionCounts = {};

      for (var i = 0; i < 7; i++) {
        dailyEmotionSum[i] = 0.0;
        dailyEmotionCounts[i] = 0;
      }

      // Populate the counts and sum based on the response data
      for (var entry in response) {
        DateTime timestamp = DateTime.parse(entry['timestamp']);
        int dayIndex = DateTime.now().difference(timestamp).inDays;

        if (dayIndex < 7) {
          // Reverse the index to align with the chart (Mon-Sun)
          int chartIndex = 6 - dayIndex;
          double emotionValue = (entry['emotion_distribution'] as Map<String, dynamic>)[emotion] ?? 0.0;

          dailyEmotionSum[chartIndex] = dailyEmotionSum[chartIndex]! + emotionValue;
          dailyEmotionCounts[chartIndex] = dailyEmotionCounts[chartIndex]! + 1;
        }
      }

      // Calculate the average emotion value per day
      List<FlSpot> spots = [];
      for (var i = 0; i < 7; i++) {
        double averageEmotionValue = dailyEmotionCounts[i] != 0
            ? dailyEmotionSum[i]! / dailyEmotionCounts[i]!
            : 0.0;
        spots.add(FlSpot(i.toDouble(), averageEmotionValue));
        print('Day $i: Average $emotion = $averageEmotionValue');  // Debugging output
      }

      print('Generated spots: $spots');  // Debugging output
      return spots;
    } catch (e) {
      print('Error fetching emotion data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weekly Emotions',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    value: widget.selectedEmotion,
                    icon: Icon(Icons.arrow_drop_down, color: isDarkMode ? Colors.white : Colors.black),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    underline: Container(
                      height: 1,
                      color: Colors.transparent,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        widget.onEmotionChanged(newValue);
                      }
                    },
                    items: widget.emotions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: FutureBuilder<List<FlSpot>>(
                  future: _emotionDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No data available'));
                    } else {
                      return LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            horizontalInterval: 1,
                            verticalInterval: 1,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                                strokeWidth: 1,
                              );
                            },
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                getTitlesWidget: bottomTitleWidgets,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: Text(
                                      value.toInt().toString(),
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.white : const Color(0xff68737d),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: isDarkMode ? const Color(0xff37434d) : const Color(0xff37434d), width: 1),
                          ),
                          minX: 0,
                          maxX: 6,
                          minY: 0,
                          maxY: 5,
                          lineBarsData: [
                            LineChartBarData(
                              spots: snapshot.data!,
                              isCurved: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.withOpacity(0.6),
                                  Colors.blue.withOpacity(0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.withOpacity(0.3),
                                    Colors.blue.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Mon', style: style);
        break;
      case 1:
        text = const Text('Tue', style: style);
        break;
      case 2:
        text = const Text('Wed', style: style);
        break;
      case 3:
        text = const Text('Thu', style: style);
        break;
      case 4:
        text = const Text('Fri', style: style);
        break;
      case 5:
        text = const Text('Sat', style: style);
        break;
      case 6:
        text = const Text('Sun', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4.0,
      child: text,
    );
  }
}
