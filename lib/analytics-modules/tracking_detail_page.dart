import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fix_emotion/analytics-modules/pdf_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../graph/pie_chart_widget.dart';

class TrackingDetailPage extends StatefulWidget {
  final String emotion;
  final String date;
  final String time;
  final String duration;
  final String emotionDistributionJson;

  const TrackingDetailPage({
    Key? key,
    required this.emotion,
    required this.date,
    required this.time,
    required this.duration,
    required this.emotionDistributionJson,
  }) : super(key: key);

  @override
  _TrackingDetailPageState createState() => _TrackingDetailPageState();
}

class _TrackingDetailPageState extends State<TrackingDetailPage> {
  final GlobalKey _chartKey = GlobalKey();
  late Map<String, double> emotionDistribution;

  @override
  void initState() {
    super.initState();
    emotionDistribution = Map<String, double>.from(
      jsonDecode(widget.emotionDistributionJson).map(
        (key, value) => MapEntry(key, (value as num).toDouble() * 100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Duration: ${widget.duration}');
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Details'),
        backgroundColor: isDarkMode ? const Color(0xFF0D2C2D) : const Color(0xFFB6DDF2),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _onSavePdfPressed,
          ),
        ],
      ),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dominant Emotion: ${widget.emotion}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoRow('Date', widget.date, isDarkMode),
            _buildInfoRow('Time', widget.time, isDarkMode),
            _buildInfoRow('Duration', widget.duration, isDarkMode),
            const SizedBox(height: 20),
            Text(
              'Emotion Distribution:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            RepaintBoundary(
              key: _chartKey,
              child: PieChartWidget(emotionData: emotionDistribution),
            ),
            const SizedBox(height: 20),
            _buildEmotionPercentages(emotionDistribution, isDarkMode),
          ],
        ),
      ),
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionPercentages(
      Map<String, double> emotionDistribution, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: emotionDistribution.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              Text(
                '${entry.value.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _onSavePdfPressed() async {
    try {
      
      RenderRepaintBoundary boundary = _chartKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      ui.Image chartImage = await boundary.toImage(pixelRatio: pixelRatio);
      ByteData? byteData =
          await chartImage.toByteData(format: ui.ImageByteFormat.png);
      Uint8List chartBytes = byteData!.buffer.asUint8List();

      await PDFGenerator.saveTrackingDetailsAsPDF(
        context: context,
        emotion: widget.emotion,
        date: widget.date,
        time: widget.time,
        duration: widget.duration,
        emotionDistribution: emotionDistribution,
        chartImageBytes: chartBytes, 
      );
    } catch (e) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PDF: $e')),
      );
    }
  }
}
