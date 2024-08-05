import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fix_emotion/auth-modules/login-modules/login.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isLoading = false;
  late final StreamSubscription<AuthState> _authStateSubscription;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _authStateSubscription = supabase.auth.onAuthStateChange.listen(
      (data) {
        final session = data.session;
        if (session != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationEmail() async {
    try {
      await supabase.auth.signInWithOtp(
        email: _emailController.text.trim(),
        emailRedirectTo: kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check your email for a verification link!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          data: {'username': _usernameController.text.trim()},
        );

        await _sendVerificationEmail();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please verify your email.')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          _buildBackgroundImage('assets/images/Vector01.png'),
          _buildBackgroundImage('assets/images/Vector6.png'),
          Column(
            children: [
              _buildHeader(context, isDarkMode),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLogo(),
                          const SizedBox(height: 20.0),
                          Text(
                            'Account Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          _buildTextField(
                            labelText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            isDarkMode: isDarkMode,
                          ),
                          _buildTextField(
                            labelText: 'Username',
                            keyboardType: TextInputType.text,
                            controller: _usernameController,
                            isDarkMode: isDarkMode,
                          ),
                          _buildTextField(
                            labelText: 'Password',
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            controller: _passwordController,
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 20.0),
                          _buildNextButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              'Register',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF505050),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo2.png',
      height: 200,
      width: double.infinity,
    );
  }

  Widget _buildTextField({
    required String labelText,
    required TextInputType keyboardType,
    bool obscureText = false,
    required TextEditingController controller,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          if (labelText == 'Email' && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Enter a valid email address';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _registerUser,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6EBBC5),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 18,
        ),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Next',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
    );
  }
}
