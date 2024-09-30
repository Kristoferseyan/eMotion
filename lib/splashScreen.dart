import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'main.dart';

class SplashScreen extends StatelessWidget {
  final bool isAuthenticated;

  const SplashScreen({Key? key, required this.isAuthenticated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      home: AnimatedSplashScreen(
        splash: SizedBox.expand(
          child: Image.asset(
            "assets/splashscreen/Sequence_01.gif",
            fit: BoxFit.cover,
          ),
        ),
        nextScreen: MyApp(isAuthenticated: isAuthenticated),
        splashIconSize: double.infinity,
        duration: 6000,
        backgroundColor: Colors.transparent,
        pageTransitionType: PageTransitionType.fade,
      ),
    );
  }
}
