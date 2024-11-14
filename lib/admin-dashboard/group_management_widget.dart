import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupManagementWidget extends StatefulWidget {
  final String userId; 

  const GroupManagementWidget({Key? key, required this.userId}) : super(key: key);

  @override
  _GroupManagementWidgetState createState() => _GroupManagementWidgetState();
}

class _GroupManagementWidgetState extends State<GroupManagementWidget> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> groups = [];
  bool _loadingGroups = false;
  bool _showGroupList = false; 

  @override
  void initState() {
    super.initState();
    _fetchGroups(); 
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

      setState(() {
        groups = List<Map<String, dynamic>>.from(response as List);
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

  
  Future<void> _deleteGroup(String groupId) async {
    try {
      await supabase.from('user_groups').delete().eq('id', groupId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group deleted successfully')),
      );
      
      _fetchGroups();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting group: $error')),
      );
    }
  }

  
  void _confirmDeleteGroup(String groupId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text('Are you sure you want to delete this group? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteGroup(groupId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _loadingGroups
              ? null
              : () {
                  setState(() {
                    _showGroupList = !_showGroupList;
                  });
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode ? Colors.teal : const Color(0xFF317B85),
          ),
          child: Text(
            'You have created ${groups.length} group${groups.length == 1 ? '' : 's'}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        if (_loadingGroups)
          const Center(child: CircularProgressIndicator())
        else if (_showGroupList)
          _buildGroupList(isDarkMode),
      ],
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
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Card(
          color: isDarkMode ? const Color(0xFF1E4A54) : Colors.white,
          child: ListTile(
            title: Text(
              group['group_name'],
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            subtitle: Text(
              group['description'] ?? 'No description',
              style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDeleteGroup(group['id']),
            ),
          ),
        );
      },
    );
  }
}
