import 'package:flutter/material.dart';

class EmotionDict extends StatelessWidget {
  final Map<String, Map<String, String>> emotionDefinitions = {
    'Happiness': {
      'definition': 'A feeling of joy or contentment.',
      'citation': 'Source: Merriam-Webster Dictionary'
    },
    'Sadness': {
      'definition': 'A feeling of sorrow or unhappiness.',
      'citation': 'Source: Oxford Dictionary'
    },
    'Anger': {
      'definition': 'A strong feeling of displeasure or hostility.',
      'citation': 'Source: Cambridge Dictionary'
    },
    'Neutral': {
      'definition': 'A state of being neither positive nor negative.',
      'citation': 'Source: Collins Dictionary'
    },
    'Surprise': {
      'definition': 'A feeling of unexpected astonishment or shock.',
      'citation': 'Source: Merriam-Webster Dictionary'
    },
    'Disgust': {
      'definition': 'A strong feeling of dislike or revulsion.',
      'citation': 'Source: Oxford Dictionary'
    },
    'Fear': {
      'definition': 'An unpleasant emotion caused by the threat of danger.',
      'citation': 'Source: Cambridge Dictionary'
    },
  };

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      appBar: AppBar(
        title: const Text('Emotion Dictionary'),
        backgroundColor: isDarkMode ? const Color(0xFF0D2C2D) : const Color(0xFFB6DDF2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: emotionDefinitions.length,
          itemBuilder: (context, index) {
            String emotion = emotionDefinitions.keys.elementAt(index);
            String definition = emotionDefinitions[emotion]!['definition']!;
            String citation = emotionDefinitions[emotion]!['citation']!;
            String emoji = _getEmotionEmoji(emotion);

            return Card(
              color: isDarkMode ? const Color.fromARGB(255, 23, 57, 61) : Colors.white,
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Text(
                  emoji,
                  style: TextStyle(fontSize: 40, color: isDarkMode ? Colors.white70 : const Color(0xFF317B85)),
                ),
                title: Text(
                  emotion,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      definition,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      citation,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDarkMode ? Colors.white60 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getEmotionEmoji(String emotion) {
    switch (emotion) {
      case 'Happiness':
        return '😊';
      case 'Sadness':
        return '😢';
      case 'Anger':
        return '😠';
      case 'Neutral':
        return '😐';
      case 'Surprise':
        return '😮';
      case 'Disgust':
        return '🤮';
      case 'Fear':
        return '😨';
      default:
        return '😊';
    }
  }
}
