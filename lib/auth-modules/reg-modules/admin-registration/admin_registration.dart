import 'dart:async';
import 'package:fix_emotion/auth-modules/reg-modules/admin-registration/terms_and_conditions_admin.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';
import 'admin_widgets.dart'; 

class AdminRegistrationPage extends StatefulWidget {
  const AdminRegistrationPage({Key? key}) : super(key: key);

  @override
  _AdminRegistrationPageState createState() => _AdminRegistrationPageState();
}

class _AdminRegistrationPageState extends State<AdminRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _organizationNameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isOrganizationSelected = true;
  bool _agreedToTerms = false; // Track if Terms are accepted

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _organizationNameController.dispose();
    _roleController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _registerAdmin() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        String hashedPassword = BCrypt.hashpw(_passwordController.text.trim(), BCrypt.gensalt());

        final response = await supabase.from('admin_users').insert({
          'email': _emailController.text.trim(),
          'password': hashedPassword,
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'organization_name': _isOrganizationSelected ? _organizationNameController.text.trim() : null,
          'organization_role': _isOrganizationSelected ? _roleController.text.trim() : null,
          'group_name': !_isOrganizationSelected ? _groupNameController.text.trim() : null,
        }).select().single();

        if (response['error'] != null) {
          throw Exception('Failed to register admin: ${response['error'].message}');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin registration successful!')),
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

  bool _validatePasswords() {
    return _passwordController.text == _confirmPasswordController.text;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AdminTermsAndConditionsDialog(
          onAccept: () {
            Navigator.of(context).pop(); // Close the dialog
            setState(() {
              _agreedToTerms = true; // Proceed to registration
            });
            _registerAdmin(); // Call the registration function after accepting terms
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminHeader(isDarkMode: isDarkMode),
              const SizedBox(height: 20),
              AdminTextField(
                labelText: 'First Name',
                controller: _firstNameController,
                isDarkMode: isDarkMode,
              ),
              AdminTextField(
                labelText: 'Last Name',
                controller: _lastNameController,
                isDarkMode: isDarkMode,
              ),
              AdminTextField(
                labelText: 'Email',
                controller: _emailController,
                isDarkMode: isDarkMode,
                keyboardType: TextInputType.emailAddress,
              ),
              AdminPasswordField(
                labelText: 'Password',
                controller: _passwordController,
                isPasswordVisible: _isPasswordVisible,
                toggleVisibility: _togglePasswordVisibility,
                isDarkMode: isDarkMode,
              ),
              AdminPasswordField(
                labelText: 'Confirm Password',
                controller: _confirmPasswordController,
                isPasswordVisible: _isPasswordVisible,
                toggleVisibility: _togglePasswordVisibility,
                isDarkMode: isDarkMode,
                validatePasswords: _validatePasswords,
              ),
              AdminToggle(
                isOrganizationSelected: _isOrganizationSelected,
                onToggle: (value) {
                  setState(() {
                    _isOrganizationSelected = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              _isOrganizationSelected
                  ? AdminTextField(
                      labelText: 'Organization Name',
                      controller: _organizationNameController,
                      isDarkMode: isDarkMode,
                    )
                  : AdminTextField(
                      labelText: 'Group Name',
                      controller: _groupNameController,
                      isDarkMode: isDarkMode,
                    ),
              if (_isOrganizationSelected)
                AdminTextField(
                  labelText: 'Role in Organization',
                  controller: _roleController,
                  isDarkMode: isDarkMode,
                ),
              const SizedBox(height: 20),
              AdminRegisterButton(
                isLoading: _isLoading,
                onPressed: _showTermsAndConditions, // Show terms before registering
              ),
            ],  
          ),
        ),
      ),
    );
  }
}