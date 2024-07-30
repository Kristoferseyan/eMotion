import 'package:fix_emotion/dashboard-modules/module-boxes/emotion-dictionary/emotionDict.dart';
import 'package:flutter/material.dart';


class CustomLayout extends StatelessWidget {
  final double maxWidth;
  final String userName;

  CustomLayout({Key? key, required this.maxWidth, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        double width = maxWidth * 0.9;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: _buildRectangle(
              context: context,
              index: index,
              width: width,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRectangle({
    required BuildContext context,
    required int index,
    required double width,
  }) {
    List<Map<String, dynamic>> rectangles = [
      {
        'color': Color(0xFFFFC5C5),
        'borderColor': Color.fromARGB(255, 240, 166, 166),
        'imagePath': 'assets/images/emoTrack.png',
        'text': 'Track Emotions',
        'textColor': Color.fromARGB(255, 209, 130, 130),
        'onTap': null,
      },
      {
        'color': Color(0xFFFFEBD8),
        'borderColor': Color.fromARGB(255, 216, 176, 139),
        'imagePath': 'assets/images/emoDict.png',
        'text': 'Emotion Dictionary',
        'textColor': Color.fromARGB(255, 184, 146, 111),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EmotionDict()),
          );
        },
      },
      {
        'color': Color(0xFFADC4CE),
        'borderColor': Color.fromARGB(255, 128, 163, 179),
        'imagePath': 'assets/images/aboutUs.png',
        'text': 'About Us',
        'textColor': Color.fromARGB(255, 94, 130, 146),
        'onTap': null,
      },
    ];

    final Map<String, dynamic> rectangle = rectangles[index % rectangles.length];

    return GestureDetector(
      onTap: rectangle['onTap'],
      child: Container(
        width: width,
        height: 80,
        margin: EdgeInsets.symmetric(vertical: 0),
        decoration: BoxDecoration(
          color: rectangle['color'],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: rectangle['borderColor'],
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 10),
            Image.asset(
              rectangle['imagePath'],
              width: 36,
              height: 36,
            ),
            SizedBox(width: 10),
            Text(
              rectangle['text'],
              style: TextStyle(
                color: rectangle['textColor'],
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
