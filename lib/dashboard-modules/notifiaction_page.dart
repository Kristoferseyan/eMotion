import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsPage extends StatelessWidget {
  final String userId;
  final Function(String notificationId) markAsRead;
  final VoidCallback refreshNotifications; // New callback to refresh notifications

  const NotificationsPage({
    Key? key,
    required this.userId,
    required this.markAsRead,
    required this.refreshNotifications, // Add this to update notifications
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchNotifications() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('notifications')
        .select('id, message, created_at, read, invite_id')
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

  Future<void> _respondToInvite(BuildContext context, String inviteId, bool accepted, String notificationId) async {
    final status = accepted ? 'accepted' : 'declined';
    try {
      final inviteResponse = await Supabase.instance.client
          .from('group_invitations')
          .select('group_id')
          .eq('id', inviteId)
          .single();

      final groupId = inviteResponse['group_id'];

      await Supabase.instance.client
          .from('group_invitations')
          .update({'status': status, 'responded_at': DateTime.now().toIso8601String()})
          .eq('id', inviteId);

      if (accepted) {
        await Supabase.instance.client
            .from('group_memberships')
            .insert({'group_id': groupId, 'user_id': userId});
      }

      Navigator.of(context).pop(); // Close the dialog first
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(accepted ? 'You have been added to the group successfully!' : 'You declined the group invite.')),
        );
        markAsRead(notificationId); // Mark notification as read
        refreshNotifications(); // Call this method to update the badge
      });
    } catch (error) {
      Navigator.of(context).pop(); // Close the dialog first
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error responding to invite: $error')),
        );
      });
    }
  }

  void _showInviteDialog(BuildContext dialogContext, String message, String inviteId, String notificationId) {
    showDialog(
      context: dialogContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Group Invitation'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                _respondToInvite(context, inviteId, true, notificationId); // Pass the invite and notification IDs
              },
              child: const Text('Accept'),
            ),
            TextButton(
              onPressed: () {
                _respondToInvite(context, inviteId, false, notificationId); // Pass the invite and notification IDs
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
                  if (notification['message'].contains('invited to join the group')) {
                    _showInviteDialog(
                      context,
                      notification['message'],
                      notification['invite_id'],
                      notification['id'], // Pass the notification ID for deletion
                    );
                  } else {
                    markAsRead(notification['id']); // Call markAsRead with the notification ID
                    refreshNotifications(); // Refresh the badge count
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
