import 'package:fix_emotion/admin-dashboard/group_member_page.dart';
import 'package:fix_emotion/admin-dashboard/group_overview_page.dart'; // Import GroupOverviewPage
import 'package:flutter/material.dart';
import 'main_dashboard_page.dart';
import 'settings_page.dart';
import 'nav_bar.dart';

class AdminDashboard extends StatefulWidget {
  final String userId;
  final String userEmail;

  const AdminDashboard({Key? key, required this.userId, required this.userEmail}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF122E31)
          : const Color(0xFFF3FCFF),
      body: SafeArea(
        child: _buildPage(),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // This function returns the correct page based on the selected index.
  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return DashboardPage(userId: widget.userId, userEmail: widget.userEmail);
      case 1:
        return GroupMembersPage(userId: widget.userId);
      case 2:
        return GroupOverviewPage(userId: widget.userId); // Group Overview page
      case 3:
        return SettingsPage(onLogout: _logout, userId: widget.userId, userEmail: widget.userEmail);
      default:
        return DashboardPage(userId: widget.userId, userEmail: widget.userEmail);
    }
  }

  Future<void> _logout() async {
    Navigator.pushReplacementNamed(context, '/login');
  }
}
