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
          gap: screenWidth * 0.03, // Increased gap for better spacing
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.02, // More vertical padding
          ),
          tabMargin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.012,
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
              textColor: const Color.fromARGB(255, 60, 60, 60), // Darker text
              textSize: screenWidth * 0.04, // Slightly larger text
            ),
            GButton(
              icon: Icons.settings,
              iconActiveColor: isDarkMode
                  ? const Color.fromARGB(255, 49, 123, 136)
                  : Colors.white,
              iconColor: const Color.fromARGB(255, 49, 123, 136),
              text: 'Settings',
              textColor: const Color.fromARGB(255, 60, 60, 60), // Darker text
              textSize: screenWidth * 0.04, // Slightly larger text
            ),
          ],
          selectedIndex: selectedIndex,
          onTabChange: onItemTapped,
        ),
      ),
    );
  }
}
