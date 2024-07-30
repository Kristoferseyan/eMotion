import 'package:fix_emotion/auth-modules/supabase_client.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = SupabaseClientService.instance.client;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _ageController;

  bool _isFirstNameEditing = false;
  bool _isLastNameEditing = false;
  bool _isEmailEditing = false;
  bool _isUsernameEditing = false;
  bool _isAgeEditing = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _ageController = TextEditingController();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfile(); // Call _loadProfile after build context is ready
  }

  Future<void> _loadProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      // Handle the case where there is no logged-in user
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is logged in.')),
        );
      });
      return;
    }

    final response = await supabase.from('users').select().eq('id', userId).single();

    if (response['error'] == null && response != null) {
      final user = response as Map<String, dynamic>;
      setState(() {
        _firstNameController.text = user['fName'] ?? '';
        _lastNameController.text = user['lName'] ?? '';
        _emailController.text = user['email'] ?? '';
        _usernameController.text = user['username'] ?? '';
        _ageController.text = (user['age']?.toString()) ?? '';
      });
    } else {
      // Handle error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${response['error']?.message}')),
        );
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        // Handle the case where there is no logged-in user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is logged in.')),
        );
        return;
      }

      final updates = {
        'fName': _firstNameController.text,
        'lName': _lastNameController.text,
        'email': _emailController.text,
        'username': _usernameController.text,
        'age': int.tryParse(_ageController.text),
      };

      final response = await supabase.from('users').update(updates).eq('id', userId);

      if (response.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        setState(() {
          _isFirstNameEditing = false;
          _isLastNameEditing = false;
          _isEmailEditing = false;
          _isUsernameEditing = false;
          _isAgeEditing = false;
        });
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${response.error?.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      labelText: 'First Name',
                      controller: _firstNameController,
                      isDarkMode: isDarkMode,
                      isEditing: _isFirstNameEditing,
                      onEditPressed: () {
                        setState(() {
                          _isFirstNameEditing = !_isFirstNameEditing;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      labelText: 'Last Name',
                      controller: _lastNameController,
                      isDarkMode: isDarkMode,
                      isEditing: _isLastNameEditing,
                      onEditPressed: () {
                        setState(() {
                          _isLastNameEditing = !_isLastNameEditing;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      labelText: 'Email',
                      controller: _emailController,
                      isDarkMode: isDarkMode,
                      keyboardType: TextInputType.emailAddress,
                      isEditing: _isEmailEditing,
                      onEditPressed: () {
                        setState(() {
                          _isEmailEditing = !_isEmailEditing;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      labelText: 'Username',
                      controller: _usernameController,
                      isDarkMode: isDarkMode,
                      isEditing: _isUsernameEditing,
                      onEditPressed: () {
                        setState(() {
                          _isUsernameEditing = !_isUsernameEditing;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      labelText: 'Age',
                      controller: _ageController,
                      isDarkMode: isDarkMode,
                      keyboardType: TextInputType.number,
                      isEditing: _isAgeEditing,
                      onEditPressed: () {
                        setState(() {
                          _isAgeEditing = !_isAgeEditing;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 110, 187, 197),
                        minimumSize: const Size(double.infinity, 60),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    required bool isDarkMode,
    required bool isEditing,
    required VoidCallback onEditPressed,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            readOnly: !isEditing,
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
            keyboardType: keyboardType,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your $labelText';
              }
              return null;
            },
          ),
        ),
        IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.edit),
          color: isDarkMode ? Colors.white : Colors.black,
          onPressed: onEditPressed,
        ),
      ],
    );
  }
}
