import 'dart:async';
import 'package:fix_emotion/dashboard-modules/module-boxes/custom_layout.dart';
import 'package:fix_emotion/dashboard-modules/notifiaction_page.dart';
import 'package:fix_emotion/settings-modules/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../auth-modules/authentication_service.dart';
import '../auth-modules/login-modules/login.dart';
import '../graph/emotion-chart/emotion_chart.dart';
import 'profile_page.dart';

class DashboardLayout extends StatefulWidget {
  final String userId;

  const DashboardLayout({Key? key, required this.userId}) : super(key: key);

  @override
  _DashboardLayoutState createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> with WidgetsBindingObserver {
  String timeRange = 'Weekly';
  String selectedEmotion = 'Happiness';
  String? userName;
  int unreadNotificationCount = 0;
  bool _isInForeground = true;
  bool showNotifications = false;

  final List<String> emotions = [
    'Happiness',
    'Sadness',
    'Anger',
    'Neutral',
    'Surprise',
    'Disgust',
    'Fear',
  ];

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  final AuthenticationService authService = AuthenticationService();
  Timer? _notificationTimer;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchUserName();
    _fetchUnreadNotifications();
    _startPollingNotifications();
    _initializeNotifications();
    _fetchTimeRangeFromSettings(); 
  }

  Future<void> _fetchTimeRangeFromSettings() async {
    try {
      final settingsTimeRange = await SettingsService.getChartTimeRange(); 
      setState(() {
        timeRange = settingsTimeRange ?? 'Weekly'; 
      });
    } catch (error) {
      print('Error fetching time range from settings: $error');
    }
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notiflogo');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _startPollingNotifications() {
    _notificationTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _fetchUnreadNotifications();
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

  Future<void> _fetchUnreadNotifications() async {
    try {
      final response = await authService.client
          .from('notifications')
          .select()
          .eq('user_id', widget.userId)
          .eq('read', false);

      int newUnreadCount = response.length;

      if (newUnreadCount > unreadNotificationCount) {
        _handleNotification('New Group Invite', 'You have a new group invite!');
      }

      setState(() {
        unreadNotificationCount = newUnreadCount;
      });
    } catch (error) {
      print('Error fetching notifications: $error');
    }
  }

  void _showInAppNotification(BuildContext context, String title, String body) {
    final snackBar = SnackBar(
      content: Text('$title: $body'),
      duration: Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'new_group_invite_channel',
      'Group Invites',
      channelDescription: 'Notifications for new group invitations.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, 
      title,
      body,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _isInForeground = state == AppLifecycleState.resumed;
    });
  }

  void _handleNotification(String title, String body) {
    if (_isInForeground) {
      _showInAppNotification(context, title, body);
    } else {
      _showLocalNotification(title, body);
    }
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      await authService.client
          .from('notifications')
          .update({'read': true})
          .eq('id', notificationId);

      setState(() {
        unreadNotificationCount--;
      });
    } catch (error) {
      print('Error marking notification as read: $error');
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
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
          body: SafeArea(
            child: userName == null
                ? const Center(child: CircularProgressIndicator())
                : DashboardBody(
                    userId: widget.userId,
                    userName: userName!,
                    selectedEmotion: selectedEmotion,
                    timeRange: timeRange,
                    emotions: emotions,
                    unreadNotificationCount: unreadNotificationCount,
                    onEmotionChanged: (newEmotion) {
                      setState(() {
                        selectedEmotion = newEmotion;
                      });
                    },
                    onTimeRangeChanged: (newTimeRange) {
                      setState(() {
                        timeRange = newTimeRange;
                      });
                    },
                    onProfileButtonPressed: () => _navigateToProfilePage(context),
                    onNotificationButtonPressed: _toggleNotifications,
                    showNotifications: showNotifications,
                    markAsRead: _markNotificationAsRead,
                    refreshNotifications: _fetchUnreadNotifications, 
                  ),
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
  final ValueChanged<String> markAsRead;
  final VoidCallback refreshNotifications; 
  final String timeRange;
  final ValueChanged<String> onTimeRangeChanged; 

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
    required this.refreshNotifications, required this.timeRange, required this.onTimeRangeChanged, 
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
                userId: userId,
                selectedEmotions: [selectedEmotion],
                emotions: emotions,
                onEmotionChanged: (newEmotions) {
                  if (newEmotions.isNotEmpty) {
                    onEmotionChanged(newEmotions.first);
                  }
                },
                timeRange: timeRange,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color.fromARGB(255, 23, 57, 61) : const Color(0xFFF3FCFF),
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
                        refreshNotifications: refreshNotifications, 
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
