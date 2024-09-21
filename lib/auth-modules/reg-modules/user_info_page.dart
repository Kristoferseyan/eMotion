import 'package:fix_emotion/auth-modules/login-modules/login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class UserInfoPage extends StatefulWidget {
  final String userId;
  const UserInfoPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _bDateController = TextEditingController();

  bool _isLoading = false;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _fNameController.dispose();
    _lNameController.dispose();
    _bDateController.dispose();
    super.dispose();
  }

  Future<void> _saveUserInfo() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        DateTime birthDate = DateFormat('yyyy-MM-dd').parse(_bDateController.text.trim());
        int age = _calculateAge(birthDate);

        // Update to use the new 'user_admin' table
        final response = await supabase.from('user_admin').update({
          'fname': _fNameController.text.trim(),
          'lname': _lNameController.text.trim(),
          'age': age,
          'bdate': _bDateController.text.trim(),
        }).eq('id', widget.userId).select();

        if (response.isEmpty) {
          throw Exception('Failed to save user information.');
        }

        // Insert default permissions for the user
        final permissionResponse = await supabase.from('user_permissions').insert({
          'user_id': widget.userId,
          'camera_access': false,
          'motion_data_sharing': false,
          'anonymous_data_collection': false,
        }).select();

        if (permissionResponse.isEmpty) {
          throw Exception('Failed to insert user permissions.');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Information saved successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
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

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
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
                      padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20.0),
                          Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          _buildTextField(
                            labelText: 'First Name',
                            keyboardType: TextInputType.text,
                            controller: _fNameController,
                            isDarkMode: isDarkMode,
                          ),
                          _buildTextField(
                            labelText: 'Last Name',
                            keyboardType: TextInputType.text,
                            controller: _lNameController,
                            isDarkMode: isDarkMode,
                          ),
                          _buildDateField(
                            labelText: 'Birth Date',
                            controller: _bDateController,
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 20.0),
                          _buildSaveButton(),
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
              'Complete Your Profile',
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

  Widget _buildTextField({
    required String labelText,
    required TextInputType keyboardType,
    required TextEditingController controller,
    required bool isDarkMode,
    bool obscureText = false,
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
          return null;
        },
      ),
    );
  }

  Widget _buildDateField({
    required String labelText,
    required TextEditingController controller,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );

        if (pickedDate != null) {
          controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        }
      },
      child: AbsorbPointer(
        child: _buildTextField(
          labelText: labelText,
          keyboardType: TextInputType.datetime,
          controller: controller,
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveUserInfo,
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
              'Save Information',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
    );
  }
}
