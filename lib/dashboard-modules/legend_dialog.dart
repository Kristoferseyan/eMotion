import 'package:flutter/material.dart';

class LegendDialog extends StatelessWidget {
  const LegendDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Emotion Intensity Legend'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendItem(Colors.red, 'Very High'),
          _buildLegendItem(Colors.orange, 'High'),
          _buildLegendItem(Colors.yellow, 'Moderate'),
          _buildLegendItem(Colors.white, 'Low'),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 5),
        Text(label, style: TextStyle(color: Colors.black)),
      ],
    );
  }
}
