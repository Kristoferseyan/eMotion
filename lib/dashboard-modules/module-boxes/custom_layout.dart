import 'package:fix_emotion/dashboard-modules/module-boxes/emotion-dictionary/emotionDict.dart';
import 'package:fix_emotion/dashboard-modules/module-boxes/tracking-modules/track_emo_layout.dart';
import 'package:flutter/material.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRectangle(
            context: context,
            width: maxWidth * 0.85,
            color: isDarkMode ? const Color(0xFF2A5B5E) : const Color(0xFFFFD9D9),
            borderColor: isDarkMode ? const Color(0xFF1D4D4F) : const Color.fromARGB(255, 240, 130, 130),
            textColor: isDarkMode ? const Color(0xFFB3E3E2) : const Color.fromARGB(255, 150, 70, 70),
            imagePath: 'assets/images/emoTrack.png',
            text: 'Track Emotions',
            onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrackEmoLayout(userId: userId,), // No parameters passed
              ),
            );
          }
          ),
          const SizedBox(height: 16),
          _buildRectangle(
            context: context,
            width: maxWidth * 0.85,
            color: isDarkMode ? const Color(0xFF2A5B5E) : const Color(0xFFFFD9D9),
            borderColor: isDarkMode ? const Color(0xFF1D4D4F) : const Color.fromARGB(255, 240, 130, 130),
            textColor: isDarkMode ? const Color(0xFFB3E3E2) : const Color.fromARGB(255, 150, 70, 70),
            imagePath: 'assets/images/emoDict.png',
            text: 'Emotion Dictionary',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmotionDict()), // Navigate to EmotionDict page
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
        height: 90,
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
            const SizedBox(width: 16),
            Image.asset(
              imagePath,
              width: 44,
              height: 44,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
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