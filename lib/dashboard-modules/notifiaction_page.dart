import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsPage extends StatelessWidget {
  final String userId;
  final VoidCallback markAsRead;

  const NotificationsPage({Key? key, required this.userId, required this.markAsRead}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchNotifications() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      print('Notification removed successfully');
    } catch (error) {
      print('Error removing notification: $error');
    }
  }

  Future<void> _respondToInvite(BuildContext context, String inviteId, bool accepted) async {
    final status = accepted ? 'accepted' : 'declined';
    try {
      // First, get the group_id from the group_invitations table using the invite_id
      final inviteResponse = await Supabase.instance.client
          .from('group_invitations')
          .select('group_id')
          .eq('id', inviteId)
          .single();

      final groupId = inviteResponse['group_id'];

      // Update the group invitation status
      await Supabase.instance.client
          .from('group_invitations')
          .update({'status': status, 'responded_at': DateTime.now().toIso8601String()})
          .eq('id', inviteId);

      if (accepted) {
        // If the invite is accepted, add the user to the group_memberships table
        await Supabase.instance.client
            .from('group_memberships')
            .insert({
              'group_id': groupId,
              'user_id': userId, // The user accepting the invite
            });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have been added to the group successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You declined the group invite.')),
        );
      }

      // Close the dialog AFTER showing the Snackbar
      Navigator.of(context).pop(); // Close the dialog
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error responding to invite: $error')),
      );
    }
  }

  void _showInviteDialog(BuildContext dialogContext, String message, String inviteId) {
    showDialog(
      context: dialogContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Group Invitation'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                _respondToInvite(context, inviteId, true); // Pass the invite ID
              },
              child: const Text('Accept'),
            ),
            TextButton(
              onPressed: () {
                _respondToInvite(context, inviteId, false); // Pass the invite ID
              },
              child: const Text('Decline'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchNotifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final notifications = snapshot.data ?? [];

        if (notifications.isEmpty) {
          return const Center(child: Text('No new notifications'));
        }

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];

            return Dismissible(
              key: Key(notification['id']),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) async {
                await _deleteNotification(notification['id']);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification removed')),
                );
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: ListTile(
                leading: notification['read'] == false
                    ? const Icon(Icons.circle, color: Colors.red, size: 12)
                    : const SizedBox.shrink(),
                title: Text(notification['message']),
                subtitle: Text(notification['created_at']),
                onTap: () {
                  // If it's an invite, show the dialog
                  if (notification['message'].contains('invited to join the group')) {
                    _showInviteDialog(
                      context,
                      notification['message'],
                      notification['invite_id'], // Invite ID from the notifications table
                    );
                  } else {
                    markAsRead();
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
