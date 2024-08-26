import 'package:flutter/material.dart';
import 'package:fix_emotion/dashboard-modules/module-boxes/emotion-dictionary/emotionDict.dart';
import 'package:fix_emotion/dashboard-modules/module-boxes/tracking-modules/track_emo_layout.dart';

class CustomLayout extends StatelessWidget {
  final double maxWidth;
  final String userName;
  final String userId;

  const CustomLayout({
    Key? key,
    required this.maxWidth,
    required this.userName,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        double width = maxWidth * 0.9;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
        'color': const Color(0xFFFFC5C5),
        'borderColor': const Color.fromARGB(255, 240, 166, 166),
        'imagePath': 'assets/images/emoTrack.png',
        'text': 'Track Emotions',
        'textColor': const Color.fromARGB(255, 209, 130, 130),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrackEmoLayout(userId: userId),
            ),
          );
        },
      },
      {
        'color': const Color(0xFFFFEBD8),
        'borderColor': const Color.fromARGB(255, 216, 176, 139),
        'imagePath': 'assets/images/emoDict.png',
        'text': 'Emotion Dictionary',
        'textColor': const Color.fromARGB(255, 184, 146, 111),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EmotionDict()),
          );
        },
      },
      {
        'color': const Color(0xFFADC4CE),
        'borderColor': const Color.fromARGB(255, 128, 163, 179),
        'imagePath': 'assets/images/aboutUs.png',
        'text': 'About Us',
        'textColor': const Color.fromARGB(255, 94, 130, 146),
        'onTap': null,
      },
    ];

    final Map<String, dynamic> rectangle = rectangles[index % rectangles.length];

    return GestureDetector(
      onTap: rectangle['onTap'],
      child: Container(
        width: width,
        height: 80,
        decoration: BoxDecoration(
          color: rectangle['color'],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: rectangle['borderColor'],
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Image.asset(
              rectangle['imagePath'],
              width: 36,
              height: 36,
            ),
            const SizedBox(width: 10),
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
