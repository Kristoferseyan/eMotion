import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  final bool isLoading;

  const SocialLoginButtons({
    Key? key,
    required this.onGoogleSignIn,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 0),
        SizedBox(
          width: 330, // Full width
          height: 55.0, // Height to match your login button
          child: SignInButton(
            Buttons.Google,
            text: "Sign in with Google",
            onPressed: onGoogleSignIn,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
      ],
    );
  }
}
