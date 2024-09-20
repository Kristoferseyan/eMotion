import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFGenerator {
  static Future<void> saveTrackingDetailsAsPDF({
    required BuildContext context,
    required String emotion,
    required String date,
    required String time,
    required String duration,
    required Map<String, double> emotionDistribution,
    Uint8List? chartImageBytes, // Accept chart image bytes
  }) async {
    final pdf = pw.Document();

    // Create the PDF content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Tracking Details',
                style:
                pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Dominant Emotion: $emotion',
                  style: pw.TextStyle(fontSize: 18)),
              pw.Text('Date: $date', style: pw.TextStyle(fontSize: 16)),
              pw.Text('Time: $time', style: pw.TextStyle(fontSize: 16)),
              pw.Text('Duration: $duration', style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text('Emotion Distribution:',
                  style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              // Emotion percentages
              ...emotionDistribution.entries.map((entry) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(entry.key, style: pw.TextStyle(fontSize: 16)),
                    pw.Text('${entry.value.toStringAsFixed(1)}%',
                        style: pw.TextStyle(fontSize: 16)),
                  ],
                );
              }).toList(),
              if (chartImageBytes != null) ...[
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Image(
                    pw.MemoryImage(chartImageBytes),
                    width: 300, // Adjust size as needed
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );

    // Save the PDF file
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
