import 'package:fix_emotion/auth-modules/login-modules/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'settings-modules/settings_page.dart';
import 'dashboard-modules/dashboard.dart';
import 'auth-modules/login-modules/login.dart';
import 'auth-modules/reg-modules/registration.dart';
import 'settings-modules/notification_settings_page.dart';
import 'settings-modules/privacy_settings_page.dart';

final _logger = Logger('MyApp');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/auth.env");
  final String? supabaseUrl = dotenv.env['SUPABASE_URL'];
  final String? supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    _logger.severe("Environment variables for Supabase are missing!");
    throw Exception("Environment variables for Supabase are missing!");
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  final supabase = Supabase.instance.client;
  final bool isAuthenticated = supabase.auth.currentSession != null;

  runApp(MyApp(isAuthenticated: isAuthenticated));
}

class MyApp extends StatefulWidget {
  final bool isAuthenticated;

  const MyApp({Key? key, required this.isAuthenticated}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void setTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: _onGenerateRoute,
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _themeMode, // Apply the dynamically updated theme
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    Uri uri = Uri.parse(settings.name ?? '');

    _logger.info('Navigating to: ${settings.name}');
    _logger.info('URI Scheme: ${uri.scheme}');
    _logger.info('URI Path: ${uri.path}');
    _logger.info('Query Parameters: ${uri.queryParameters}');

    final args = getRouteArguments(settings);

    if (uri.scheme == 'emotion' && uri.path == '/reset-password') {
      final token = uri.queryParameters['token'] ?? '';
      _logger.info('Reset Password Token from Deep Link: $token');
      return MaterialPageRoute(
        builder: (_) => ResetPasswordPage(accessToken: token),
      );
    }

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginReg());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegistrationPage());
      case '/dashboard':
        return MaterialPageRoute(
          builder: (_) => Dashboard(
            userId: args['userId'] ?? '',
            userEmail: args['userEmail'] ?? '',
          ),
        );
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => SettingsPage(userId: args['userId'] ?? ''),
        );
      case '/notification-settings':
        return MaterialPageRoute(builder: (_) => NotificationSettingsPage());
      case '/reset-password':
        final token = args['token'] ?? '';
        _logger.info('Navigating to ResetPasswordPage with token: $token');
        return MaterialPageRoute(
          builder: (_) => ResetPasswordPage(accessToken: token),
        );
      case '/privacy-settings':
        return MaterialPageRoute(
          builder: (_) => PrivacySettingsPage(),
        );
      default:
        _logger.warning('Unknown route: ${settings.name}');
        return MaterialPageRoute(builder: (_) => const LoginReg());
    }
  }

  Map<String, dynamic> getRouteArguments(RouteSettings settings) {
    return settings.arguments as Map<String, dynamic>? ?? {};
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color.fromARGB(255, 49, 123, 133),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buttonStyle(Colors.white, Colors.black),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _outlinedButtonStyle(Colors.white),
      ),
    );  
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color.fromARGB(255, 18, 46, 49),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buttonStyle(Colors.white, Colors.black),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _outlinedButtonStyle(Colors.white),
      ),
    );
  }

  // Reusable button styles
  ButtonStyle _buttonStyle(Color backgroundColor, Color foregroundColor) {
    return ElevatedButton.styleFrom(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
    );
  }

  ButtonStyle _outlinedButtonStyle(Color borderColor) {
    return OutlinedButton.styleFrom(
      foregroundColor: borderColor,
      side: BorderSide(color: borderColor),
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
                height: MediaQuery.of(context).size.height * 0.25,
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _navigateBasedOnAuth(supabase, context);
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

  void _navigateBasedOnAuth(SupabaseClient supabase, BuildContext context) {
    if (supabase.auth.currentSession != null) {
      Navigator.pushNamed(context, '/dashboard');
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }
}
