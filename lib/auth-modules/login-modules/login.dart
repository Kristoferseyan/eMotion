import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_header.dart';
import 'login_form.dart';
import 'social_login_buttons.dart';
import '../logo.dart';
import 'package:fix_emotion/dashboard-modules/dashboard.dart';
import '../authentication_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  bool rememberMe = false;
  bool _isLoading = false;

  final authService = AuthenticationService();

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    _loadSavedCredentials();
  }

  void _setupAuthListener() {
    authService.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _navigateToDashboard();
      }
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final credentials = await authService.loadSavedCredentials();
    if (credentials != null) {
      setState(() {
        rememberMe = true;
        usernameController.text = credentials['username']!;
        passwordController.text = credentials['password']!;
      });
    }
  }

  Future<void> _navigateToDashboard() async {
    final userData = await authService.getUserData();
    if (userData != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Dashboard(
            userId: userData['userId']!,
            userEmail: userData['userEmail']!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : Colors.white,
      body: Stack(
        children: [
          _buildBackgroundImage('assets/images/Vector01.png'),
          _buildBackgroundImage('assets/images/Vector6.png'),
          Column(
            children: [
              LoginHeader(isDarkMode: isDarkMode),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Logo(),
                      LoginForm(
                        usernameController: usernameController,
                        passwordController: passwordController,
                        rememberMe: rememberMe,
                        isLoading: _isLoading,
                        onRememberMeChanged: (value) {
                          setState(() {
                            rememberMe = value;
                          });
                        },
                        onLogin: _loginUser,
                      ),
                      SocialLoginButtons(
                        onGoogleSignIn: _googleSignIn,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loginUser() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await authService.signInWithUsernameAndPassword(username, password);
      if (user != null) {
        if (rememberMe) {
          await authService.saveCredentials(username, password);
        } else {
          await authService.removeCredentials();
        }
        await _navigateToDashboard();
      }
    } catch (error) {
      print('Unexpected error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error occurred: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await authService.signInWithGoogle();
    } catch (error) {
      print('Error during Google Sign-In: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during Google Sign-In: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildBackgroundImage(String assetPath) {
    return Positioned.fill(
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
      ),
    );
  }
}
