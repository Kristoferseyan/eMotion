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
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
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
          selectedIndex: selectedIndex,
          onTabChange: onItemTapped,
        ),
      ),
    );
  }
}
