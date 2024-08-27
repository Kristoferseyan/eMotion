import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fix_emotion/auth-modules/reg-modules/user_info_page.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:fix_emotion/main.dart';

import 'terms_and_conditions_dialog.dart';

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
  bool _agreedToTerms = false;
  bool _termsRead = false;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreedToTerms) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginReg(),
          ),
        );
        return;
      }

      try {
        setState(() {
          _isLoading = true;
        });

        String hashedPassword = BCrypt.hashpw(_passwordController.text.trim(), BCrypt.gensalt());

        final response = await supabase.from('users').insert({
          'email': _emailController.text.trim(),
          'password': hashedPassword,
          'username': _usernameController.text.trim(),
        }).select().single();

        if (response['error'] != null) {
          throw Exception('Failed to insert user data: ${response['error'].message}');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserInfoPage(userId: response['id']),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}'), backgroundColor: Colors.red),
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
                          _buildTermsButton(),
                          _buildTermsCheckbox(),
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
        color: isDarkMode ? Colors.grey[800] : Colors.white70,
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
            color: isDarkMode ? Colors.black87 : Colors.black87,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: true,
          fillColor: isDarkMode ? Colors.white : Colors.white70,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(
          color: isDarkMode ? Colors.black : Colors.black87,
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

  Widget _buildTermsButton() {
    return TextButton(
      onPressed: () {
        _showTermsAndConditions();
      },
      child: const Text(
        'Read Terms and Conditions',
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _agreedToTerms,
          onChanged: _termsRead
              ? (bool? value) {
                  setState(() {
                    _agreedToTerms = value ?? false;
                  });
                }
              : null,
        ),
        Expanded(
          child: Text(
            'I agree to the Terms and Conditions',
            style: TextStyle(
              fontSize: 14,
              color: _agreedToTerms ? Colors.black : Colors.red,
            ),
          ),
        ),
      ],
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

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const TermsAndConditionsDialog();
      },
    ).then((_) {
      setState(() {
        _termsRead = true;
      });
    });
  }
}
