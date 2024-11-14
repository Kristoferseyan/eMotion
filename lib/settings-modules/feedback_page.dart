import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackPage extends StatefulWidget {
  final String userId;
  final String userEmail; 

  const FeedbackPage({Key? key, required this.userId, required this.userEmail}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool _isSubmitting = false;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserName(); 
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  
  Future<void> _fetchUserName() async {
    try {
      final response = await supabase
          .from('user_admin')
          .select('fname, lname')
          .eq('id', widget.userId)
          .single();

      if (response != null) {
        final firstName = response['fname'] ?? '';
        final lastName = response['lname'] ?? '';
        setState(() {
          _userName = '$firstName $lastName'.trim();
        });
      }
    } catch (error) {
      print('Error fetching user name: $error');
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      
      await supabase.from('feedback').insert({
        'user_id': widget.userId,
        'feedback': _feedbackController.text,
        'submitted_at': DateTime.now().toIso8601String(),
      });

      
      await _sendFeedbackEmail(widget.userEmail, _feedbackController.text, _userName.isNotEmpty ? _userName : widget.userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully!')),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting feedback: $error')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  
Future<void> _sendFeedbackEmail(String userEmail, String feedbackText, String userNameOrId) async {
  final smtpServer = gmail('d06273540@gmail.com', 'rlzdtfsmlldudcfn'); 

  final message = Message()
    ..from = Address('d06273540@gmail.com', 'eMotion Mail') 
    ..recipients.add('d06273540@gmail.com') 
    ..subject = 'Feedback from $userNameOrId' 
    ..text = 'Feedback from $userNameOrId (Email: $userEmail):\n\n$feedbackText' 
    ..headers = {'Reply-To': userEmail}; 

  try {
    final sendReport = await send(message, smtpServer);
    print('Feedback email sent: $sendReport');
  } catch (e) {
    print('Failed to send feedback email: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to send feedback email: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
      appBar: AppBar(
        title: const Text('Send Feedback'),
        backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFFF3FCFF),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildFeedbackTextField(isDarkMode),
                const SizedBox(height: 20),
                _buildSubmitButton(isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
  Widget _buildFeedbackTextField(bool isDarkMode) {
    return TextFormField(
      controller: _feedbackController,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: 'Your Feedback',
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white : const Color(0xFF122E31),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: isDarkMode ? const Color.fromARGB(58, 255, 255, 255) : Colors.white,
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
          return 'Please enter your feedback';
        }
        return null;
      },
    );
  }

  
  Widget _buildSubmitButton(bool isDarkMode) {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitFeedback,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? const Color(0xFF1A3C40) : const Color(0xFF6EBBC5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: _isSubmitting
          ? const CircularProgressIndicator()
          : const Text(
              'Submit Feedback',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
    );
  }
}
