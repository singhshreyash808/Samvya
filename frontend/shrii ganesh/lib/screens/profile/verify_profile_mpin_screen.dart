import 'package:flutter/material.dart';

import '../../services/local_storage_service.dart';
import 'edit_profile_screen.dart';

class VerifyProfileMpinScreen extends StatefulWidget {
  const VerifyProfileMpinScreen({super.key});

  @override
  State<VerifyProfileMpinScreen> createState() =>
      _VerifyProfileMpinScreenState();
}

class _VerifyProfileMpinScreenState
    extends State<VerifyProfileMpinScreen> {

  final TextEditingController mpinController =
  TextEditingController();

  Future<void> verifyMpin() async {

    String? savedMpin =
    await LocalStorageService.getMPIN();

    if (savedMpin == mpinController.text.trim()) {

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
        ),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect MPIN"),
        ),
      );
    }
  }

  @override
  void dispose() {
    mpinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Verify MPIN"),
        backgroundColor: const Color(0xff0F9D8A),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(height: 40),

            const Icon(
              Icons.lock,
              size: 90,
              color: Color(0xff0F9D8A),
            ),

            const SizedBox(height: 20),

            const Text(
              "Enter your MPIN",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: mpinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "MPIN",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xff0F9D8A),
                ),

                onPressed: verifyMpin,

                child: const Text(
                  "VERIFY",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}