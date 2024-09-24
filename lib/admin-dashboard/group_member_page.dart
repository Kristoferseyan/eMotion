import 'package:fix_emotion/admin-dashboard/admin_sessions_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class GroupMembersPage extends StatefulWidget {
  final String userId;

  const GroupMembersPage({Key? key, required this.userId}) : super(key: key);

  @override
  _GroupMembersPageState createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> groups = [];
  List<Map<String, dynamic>> members = [];
  String? selectedGroup;
  Map<String, List<Map<String, dynamic>>> userSessions = {}; // To store sessions per user

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  // Fetch groups created by this admin
  Future<void> _fetchGroups() async {
    final response = await supabase
        .from('user_groups')
        .select()
        .eq('created_by', widget.userId);

    // Directly access the response data
    if (response is List) {
      setState(() {
        groups = List<Map<String, dynamic>>.from(response);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching groups')),
      );
    }
  }

  // Fetch members and their sessions for the selected group
  Future<void> _fetchGroupMembers(String groupId) async {
    final response = await supabase
        .from('group_memberships')
        .select('user_admin(id, fname, lname, email)')
        .eq('group_id', groupId);

    // Directly access the response data
    if (response is List) {
      setState(() {
        members = List<Map<String, dynamic>>.from(response);
        _fetchUserSessions();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching group members')),
      );
    }
  }

  // Fetch sessions for each member and retrieve their names
  Future<void> _fetchUserSessions() async {
    for (var member in members) {
      final userId = member['user_admin']['id'];
      final sessionResponse = await supabase
          .from('emotion_tracking')
          .select()
          .eq('user_id', userId);

      // Directly access the session response
      if (sessionResponse is List) {
        setState(() {
          userSessions[userId] = List<Map<String, dynamic>>.from(sessionResponse);
        });
      }
    }
  }

  // Delete a group member
  Future<void> _deleteGroupMember(String groupId, String memberId) async {
    final response = await supabase
        .from('group_memberships')
        .delete()
        .eq('group_id', groupId)
        .eq('user_id', memberId);

    // Check if there's an error in the response
    if (response == null || response.error == null) {
      setState(() {
        members.removeWhere((member) => member['user_admin']['id'] == memberId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member removed successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting member')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildGroupSelectionBox(isDarkMode),
          const SizedBox(height: 20),
          _buildMemberListBox(isDarkMode),
        ],
      ),
    );
  }

  // Build the group selection dropdown box
  Widget _buildGroupSelectionBox(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E4A54) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Group',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButton<String>(
            isExpanded: true,
            value: selectedGroup,
            hint: const Text('Choose a group'),
            onChanged: (String? newValue) {
              setState(() {
                selectedGroup = newValue;
                if (newValue != null) {
                  _fetchGroupMembers(newValue);
                }
              });
            },
            items: groups.map<DropdownMenuItem<String>>((Map<String, dynamic> group) {
              return DropdownMenuItem<String>(
                value: group['id'],
                child: Text(group['group_name']),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Build the member list view with expandable session lists and delete functionality
  Widget _buildMemberListBox(bool isDarkMode) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E4A54) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: members.isEmpty
            ? const Center(child: Text('No members to display'))
            : ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index]['user_admin'];
            final userId = member['id'];
            return Dismissible(
              key: Key(userId),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                _confirmDeleteMember(context, selectedGroup!, userId);
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: ExpansionTile(
                title: Text(
                  '${member['fname']} ${member['lname']}',
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                ),
                subtitle: Text(
                  member['email'],
                  style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
                ),
                children: _buildSessionList(userId, isDarkMode),
              ),
            );
          },
        ),
      ),
    );
  }

  // Build the session list for each user
  List<Widget> _buildSessionList(String userId, bool isDarkMode) {
    if (!userSessions.containsKey(userId)) {
      return [const Center(child: CircularProgressIndicator())];
    }

    final sessions = userSessions[userId] ?? [];
    if (sessions.isEmpty) {
      return [const ListTile(title: Text('No sessions available'))];
    }

    return sessions.map((session) {
      final String formattedDate = _formatDate(session['timestamp']);
      final String formattedTime = _formatTime(session['timestamp']);
      final String emotionDistributionJson = jsonEncode(session['emotion_distribution']);

      return ListTile(
        title: Text(
          'Session ID: ${session['session_id']}',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emotion: ${session['emotion']}',
              style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
            ),
            Text(
              'Date: $formattedDate',
              style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminSessionDetailPage(
                sessionId: session['session_id'],
                emotion: session['emotion'],
                date: formattedDate,
                time: formattedTime,
                duration: session['duration'].toString(),
                emotionDistributionJson: emotionDistributionJson,
              ),
            ),
          );
        },
      );
    }).toList();
  }

  // Helper function to confirm delete
  void _confirmDeleteMember(BuildContext context, String groupId, String memberId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Member'),
          content: const Text('Are you sure you want to delete this member?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteGroupMember(groupId, memberId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Helper function to format the date from the timestamp
  String _formatDate(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }

  // Helper function to format the time from the timestamp
  String _formatTime(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    return '${dateTime.hour}:${dateTime.minute}';
  }
}
