import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  final String userId;
  final String userEmail;

  const DashboardPage({Key? key, required this.userId, required this.userEmail}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> users = [];
  Map<String, bool> selectedUsers = {};
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // Fetch the users (non-admins) to be invited
  Future<void> _fetchUsers() async {
    try {
      final response = await supabase
          .from('user_admin')
          .select()
          .eq('role', 'user'); // Fetch only non-admin users

      setState(() {
        users = List<Map<String, dynamic>>.from(response);
        for (var user in users) {
          selectedUsers[user['id']] = false;
        }
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: $error')),
      );
    }
  }

  // Send an invite notification to selected users
  Future<void> _sendInviteNotification(String userId, String inviteId, String groupName) async {
    try {
      await supabase.from('notifications').insert({
        'user_id': userId,
        'message': 'You have been invited to join the group $groupName',
        'invite_id': inviteId, // Link the invite ID
        'read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      print('Error sending invite notification: $error');
    }
  }

  // Create the group and add users
  // Insert into the group_invitations and notifications table
  Future<void> _sendGroupInviteAndNotification(String userId, String groupId, String groupName) async {
    try {
      // Insert the group invitation
      final inviteResponse = await supabase.from('group_invitations').insert({
        'group_id': groupId,
        'user_id': userId,
        'admin_id': widget.userId,  // Assuming this is the current admin
        'status': 'pending',
        'sent_at': DateTime.now().toIso8601String(),
      }).select().single();

      // Get the invite ID to use in the notification
      final inviteId = inviteResponse['id'];

      // Send a notification to the user
      await _sendInviteNotification(userId, inviteId, groupName);

      print('Invite and notification sent to user $userId');
    } catch (error) {
      print('Error sending invite or notification: $error');
    }
  }

  // Call this function for each selected user after group creation
  Future<void> _createGroupAndSendInvites() async {
    final groupName = _groupNameController.text.trim();
    final groupDescription = _groupDescriptionController.text.trim();

    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    final selectedUserIds = selectedUsers.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No users selected')),
      );
      return;
    }

    try {
      // Insert the group into the user_groups table
      final groupResponse = await supabase.from('user_groups').insert({
        'group_name': groupName,
        'description': groupDescription,
        'created_by': widget.userId,
      }).select().single();

      final groupId = groupResponse['id'];

      // Send invite notifications and record in group_invitations
      for (String userId in selectedUserIds) {
        await _sendGroupInviteAndNotification(userId, groupId, groupName);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group created and invitations sent!')),
      );

      // Reset form after success
      setState(() {
        selectedUsers.clear();
        _groupNameController.clear();
        _groupDescriptionController.clear();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating group: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            _buildHeader(isDarkMode),
            const SizedBox(height: 15),
            _buildGroupSection(isDarkMode),
            const SizedBox(height: 15),
            _buildUserSelectionSection(isDarkMode),
            const SizedBox(height: 15),
            _buildAddUsersButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(30.0),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E4A54) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Admin',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage user groups and permissions efficiently.',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E4A54) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Group',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _groupNameController,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            decoration: InputDecoration(
              labelText: 'Group Name',
              labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              filled: true,
              fillColor: isDarkMode ? const Color.fromARGB(255, 40, 80, 90) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _groupDescriptionController,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            decoration: InputDecoration(
              labelText: 'Group Description',
              labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              filled: true,
              fillColor: isDarkMode ? const Color.fromARGB(255, 40, 80, 90) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSelectionSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E4A54) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Users to Add to Group',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 210,
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return CheckboxListTile(
                  title: Text(
                    '${user['fname']} ${user['lname']}',
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  subtitle: Text(
                    user['email'],
                    style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
                  ),
                  value: selectedUsers[user['id']] ?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      selectedUsers[user['id']] = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddUsersButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _createGroupAndSendInvites,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
          backgroundColor: const Color(0xFF6EBBC5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Create Group and Send Invitations',
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
      ),
    );
  }
}
