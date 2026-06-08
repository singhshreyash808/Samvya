import 'package:flutter/material.dart';
import 'package:samvya/screens/dashboard/dashboard_screen.dart';
import 'package:samvya/screens/dashboard/main_dashboard.dart';
import 'package:samvya/screens/dashboard/profile_screen.dart';
import '../../services/local_storage_service.dart';

import '../mpin/verify_mpin_screen.dart';
import '../dashboard/profile_screen.dart';

class VerifyMpinScreen extends StatefulWidget {
  const VerifyMpinScreen({super.key});

  @override
  State<VerifyMpinScreen> createState() =>
      _VerifyMpinScreenState();
}

class _VerifyMpinScreenState
    extends State<VerifyMpinScreen> {

  final mpinController = TextEditingController();

  Future<void> verifyMpin() async {

    String? savedMpin =
    await LocalStorageService.getMPIN();



    if (savedMpin == mpinController.text) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const DashboardScreen(),
        ),
      );

    } else {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text("Incorrect MPIN"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter MPIN"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: mpinController,
              keyboardType:
              TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration:
              const InputDecoration(
                labelText: "MPIN",
              ),
            ),

            ElevatedButton(
              onPressed: verifyMpin,
              child:
              const Text("Login"),
            )
          ],
        ),
      ),
    );
  }
}