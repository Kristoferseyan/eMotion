import 'package:flutter/material.dart';
import 'supabase_client.dart';
import 'login.dart';
import 'package:supabase/supabase.dart';

class RegPage extends StatefulWidget {
  const RegPage({Key? key}) : super(key: key);

  @override
  _RegPageState createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final supabase = SupabaseClientService.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await supabase.from('users').insert({
          'fName': _firstNameController.text,
          'lName': _lastNameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'username': _usernameController.text,
          'age': int.tryParse(_ageController.text) ?? 0,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration successful')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } on PostgrestException catch (error) {
        // Handle Supabase specific exceptions
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      } catch (error) {
        // Handle other types of exceptions
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An unexpected error occurred.')));
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
                        children: [
                          _buildLogo(),
                          _buildTextField(
                            labelText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            isDarkMode: isDarkMode,
                          ),
                          _buildTextField(
                            labelText: 'Password',
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            controller: _passwordController,
                            isDarkMode: isDarkMode,
                          ),
                          _buildTextField(
                            labelText: 'Username',
                            keyboardType: TextInputType.text,
                            controller: _usernameController,
                            isDarkMode: isDarkMode,
                          ),
                          _buildTextField(
                            labelText: 'First name',
                            keyboardType: TextInputType.text,
                            controller: _firstNameController,
                            isDarkMode: isDarkMode,
                          ),
                          _buildTextField(
                            labelText: 'Last name',
                            keyboardType: TextInputType.text,
                            controller: _lastNameController,
                            isDarkMode: isDarkMode,
                          ),
                          _buildTextField(
                            labelText: 'Age',
                            keyboardType: TextInputType.number,
                            controller: _ageController,
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 20.0),
                          _buildRegisterButton(),
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
      height: 150,
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
          labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          filled: true,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your $labelText';
          }
          return null;
        },
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _registerUser,
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
      child: const Text(
        'Register',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}