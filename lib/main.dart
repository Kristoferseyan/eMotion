import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'settings-modules/settings_page.dart';
import 'dashboard-modules/dashboard.dart';
import 'auth-modules/login-modules/login.dart';
import 'auth-modules/reg-modules/registration.dart';
import 'settings-modules/notification_settings_page.dart';
import 'settings-modules/privacy_settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: "assets/auth.env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final supabase = Supabase.instance.client;
  final bool isAuthenticated = supabase.auth.currentSession != null;

  runApp(MyApp(isAuthenticated: isAuthenticated));
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;
  const MyApp({Key? key, required this.isAuthenticated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: isAuthenticated ? '/dashboard' : '/',
      routes: {
        '/': (context) => const LoginReg(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegistrationPage(),
        '/settings': (context) => SettingsPage(),
        '/dashboard': (context) => const Dashboard(userId: '', userEmail: '',),
        '/notification-settings': (context) => NotificationSettingsPage(),
        'privacy-settings': (context) => PrivacySettingsPage(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color.fromARGB(255, 49, 123, 133),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color.fromARGB(255, 18, 46, 49),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
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
    final supabase = Supabase.instance.client;

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
                    if (supabase.auth.currentSession != null) {
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
