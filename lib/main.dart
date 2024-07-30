import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'auth-modules/login.dart';
import 'auth-modules/registration.dart';
import 'settings-modules/settings_page.dart';
import 'dashboard-modules/dashboard.dart'; 
import 'auth-modules/authentication_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://zpnrhnnbetfdvnffcrmj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpwbnJobm5iZXRmZHZuZmZjcm1qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE2MTUxMTcsImV4cCI6MjAzNzE5MTExN30.Dw3FMknFnLzuBeqJY7pTeCMCRwIoBl2ihyh_uXmRZJ8',
  );

  final AuthenticationService authService = AuthenticationService();
  final bool isAuthenticated = authService.isAuthenticated();

  runApp(MyApp(isAuthenticated: isAuthenticated));
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;
  const MyApp({Key? key, required this.isAuthenticated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: isAuthenticated ? '/dashboard' :'/'  ,
      routes: {
        '/': (context) => const LoginReg(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegPage(),
        '/settings': (context) => SettingsPage(),
        '/dashboard': (context) => const Dashboard(userName: '', userEmail: '',),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color.fromARGB(255, 49, 123, 133),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black, backgroundColor: Colors.white, 
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white, side: const BorderSide(color: Colors.white), 
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color.fromARGB(255, 18, 46, 49),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black, backgroundColor: Colors.white, 
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white, side: const BorderSide(color: Colors.white), 
          ),
        ),
      ),
      themeMode: ThemeMode.system,
    );
  }
}

class LoginReg extends StatelessWidget {
  const LoginReg({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    final AuthenticationService authService = AuthenticationService();

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFF317B85),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/logo.png',
                height: 200,
              ),
              const SizedBox(height: 40), 
              SizedBox(
                height: 50, 
                width: double.infinity, 
                child: ElevatedButton(
                  onPressed: () {
                    if (authService.isAuthenticated()) {
                      Navigator.pushNamed(context, '/dashboard');
                    } else {
                      Navigator.pushNamed(context, '/login');
                    }
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
