import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'emotion_chart_data.dart';
import 'emotion_dropdown.dart';

class EmotionChart extends StatefulWidget {
  final String userId;  // Add userId parameter
  final List<String> selectedEmotions;
  final List<String> emotions;
  final ValueChanged<List<String>> onEmotionChanged;

  const EmotionChart({
    Key? key,
    required this.userId,  // Add userId to constructor
    required this.selectedEmotions,
    required this.emotions,
    required this.onEmotionChanged,
  }) : super(key: key);

  @override
  _EmotionChartState createState() => _EmotionChartState();
}

class _EmotionChartState extends State<EmotionChart> {
  late Future<Map<String, List<FlSpot>>> _emotionDataFuture;

  @override
  void initState() {
    super.initState();
    // Pass both userId and selectedEmotions to fetchEmotionData
    _emotionDataFuture = EmotionChartData.fetchEmotionData(widget.userId, widget.selectedEmotions);
  }

  @override
  void didUpdateWidget(EmotionChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedEmotions != widget.selectedEmotions) {
      setState(() {
        // Pass both userId and selectedEmotions to fetchEmotionData
        _emotionDataFuture = EmotionChartData.fetchEmotionData(widget.userId, widget.selectedEmotions);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 400,
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
                  EmotionDropdown(
                    selectedEmotions: widget.selectedEmotions,
                    emotions: widget.emotions,
                    onEmotionChanged: widget.onEmotionChanged,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: FutureBuilder<Map<String, List<FlSpot>>>(
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
                                getTitlesWidget: _bottomTitleWidgets,
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
                          lineBarsData: snapshot.data!.entries.map((entry) {
                            return LineChartBarData(
                              spots: entry.value,
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
                              dotData: FlDotData(show: true), // Show data points
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
                            );
                          }).toList(),
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

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
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
