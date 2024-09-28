import 'package:fix_emotion/dashboard-modules/module-boxes/custom_layout.dart';
import 'package:fix_emotion/dashboard-modules/notifiaction_page.dart';
import 'package:flutter/material.dart';
import '../graph/emotion-chart/emotion_chart.dart';
import 'profile_page.dart';
import '../auth-modules/login-modules/login.dart';
import '../auth-modules/authentication_service.dart';


class DashboardLayout extends StatefulWidget {
  final String userId;

  const DashboardLayout({Key? key, required this.userId}) : super(key: key);

  @override
  _DashboardLayoutState createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  String selectedEmotion = 'Happiness';
  String? userName;
  int unreadNotificationCount = 0;
  bool showNotifications = false; // Controls whether notifications are displayed or not

  final List<String> emotions = [
    'Happiness',
    'Sadness',
    'Anger',
    'Neutral',
    'Surprise',
    'Disgust',
    'Fear',
  ];

  final AuthenticationService authService = AuthenticationService();

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchUnreadNotifications();
  }

  Future<void> _fetchUserName() async {
    try {
      final response = await authService.client
          .from('user_admin')
          .select('fname')
          .eq('id', widget.userId)
          .single();

      setState(() {
        userName = response['fname'] ?? 'User';
      });
    } catch (error) {
      setState(() {
        userName = 'User';
      });
      print('Error fetching user name: $error');
    }
  }

  // Fetch unread notification count
  Future<void> _fetchUnreadNotifications() async {
    try {
      final response = await authService.client
          .from('notifications')
          .select()
          .eq('user_id', widget.userId)
          .eq('status', 'unread');

      setState(() {
        unreadNotificationCount = response.length;
      });
    } catch (error) {
      print('Error fetching notifications: $error');
    }
  }

  Future<void> _markNotificationsAsRead() async {
    try {
      await authService.client
          .from('notifications')
          .update({'status': 'read'})
          .eq('user_id', widget.userId)
          .eq('status', 'unread');

      setState(() {
        unreadNotificationCount = 0;
        showNotifications = false;
      });
    } catch (error) {
      print('Error marking notifications as read: $error');
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Log Out'),
            content: const Text('Are you sure you want to log out?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await _logout();
                },
                child: const Text('Log Out'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<void> _logout() async {
    await authService.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
        body: SafeArea(
          child: userName == null
              ? const Center(child: CircularProgressIndicator())
              : DashboardBody(
                  userId: widget.userId,
                  userName: userName!,
                  selectedEmotion: selectedEmotion,
                  emotions: emotions,
                  unreadNotificationCount: unreadNotificationCount,
                  onEmotionChanged: (newEmotion) {
                    setState(() {
                      selectedEmotion = newEmotion;
                    });
                  },
                  onProfileButtonPressed: () => _navigateToProfilePage(context),
                  onNotificationButtonPressed: _toggleNotifications,
                  showNotifications: showNotifications,
                  markAsRead: _markNotificationsAsRead,
                ),
        ),
      ),
    );
  }

  void _navigateToProfilePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userId: widget.userId),
      ),
    );
  }

  // Toggle the notification view on and off
  void _toggleNotifications() {
    setState(() {
      showNotifications = !showNotifications;
    });
  }
}

class DashboardBody extends StatelessWidget {
  final String userId;
  final String userName;
  final String selectedEmotion;
  final List<String> emotions;
  final ValueChanged<String> onEmotionChanged;
  final VoidCallback onProfileButtonPressed;
  final VoidCallback onNotificationButtonPressed;
  final bool showNotifications;
  final int unreadNotificationCount;
  final VoidCallback markAsRead;

  const DashboardBody({
    Key? key,
    required this.userId,
    required this.userName,
    required this.selectedEmotion,
    required this.emotions,
    required this.onEmotionChanged,
    required this.onProfileButtonPressed,
    required this.onNotificationButtonPressed,
    required this.showNotifications,
    required this.unreadNotificationCount,
    required this.markAsRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildHeader(isDarkMode),
            const SizedBox(height: 10),
            SizedBox(
              height: 350,
              child: EmotionChart(
                userId: userId, // Pass userId to EmotionChart
                selectedEmotions: [selectedEmotion], // Pass selected emotion
                emotions: emotions,
                onEmotionChanged: (newEmotions) {
                  if (newEmotions.isNotEmpty) {
                    onEmotionChanged(newEmotions.first);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color.fromARGB(255, 23, 57, 61)
                      : const Color(0xFFF3FCFF),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                child: showNotifications
                    ? NotificationsPage(
                        userId: userId,
                        markAsRead: markAsRead,
                      )
                    : CustomLayout(
                        maxWidth: constraints.maxWidth,
                        userName: userName,
                        userId: userId,
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    onPressed: onNotificationButtonPressed,
                  ),
                  if (unreadNotificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadNotificationCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.account_circle,
                    color: isDarkMode ? Colors.white : Colors.black),
                onPressed: onProfileButtonPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
