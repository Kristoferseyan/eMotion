import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatelessWidget {
  final Map<String, int> scores;
  final bool showEmojis;

  const MyBarGraph({
    super.key,
    required this.scores,
    this.showEmojis = false,
  });

  @override
  Widget build(BuildContext context) {
    // Print statement to check if the widget is building and the scores being passed
    print("Building MyBarGraph with scores: $scores");

    // Sort the scores alphabetically by key
    final sortedScores = Map.fromEntries(
      scores.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );

    // Calculate the maximum score to normalize the data
    final maxScore = scores.values.isNotEmpty ? scores.values.reduce((a, b) => a > b ? a : b) : 1;

    // Print maxScore for debugging
    print("Max score: $maxScore");

    // Handle empty or all-zero data by setting a default maxScore
    final maxY = 100.0; // Max is fixed to 100% for the percentage-based graph

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Container(
        height: MediaQuery.of(context).size.height / 2.5, // Adjust height to limit overlap
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(125, 201, 201, 201), // Background color
          borderRadius: BorderRadius.circular(15), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 8,
              offset: const Offset(0, 4), // Shadow for a 3D effect
            ),
          ],
        ),
        child: BarChart(
          BarChartData(
            maxY: maxY, // Fixed maxY at 100% to show percentages
            minY: 0,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false), // Removed borders
            titlesData: FlTitlesData(
              show: true,
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()}%', style: const TextStyle(color: Colors.grey));
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) =>
                      getBottomTitles(value, meta, showEmojis, sortedScores),
                ),
              ),
            ),
            barGroups: sortedScores.entries.map((entry) {
              final index = sortedScores.keys.toList().indexOf(entry.key);
              final double percentage = (entry.value / maxScore) * 100;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: percentage, // Scale the value to a percentage of the max score
                    width: 24, // Slightly wider bars
                    color: Colors.blueAccent, // Bar color
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY, // Use 100 as the background bar
                      color: Colors.grey[300], // Background bar color
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

Widget getBottomTitles(
    double value, TitleMeta meta, bool showEmojis, Map<String, int> sortedScores) {
  const style = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  if (value.toInt() >= 0 && value.toInt() < sortedScores.length) {
    final emotion = sortedScores.keys.elementAt(value.toInt());
    return SideTitleWidget(
      child: Text(showEmojis ? getEmojiForEmotion(emotion) : emotion, style: style),
      axisSide: meta.axisSide,
    );
  } else {
    return SideTitleWidget(child: Text(''), axisSide: meta.axisSide);
  }
}

String getEmojiForEmotion(String emotion) {
  switch (emotion) {
    case 'Angry':
      return '😠';
    case 'Happy':
      return '😄';
    case 'Sad':
      return '😢';
    case 'Disgust':
      return '🤢';
    case 'Fear':
      return '😨';
    case 'Neutral':
      return '😐';
    case 'Surprise':
      return '😲';
    default:
      return '?';
  }
}
