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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Center vertically
        children: [
          _buildRectangle(
            context: context,
            width: maxWidth * 0.85, // Slightly reduced width for better fit
            color: const Color(0xFFFFC5C5),
            borderColor: const Color.fromARGB(255, 240, 166, 166),
            imagePath: 'assets/images/emoTrack.png',
            text: 'Track Emotions',
            textColor: const Color.fromARGB(255, 209, 130, 130),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrackEmoLayout(userId: userId),
                ),
              );
            },
          ),
          const SizedBox(height: 16), // Reduced spacing between boxes
          _buildRectangle(
            context: context,
            width: maxWidth * 0.85, // Slightly reduced width for better fit
            color: const Color(0xFFFFEBD8),
            borderColor: const Color.fromARGB(255, 216, 176, 139),
            imagePath: 'assets/images/emoDict.png',
            text: 'Emotion Dictionary',
            textColor: const Color.fromARGB(255, 184, 146, 111),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmotionDict()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRectangle({
    required BuildContext context,
    required double width,
    required Color color,
    required Color borderColor,
    required String imagePath,
    required String text,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 90, // Slightly reduced height for better fit
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
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
            const SizedBox(width: 16), // Reduced padding
            Image.asset(
              imagePath,
              width: 44, // Adjusted image size for better fit
              height: 44,
            ),
            const SizedBox(width: 16), // Reduced padding
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20, // Slightly reduced text size
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
