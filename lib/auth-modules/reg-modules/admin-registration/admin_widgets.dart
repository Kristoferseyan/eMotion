import 'package:flutter/material.dart';


class AdminHeader extends StatelessWidget {
  final bool isDarkMode;

  const AdminHeader({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              'Monitor Registration',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF505050),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class AdminTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool isDarkMode;
  final TextInputType keyboardType;

  const AdminTextField({
    Key? key,
    required this.labelText,
    required this.controller,
    required this.isDarkMode,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black), 
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
}


class AdminPasswordField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool isPasswordVisible;
  final VoidCallback toggleVisibility;
  final bool isDarkMode;
  final bool Function()? validatePasswords;

  const AdminPasswordField({
    Key? key,
    required this.labelText,
    required this.controller,
    required this.isPasswordVisible,
    required this.toggleVisibility,
    required this.isDarkMode,
    this.validatePasswords,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        obscureText: !isPasswordVisible,
        style: const TextStyle(color: Colors.black), 
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
          suffixIcon: IconButton(
            icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: toggleVisibility,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          if (labelText == 'Confirm Password' && validatePasswords != null && !validatePasswords!()) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
    );
  }
}



class AdminToggle extends StatelessWidget {
  final bool isOrganizationSelected; 
  final ValueChanged<bool> onToggle; 

  const AdminToggle({
    Key? key,
    required this.isOrganizationSelected,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.group, color: !isOrganizationSelected ? Colors.blue : Colors.grey),
          onPressed: () => onToggle(false), 
        ),
        Switch(
          value: isOrganizationSelected, 
          onChanged: onToggle,
          activeColor: Colors.blue,
          inactiveThumbColor: Colors.grey,
        ),
        IconButton(
          icon: Icon(Icons.apartment, color: isOrganizationSelected ? Colors.blue : Colors.grey),
          onPressed: () => onToggle(true), 
        ),
      ],
    );
  }
}



class AdminRegisterButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const AdminRegisterButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6EBBC5),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Register as Monitor'),
    );
  }
}
