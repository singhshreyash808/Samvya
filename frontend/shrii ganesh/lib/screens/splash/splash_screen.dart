import 'dart:async';
import 'package:flutter/material.dart';
import 'package:samvya/screens/auth/dpdpa_consent_screen.dart';
import 'package:samvya/screens/welcome/welcome_screen.dart';
import '../../services/local_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 3),
          () async {
        final consentGiven = await LocalStorageService.isConsentGiven();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => consentGiven
                ? const WelcomeScreen()
                : const DpdpaConsentScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/icons/logo.png",
              height: 120,
            ),
            const SizedBox(height: 20),
            const Text(
              "SAMVYA",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}