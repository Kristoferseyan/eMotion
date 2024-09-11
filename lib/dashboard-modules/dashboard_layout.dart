import 'package:flutter/material.dart';
import '../graph/emotion-chart/emotion_chart.dart';
import 'custom_layout.dart';
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
  final List<String> emotions = [
    'Happiness',
    'Sadness',
    'Anger',
    'Neutral',
    'Surprise',
    'Disgust',
    'Fear',
  ];

  final AuthenticationService authService = AuthenticationService(); // Create an instance of AuthenticationService

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final response = await authService.client
          .from('users')
          .select('fName')
          .eq('id', widget.userId)
          .single();

      setState(() {
        userName = response['fName'] ?? 'User';
      });
    } catch (error) {
      setState(() {
        userName = 'User';
      });
      print('Error fetching user name: $error');
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
                  onEmotionChanged: (newEmotion) {
                    setState(() {
                      selectedEmotion = newEmotion;
                    });
                  },
                  onProfileButtonPressed: () => _navigateToProfilePage(context),
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
}

class DashboardBody extends StatelessWidget {
  final String userId;
  final String userName;
  final String selectedEmotion;
  final List<String> emotions;
  final ValueChanged<String> onEmotionChanged;
  final VoidCallback onProfileButtonPressed;

  const DashboardBody({
    Key? key,
    required this.userId,
    required this.userName,
    required this.selectedEmotion,
    required this.emotions,
    required this.onEmotionChanged,
    required this.onProfileButtonPressed,
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
              userId: userId,  // Pass userId to EmotionChart
              selectedEmotions: [selectedEmotion],  // Pass selected emotion
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
                  color: isDarkMode ? const Color.fromARGB(255, 23, 57, 61) : const Color(0xFFF3FCFF),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                child: CustomLayout(
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
              IconButton(
                icon: Icon(Icons.account_circle, color: isDarkMode ? Colors.white : Colors.black),
                onPressed: onProfileButtonPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
