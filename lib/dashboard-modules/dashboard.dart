import 'package:fix_emotion/dashboard-modules/dashboard_layout.dart';
import 'package:fix_emotion/settings-modules/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:fix_emotion/analytics-modules/analytics_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Dashboard extends StatefulWidget {
  final String userId; // Assuming you pass the userId here instead of userName
  final String userEmail;

  const Dashboard({super.key, required this.userId, required this.userEmail});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final response = await Supabase.instance.client
        .from('users') // Assuming your table name is 'users'
        .select('fName') // Assuming the column name for the first name is 'fName'
        .eq('id', widget.userId) // Assuming 'id' is the column for userId
        .single();

    if (response != null) {
      setState(() {
        _userName = response['fName'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardLayout(userName: _userName ?? 'User'), // Pass the fetched name or default 'User'
          AnalyticsPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: Container(
        color: isDarkMode ? const Color.fromARGB(255, 18, 46, 49) : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, // 5% of screen width
            vertical: screenHeight * 0.02, // 2% of screen height
          ),
          child: GNav(
            gap: screenWidth * 0.02, // 2% of screen width
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03, // 3% of screen width
              vertical: screenHeight * 0.015, // 1.5% of screen height
            ),
            tabMargin: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, // 5% of screen width
              vertical: screenHeight * 0.01, // 1% of screen height
            ),
            tabBackgroundColor: isDarkMode
                ? const Color.fromARGB(255, 255, 245, 245)
                : const Color.fromARGB(255, 49, 123, 136),
            iconSize: screenWidth * 0.07, // Adjusted to 7% of screen width
            tabBorderRadius: screenWidth * 0.05, // 5% of screen width
            backgroundColor:
                isDarkMode ? const Color.fromARGB(255, 18, 46, 49) : Colors.white,
            tabs: [
              GButton(
                icon: Icons.home,
                iconActiveColor: isDarkMode
                    ? const Color.fromARGB(255, 49, 123, 136)
                    : Colors.white,
                iconColor: const Color.fromARGB(255, 49, 123, 136),
                text: 'Home',
                textSize: screenWidth * 0.035, // Adjusted text size
              ),
              GButton(
                icon: Icons.book,
                iconActiveColor: isDarkMode
                    ? const Color.fromARGB(255, 49, 123, 136)
                    : Colors.white,
                iconColor: const Color.fromARGB(255, 49, 123, 136),
                text: 'Analytics',
                textSize: screenWidth * 0.035, // Adjusted text size
              ),
              GButton(
                icon: Icons.settings,
                iconActiveColor: isDarkMode
                    ? const Color.fromARGB(255, 49, 123, 136)
                    : Colors.white,
                iconColor: const Color.fromARGB(255, 49, 123, 136),
                text: 'Settings',
                textSize: screenWidth * 0.035, // Adjusted text size
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
