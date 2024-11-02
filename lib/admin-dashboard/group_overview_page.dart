import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'group_emotion_detail_page.dart';

class GroupOverviewPage extends StatefulWidget {
  final String userId;

  const GroupOverviewPage({Key? key, required this.userId}) : super(key: key);

  @override
  _GroupOverviewPageState createState() => _GroupOverviewPageState();
}

class _GroupOverviewPageState extends State<GroupOverviewPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> groups = [];
  Map<String, int> groupMemberCounts = {}; // Map to store the number of members per group
  Map<String, Map<String, double>> groupEmotionAverages = {}; // Stores average emotions per group
  bool _loadingGroups = false;

  @override
  void initState() {
    super.initState();
    _fetchGroups(); // Fetch groups on page load
  }

  Future<void> _fetchGroups() async {
    setState(() {
      _loadingGroups = true;
    });

    try {
      final response = await supabase
          .from('user_groups')
          .select('*')
          .eq('created_by', widget.userId);

      if (response != null) {
        groups = List<Map<String, dynamic>>.from(response as List);
        await _fetchGroupMemberCounts();
        await _fetchGroupEmotionAverages(); // Fetch average emotions for each group
      }

      setState(() {
        _loadingGroups = false;
      });
    } catch (error) {
      setState(() {
        _loadingGroups = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching groups: $error')),
      );
    }
  }

  Future<void> _fetchGroupMemberCounts() async {
    for (var group in groups) {
      final groupId = group['id'];
      final response = await supabase
          .from('group_memberships')
          .select('id')
          .eq('group_id', groupId);

      if (response is List) {
        setState(() {
          groupMemberCounts[groupId] = response.length;
        });
      }
    }
  }

  Future<void> _fetchGroupEmotionAverages() async {
    for (var group in groups) {
      final groupId = group['id'];
      final response = await supabase
          .from('group_memberships')
          .select('user_admin(id)')
          .eq('group_id', groupId);

      if (response is List) {
        List<String> memberIds = response
            .map((member) => member['user_admin']['id'] as String)
            .toList();

        if (memberIds.isNotEmpty) {
          await _calculateEmotionAveragesForGroup(groupId, memberIds);
        }
      }
    }
  }

  Future<void> _calculateEmotionAveragesForGroup(
      String groupId, List<String> memberIds) async {
    Map<String, double> emotionTotals = {};
    int sessionCount = 0;

    for (var memberId in memberIds) {
      final sessionResponse = await supabase
          .from('emotion_tracking')
          .select('emotion_distribution')
          .eq('user_id', memberId);

      if (sessionResponse is List) {
        for (var session in sessionResponse) {
          Map<String, dynamic> distribution =
              jsonDecode(session['emotion_distribution']);
          sessionCount++;

          // Add emotion percentages to totals
          distribution.forEach((emotion, percentage) {
            emotionTotals[emotion] = (emotionTotals[emotion] ?? 0) + percentage;
          });
        }
      }
    }

    if (sessionCount > 0) {
      emotionTotals.updateAll((emotion, total) => total / sessionCount);
    }

    setState(() {
      groupEmotionAverages[groupId] = emotionTotals;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(isDarkMode),
              const SizedBox(height: 15),
              _buildGroupCountText(isDarkMode),
              const SizedBox(height: 15),
              if (_loadingGroups)
                const Center(child: CircularProgressIndicator())
              else
                _buildGroupList(isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Text(
        'Group Overview',
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGroupCountText(bool isDarkMode) {
    return Text(
      'You have created ${groups.length} group${groups.length == 1 ? '' : 's'}',
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

Widget _buildGroupList(bool isDarkMode) {
  if (groups.isEmpty) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(
        'You have not created any groups yet.',
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black87,
          fontSize: 16,
        ),
      ),
    );
  }

  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: groups.length,
    itemBuilder: (context, index) {
      final group = groups[index];
      final groupId = group['id'];
      final memberCount = groupMemberCounts[groupId] ?? 0;
      final emotionAverages = groupEmotionAverages[groupId] ?? {};

      return Card(
        color: isDarkMode ? const Color(0xFF1E4A54) : Colors.white,
        child: ListTile(
          title: Text(
            group['group_name'],
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          subtitle: Text(
            '${group['description'] ?? 'No description'}\nMembers: $memberCount',
            style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupEmotionDetailPage(
                  groupName: group['group_name'],
                  groupId: groupId,
                  userId: widget.userId,
                  emotionAverages: emotionAverages,
                ),
              ),
            );
          },
          onLongPress: () => _showDeleteConfirmationDialog(groupId, group['group_name']),
        ),
      );
    },
  );
}

// Show a dialog to confirm deletion
void _showDeleteConfirmationDialog(String groupId, String groupName) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete Group'),
      content: Text('Are you sure you want to delete the group "$groupName"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Close the dialog
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop(); // Close the dialog
            await _deleteGroup(groupId); // Call delete function
          },
          child: Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

// Function to delete the group from Supabase and update the UI
Future<void> _deleteGroup(String groupId) async {
  try {
    await supabase.from('user_groups').delete().eq('id', groupId);

    setState(() {
      groups.removeWhere((group) => group['id'] == groupId);
      groupMemberCounts.remove(groupId);
      groupEmotionAverages.remove(groupId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Group deleted successfully')),
    );
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error deleting group: $error')),
    );
  }
}
}
