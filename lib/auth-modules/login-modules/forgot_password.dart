import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isNextButtonEnabled = false; 

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link has been sent to your email')),
      );

      
      
      Future.delayed(Duration(seconds: 5), () {
        setState(() {
          _isNextButtonEnabled = true;
        });
      });

    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : Colors.white,
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: isDarkMode ? const Color(0xFF0D2C2D) : const Color(0xFFB6DDF2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email to receive a password reset link.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 16.0),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _sendResetLink,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: isDarkMode ? const Color(0xFF1A3C40) : const Color(0xFFB6DDF2),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      'Send Reset Link',
                      style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.white),
                    ),
                  ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isNextButtonEnabled
                  ? () {
                      Navigator.pushNamed(context, '/reset-password');
                    }
                  : null, 
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: isDarkMode ? Colors.grey[800] : const Color(0xFFB6DDF2),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                'Next',
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
