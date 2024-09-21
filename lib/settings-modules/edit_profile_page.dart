import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  late TextEditingController _ageController;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _ageController = TextEditingController();

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
    _ageController.dispose();
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
        _ageController.text = user['age']?.toString() ?? '';
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
        'age': int.tryParse(_ageController.text),
      };

      try {
        final response = await supabase
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
                      _buildProfileAvatar(),
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
                            _buildTextField(
                              labelText: 'Age',
                              controller: _ageController,
                              isDarkMode: isDarkMode,
                              keyboardType: TextInputType.number,
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

  Widget _buildProfileAvatar() {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey[200],
      child: Icon(Icons.person, size: 50, color: Colors.grey[400]),
    );
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
        labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $labelText';
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton(bool isDarkMode) {
    return ElevatedButton(
      onPressed: _saveProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? const Color(0xFF1A3C40) : const Color.fromARGB(255, 110, 187, 197),
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
