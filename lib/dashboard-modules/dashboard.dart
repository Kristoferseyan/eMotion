import 'package:fix_emotion/dashboard-modules/dashboard_layout.dart';
import 'package:fix_emotion/settings-modules/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:fix_emotion/analytics-modules/analytics_page.dart';

class Dashboard extends StatefulWidget {
  final String userName;
  final String userEmail;

  const Dashboard({super.key, required this.userName, required this.userEmail});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          DashboardLayout(userName: widget.userName),
          Positioned.fill(
            child: IndexedStack(
              index: _selectedIndex == 0 ? null : _selectedIndex - 1,
              children: [
                AnalyticsPage(),
                SettingsPage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: GNav(
        gap: 8,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        tabMargin: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
        tabBackgroundColor: isDarkMode ? const Color.fromARGB(255, 255, 245, 245) : Color.fromARGB(255, 49, 123, 136),
        iconSize: 30,
        tabBorderRadius: 20,
        backgroundColor: isDarkMode ? Color.fromARGB(255, 18, 46, 49) : Colors.white,
        tabs: [
          GButton(icon: Icons.home, iconActiveColor: isDarkMode ? Color.fromARGB(255, 49, 123, 136) : Colors.white, iconColor: isDarkMode ? Color.fromARGB(255, 49, 123, 136) : Color.fromARGB(255, 49, 123, 136)),
          GButton(icon: Icons.book, iconActiveColor: isDarkMode ? Color.fromARGB(255, 49, 123, 136) : Colors.white, iconColor: isDarkMode ? Color.fromARGB(255, 49, 123, 136) : Color.fromARGB(255, 49, 123, 136)),
          GButton(icon: Icons.settings, iconActiveColor: isDarkMode ? Color.fromARGB(255, 49, 123, 136) : Colors.white, iconColor: isDarkMode ? Color.fromARGB(255, 49, 123, 136) : Color.fromARGB(255, 49, 123, 136)),
        ],
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
