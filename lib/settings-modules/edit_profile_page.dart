import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; 

class EditProfilePage extends StatefulWidget {
  final String userId;

  const EditProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _birthDateController;

  DateTime? _selectedBirthDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _birthDateController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await supabase
          .from('user_admin')
          .select()
          .eq('id', widget.userId)
          .single();

      final user = response as Map<String, dynamic>;

      setState(() {
        _firstNameController.text = user['fname'] ?? '';
        _lastNameController.text = user['lname'] ?? '';
        _emailController.text = user['email'] ?? '';
        _usernameController.text = user['username'] ?? '';
        if (user['bdate'] != null) {
          _selectedBirthDate = DateTime.parse(user['bdate']);
          _birthDateController.text = DateFormat('yyyy-MM-dd').format(_selectedBirthDate!);
        }
        _isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final updates = {
        'fname': _firstNameController.text,
        'lname': _lastNameController.text,
        'email': _emailController.text,
        'username': _usernameController.text,
        'bdate': _selectedBirthDate?.toIso8601String(),
      };

      try {
        await supabase
            .from('user_admin')
            .update(updates)
            .eq('id', widget.userId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $error')),
        );
      }
    }
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      _buildProfileHeader(isDarkMode),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              labelText: 'First Name',
                              controller: _firstNameController,
                              isDarkMode: isDarkMode,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              labelText: 'Last Name',
                              controller: _lastNameController,
                              isDarkMode: isDarkMode,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              labelText: 'Email',
                              controller: _emailController,
                              isDarkMode: isDarkMode,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              labelText: 'Username',
                              controller: _usernameController,
                              isDarkMode: isDarkMode,
                            ),
                            const SizedBox(height: 16),
                            _buildDateField(
                              labelText: 'Birth Date',
                              controller: _birthDateController,
                              isDarkMode: isDarkMode,
                              onTap: () => _selectBirthDate(context),
                            ),
                            const SizedBox(height: 20),
                            _buildSaveButton(isDarkMode),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? const [Color(0xFF1D4D4F), Color(0xFF122E31)]
              : const [Color(0xFFA2E3F6), Color(0xFFF3FCFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: isDarkMode ? Colors.white : Colors.grey[300],
            child: Text(
              _firstNameController.text.isNotEmpty
                  ? _firstNameController.text[0].toUpperCase()
                  : '',
              style: TextStyle(
                fontSize: 40,
                color: isDarkMode ? Colors.black : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_capitalize(_firstNameController.text)} ${_capitalize(_lastNameController.text)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    required bool isDarkMode,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white : const Color(0xFF122E31),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: isDarkMode ? Color.fromARGB(58, 255, 255, 255) : Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDarkMode ? const Color(0xFF6EBBC5) : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDarkMode ? const Color(0xFF6EBBC5) : Colors.blueAccent,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $labelText';
        }
        return null;
      },
    );
  }

  Widget _buildDateField({
    required String labelText,
    required TextEditingController controller,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white : const Color(0xFF122E31),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: isDarkMode ? Color.fromARGB(58, 255, 255, 255) : Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDarkMode ? const Color(0xFF6EBBC5) : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDarkMode ? const Color(0xFF6EBBC5) : Colors.blueAccent,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      ),
      readOnly: true,
      onTap: onTap,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your $labelText';
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton(bool isDarkMode) {
    return ElevatedButton(
      onPressed: _saveProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? const Color(0xFF1A3C40) : const Color(0xFF6EBBC5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        'Save',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }
}
