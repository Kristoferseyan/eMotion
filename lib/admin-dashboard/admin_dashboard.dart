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
        child: _selectedIndex == 0
            ? DashboardPage(userId: widget.userId, userEmail: widget.userEmail)
            : SettingsPage(onLogout: _logout),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Future<void> _logout() async {
    // Add your Supabase signOut logic here
    Navigator.pushReplacementNamed(context, '/login');
  }
}
