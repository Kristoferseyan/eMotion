import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: isDarkMode ? const Color.fromARGB(255, 18, 46, 49) : Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02, 
          vertical: 10.0, 
        ),
        child: GNav(
          gap: screenWidth * 0.01, 
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 10.0,
          ),
          tabMargin: const EdgeInsets.symmetric(
            horizontal: 5.0,
            vertical: 5.0,
          ),
          tabBackgroundColor: isDarkMode
              ? const Color.fromARGB(255, 255, 245, 245)
              : const Color.fromARGB(255, 49, 123, 136),
          iconSize: screenWidth * 0.07, 
          tabBorderRadius: 10.0, 
          backgroundColor: isDarkMode
              ? const Color.fromARGB(255, 18, 46, 49)
              : Colors.white,
          tabs: [
            GButton(
              icon: Icons.dashboard,
              iconActiveColor: isDarkMode
                  ? const Color.fromARGB(255, 49, 123, 136)
                  : Colors.white,
              iconColor: const Color.fromARGB(255, 49, 123, 136),
              text: 'Dashboard',
              textColor: const Color.fromARGB(255, 60, 60, 60), 
              textSize: 12.0, 
            ),
            GButton(
              icon: Icons.group,
              iconActiveColor: isDarkMode
                  ? const Color.fromARGB(255, 49, 123, 136)
                  : Colors.white,
              iconColor: const Color.fromARGB(255, 49, 123, 136),
              text: 'Groups',
              textColor: const Color.fromARGB(255, 60, 60, 60), 
              textSize: 12.0, 
            ),
            GButton(
              icon: Icons.analytics,
              iconActiveColor: isDarkMode
                  ? const Color.fromARGB(255, 49, 123, 136)
                  : Colors.white,
              iconColor: const Color.fromARGB(255, 49, 123, 136),
              text: 'Group Overview', 
              textColor: const Color.fromARGB(255, 60, 60, 60), 
              textSize: 12.0, 
            ),
            GButton(
              icon: Icons.settings,
              iconActiveColor: isDarkMode
                  ? const Color.fromARGB(255, 49, 123, 136)
                  : Colors.white,
              iconColor: const Color.fromARGB(255, 49, 123, 136),
              text: 'Settings',
              textColor: const Color.fromARGB(255, 60, 60, 60), 
              textSize: 12.0, 
            ),
          ],
          selectedIndex: selectedIndex,
          onTabChange: onItemTapped,
        ),
      ),
    );
  }
}
