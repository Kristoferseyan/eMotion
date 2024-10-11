import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'group_management_widget.dart'; // Import the GroupManagementWidget

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
    _fetchUsers(); // Fetch users with visibility setting
  }

  // Fetch the users (non-admins) who are visible to the admin
  Future<void> _fetchUsers() async {
    try {
      // Step 1: Fetch all non-admin users
      final userResponse = await supabase
          .from('user_admin')
          .select('*')
          .eq('role', 'user'); // Only non-admin users

      if (userResponse != null) {
        List<Map<String, dynamic>> allUsers = List<Map<String, dynamic>>.from(userResponse as List);

        // Step 2: Fetch visibility settings for all users
        final settingsResponse = await supabase.from('user_settings').select('user_id, is_visible_to_admin');

        if (settingsResponse != null) {
          // Convert settings response into a map for easy lookup
          Map<String, bool> visibilityMap = {
            for (var setting in settingsResponse) setting['user_id']: setting['is_visible_to_admin']
          };

          // Step 3: Filter users based on their visibility setting
          List<Map<String, dynamic>> visibleUsers = allUsers.where((user) {
            final userId = user['id'] as String;
            return visibilityMap[userId] == true; // Filter for visible users
          }).toList();

          setState(() {
            users = visibleUsers; // Only visible users are stored
            for (var user in users) {
              selectedUsers[user['id']] = false; // Initialize all users as unselected
            }
          });
        }
      }
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
  Future<void> _sendGroupInviteAndNotification(String userId, String groupId, String groupName) async {
    try {
      final inviteResponse = await supabase.from('group_invitations').insert({
        'group_id': groupId,
        'user_id': userId,
        'admin_id': widget.userId, // Admin ID
        'status': 'pending',
        'sent_at': DateTime.now().toIso8601String(),
      }).select().single();

      final inviteId = inviteResponse['id'];

      // Send a notification to the user
      await _sendInviteNotification(userId, inviteId, groupName);
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

    final selectedUserIds = selectedUsers.entries.where((entry) => entry.value).map((entry) => entry.key).toList();

    if (selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No users selected')),
      );
      return;
    }

    try {
      final groupResponse = await supabase.from('user_groups').insert({
        'group_name': groupName,
        'description': groupDescription,
        'created_by': widget.userId,
      }).select().single();

      final groupId = groupResponse['id'];

      for (String userId in selectedUserIds) {
        await _sendGroupInviteAndNotification(userId, groupId, groupName);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group created and invitations sent!')),
      );

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

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF), // Added background color
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(isDarkMode), // Custom header without AppBar
              const SizedBox(height: 15),
              _buildAdminGroupHeader(isDarkMode), // Replace the Welcome, Admin box here
              const SizedBox(height: 15),
              _buildGroupSection(isDarkMode),
              const SizedBox(height: 15),
              _buildUserSelectionSection(isDarkMode),
              const SizedBox(height: 15),
              _buildAddUsersButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Custom header without AppBar
  Widget _buildHeader(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Text(
        'Monitoring Dashboard',
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAdminGroupHeader(bool isDarkMode) {
    return Container(
      width: double.infinity, // Ensure the container takes the full width
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
      child: GroupManagementWidget(userId: widget.userId), // Insert the GroupManagementWidget
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
