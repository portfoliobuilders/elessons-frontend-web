import 'package:flutter/material.dart';
import '../landingscreen/landingscreen.dart';

/// Legacy WelcomeScreen alias delegating to [LandingScreen].
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LandingScreen();
  }
}
