import 'package:flutter/material.dart';

class EmotionDropdown extends StatelessWidget {
  final List<String> selectedEmotions;
  final List<String> emotions;
  final ValueChanged<List<String>> onEmotionChanged;

  const EmotionDropdown({
    Key? key,
    required this.selectedEmotions,
    required this.emotions,
    required this.onEmotionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Check if all emotions are selected
    final bool isAllSelected = selectedEmotions.length == emotions.length;

    return DropdownButton<String>(
      value: isAllSelected ? 'All Emotions' : selectedEmotions.isNotEmpty ? selectedEmotions.first : null,
      icon: Icon(Icons.arrow_drop_down, color: isDarkMode ? Colors.white : Colors.black),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      underline: Container(
        height: 1,
        color: Colors.transparent,
      ),
      onChanged: (String? newValue) {
        if (newValue != null) {
          if (newValue == 'All Emotions') {
            // Select all emotions when "All Emotions" is selected
            onEmotionChanged(emotions);
          } else {
            // Select only the chosen emotion
            onEmotionChanged([newValue]);
          }
        }
      },
      items: [
        const DropdownMenuItem<String>(
          value: 'All Emotions',
          child: Text('All Emotions'),
        ),
        ...emotions.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ],
    );
  }
}
