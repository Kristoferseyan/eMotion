import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginActivityPage extends StatelessWidget {
  final String userId;

  const LoginActivityPage({Key? key, required this.userId}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchLoginActivities() async {
    final supabase = Supabase.instance.client;

    // Fetch all login times from the login_activity table, ordered by login_time
    final response = await supabase
        .from('login_activity')
        .select('login_time')
        .eq('user_id', userId)
        .order('login_time', ascending: false);

    if (response != null && response.isNotEmpty) {
      return List<Map<String, dynamic>>.from(response);
    } else {
      print('No login activities found for the user.');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      appBar: AppBar(
        title: const Text('Login Activity'),
        backgroundColor: isDarkMode ? const Color(0xFF0D2C2D) : const Color(0xFFB6DDF2),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchLoginActivities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching login activity'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final loginActivities = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: loginActivities.length,
              itemBuilder: (context, index) {
                final activity = loginActivities[index];
                final loginTime = DateTime.parse(activity['login_time']).toLocal();

                return Card(
                  color: isDarkMode ? const Color.fromARGB(255, 23, 57, 61) : Colors.white,
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: Icon(
                      Icons.access_time_rounded,
                      color: isDarkMode ? Colors.white70 : const Color(0xFF317B85),
                    ),
                    title: const Text(
                      'Login Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${loginTime.year}-${loginTime.month.toString().padLeft(2, '0')}-${loginTime.day.toString().padLeft(2, '0')} '
                      '${loginTime.hour.toString().padLeft(2, '0')}:${loginTime.minute.toString().padLeft(2, '0')}:${loginTime.second.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No login activity found'));
          }
        },
      ),
    );
  }
}
