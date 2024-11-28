import 'package:fix_emotion/admin-dashboard/admin_dashboard.dart';
import 'package:fix_emotion/auth-modules/login-modules/forgot_password.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_header.dart';
import 'login_form.dart';
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
  bool _isPasswordVisible = false;
  String _errorMessage = '';

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
      final role = await _getUserRole(userData['userId']!);

      if (role == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AdminDashboard(
              userId: userData['userId']!,
              userEmail: userData['userEmail']!,
            ),
          ),
        );
      } else if (role == 'user') {
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
  }

  Future<String?> _getUserRole(String userId) async {
    try {
      final response = await authService.client
          .from('user_admin')
          .select('role')
          .eq('id', userId)
          .single();

      if (response['role'] == "admin") {
        return response['role'] as String;
      } else if (response['role'] == "user") {
        return response['role'] as String;
      }
      return null;
    } catch (error) {
      print('Error fetching user role: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                        isPasswordVisible: _isPasswordVisible,
                        onTogglePasswordVisibility: _togglePasswordVisibility,
                        errorMessage: _errorMessage,
                        onLogin: _loginUser,
                        onForgotPassword: _navigateToForgotPassword,
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

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _loginUser() async {
    final input = usernameController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = await authService.signInWithUsernameOrEmailAndPassword(input, password);
      if (user != null) {
        if (rememberMe) {
          await authService.saveCredentials(input, password);
        } else {
          await authService.removeCredentials();
        }
        await _navigateToDashboard();
      }
    } catch (error) {
      print('Unexpected error: $error');
      setState(() {
        _errorMessage = 'Incorrect username/email or password';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $_errorMessage')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToForgotPassword() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
    );
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
