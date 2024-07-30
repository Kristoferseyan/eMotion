import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool isLoading;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onLogin;

  const LoginForm({
    Key? key,
    required this.usernameController,
    required this.passwordController,
    required this.rememberMe,
    required this.isLoading,
    required this.onRememberMeChanged,
    required this.onLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildTextField(
            labelText: 'Username',
            keyboardType: TextInputType.text,
            controller: usernameController,
          ),
          const SizedBox(height: 16.0),
          _buildTextField(
            labelText: 'Password',
            keyboardType: TextInputType.text,
            obscureText: true,
            controller: passwordController,
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Checkbox(
                value: rememberMe,
                onChanged: (bool? newValue) {
                  onRememberMeChanged(newValue ?? false);
                },
              ),
              const Text('Remember Me'),
            ],
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: isLoading ? null : onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6EBBC5),
              minimumSize: const Size(double.infinity, 60),
            ),
            child: Text(
              isLoading ? 'Logging in...' : 'Login',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required TextInputType keyboardType,
    bool obscureText = false,
    required TextEditingController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }
}
