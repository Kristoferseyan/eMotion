import 'package:fix_emotion/dashboard-modules/dashboard_layout.dart';
import 'package:fix_emotion/settings-modules/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:fix_emotion/analytics-modules/analytics_page.dart';

class Dashboard extends StatefulWidget {
  final String userId;
  final String userEmail;

  const Dashboard({super.key, required this.userId, required this.userEmail});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

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
          DashboardLayout(userId: widget.userId), 
          AnalyticsPage(userId: widget.userId,),
          SettingsPage(userId: widget.userId),
        ],
      ),
      bottomNavigationBar: Container(
        color: isDarkMode ? const Color.fromARGB(255, 18, 46, 49) : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: GNav(
            gap: screenWidth * 0.02,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenHeight * 0.015,
            ),
            tabMargin: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.01,
            ),
            tabBackgroundColor: isDarkMode
                ? const Color.fromARGB(255, 255, 245, 245)
                : const Color.fromARGB(255, 49, 123, 136),
            iconSize: screenWidth * 0.07, 
            tabBorderRadius: screenWidth * 0.05, 
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
                textSize: screenWidth * 0.035, 
              ),
              GButton(
                icon: Icons.book,
                iconActiveColor: isDarkMode
                    ? const Color.fromARGB(255, 49, 123, 136)
                    : Colors.white,
                iconColor: const Color.fromARGB(255, 49, 123, 136),
                text: 'Analytics',
                textSize: screenWidth * 0.035, 
              ),
              GButton(
                icon: Icons.settings,
                iconActiveColor: isDarkMode
                    ? const Color.fromARGB(255, 49, 123, 136)
                    : Colors.white,
                iconColor: const Color.fromARGB(255, 49, 123, 136),
                text: 'Settings',
                textSize: screenWidth * 0.035, 
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
