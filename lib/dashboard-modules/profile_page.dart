import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fix_emotion/auth-modules/login-modules/login.dart';
import '../auth-modules/authentication_service.dart'; // Import your AuthenticationService

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  final AuthenticationService authService = AuthenticationService(); // Create an instance of AuthenticationService
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await supabase
          .from('users')
          .select('fName, lName, email, username, age, bDate')
          .eq('id', widget.userId)
          .single();

      setState(() {
        userData = response;
      });
    } catch (error) {
      print('Error fetching user data: $error');
    }
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
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDarkMode
                              ? const [Color(0xFF1D4D4F), Color(0xFF122E31)]
                              : const [Color(0xFFA2E3F6), Color(0xFFF3FCFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: isDarkMode ? Colors.white : Colors.grey[300],
                            child: Text(
                              (userData!['fName'][0] as String).toUpperCase(),
                              style: TextStyle(
                                fontSize: 40,
                                color: isDarkMode ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${_capitalize(userData!['fName'])} ${_capitalize(userData!['lName'])}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildProfileDetailCard(
                      context,
                      icon: Icons.email,
                      title: 'Email',
                      value: userData!['email'] ?? '',
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 10),
                    _buildProfileDetailCard(
                      context,
                      icon: Icons.person,
                      title: 'Username',
                      value: userData!['username'] ?? '',
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 10),
                    _buildProfileDetailCard(
                      context,
                      icon: Icons.calendar_today,
                      title: 'Birthdate',
                      value: userData!['bDate'] ?? '',
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 10),
                    _buildProfileDetailCard(
                      context,
                      icon: Icons.cake,
                      title: 'Age',
                      value: userData!['age'].toString(),
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? const Color(0xFF1A3C40) : Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Widget _buildProfileDetailCard(BuildContext context, {required IconData icon, required String title, required String value, required bool isDarkMode}) {
    return Card(
      color: isDarkMode ? const Color(0xFF1A3C40) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: isDarkMode ? Colors.white : Colors.black, size: 30),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
