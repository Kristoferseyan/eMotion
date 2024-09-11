import 'package:flutter/material.dart';
import 'tracking_detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrackingList extends StatefulWidget {
  final List<Map<String, dynamic>> recentTrackings;
  final String selectedEmotion;
  final ValueChanged<String?> onEmotionChanged;
  final bool isDarkMode;

  const TrackingList({
    Key? key,
    required this.recentTrackings,
    required this.selectedEmotion,
    required this.onEmotionChanged,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _TrackingListState createState() => _TrackingListState();
}

class _TrackingListState extends State<TrackingList> {
  List<Map<String, dynamic>> _trackingData = [];

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _trackingData = widget.recentTrackings;
  }

  Future<void> _deleteTrackingItem(String trackingId) async {
    try {
      // Delete the item from Supabase
      await supabase
          .from('emotion_tracking')
          .delete()
          .eq('id', trackingId);

      // Remove the item from the local list
      setState(() {
        _trackingData.removeWhere((item) => item['id'] == trackingId);
      });
    } catch (e) {
      print('Error deleting tracking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTrackings = widget.selectedEmotion == 'All'
        ? _trackingData
        : _trackingData.where((tracking) => tracking['emotion'] == widget.selectedEmotion).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Recent Tracking History', widget.isDarkMode),
            _buildEmotionFilterDropdown(widget.isDarkMode),
          ],
        ),
        const SizedBox(height: 10),
        _buildRecentTrackingList(filteredTrackings, widget.isDarkMode),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : const Color.fromARGB(255, 49, 123, 136),
      ),
    );
  }

  Widget _buildEmotionFilterDropdown(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButton<String>(
        value: widget.selectedEmotion,
        icon: Icon(Icons.filter_list, color: isDarkMode ? Colors.white : Colors.black),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        underline: Container(
          height: 2,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        onChanged: widget.onEmotionChanged,
        items: ['All', 'Happiness', 'Sadness', 'Anger', 'Surprise', 'Disgust', 'Fear']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentTrackingList(List<Map<String, dynamic>> filteredTrackings, bool isDarkMode) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color.fromARGB(255, 23, 57, 61) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
            spreadRadius: 4,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: filteredTrackings.length,
        itemBuilder: (context, index) {
          final tracking = filteredTrackings[index];

          return Dismissible(
            key: Key(tracking['id'].toString()), // Ensure a unique key for each item
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart, // Swipe from right to left
            onDismissed: (direction) async {
              final trackingId = tracking['id'];

              // Remove the item from the UI
              setState(() {
                filteredTrackings.removeAt(index);
              });

              // Delete the item from the database
              await _deleteTrackingItem(trackingId);
            },
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrackingDetailPage(
                      emotion: tracking['emotion'],
                      date: tracking['date'],
                      time: tracking['time'],
                      emotionDistributionJson: tracking['emotion_distribution'],
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isDarkMode ? const Color.fromARGB(255, 28, 66, 71) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode ? Colors.black.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    tracking['emotion'],
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  subtitle: Text(
                    '${tracking['date']} ${tracking['time']}',
                    style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
