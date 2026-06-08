import 'package:flutter/material.dart';
import '../mpin/create_mpin_screen.dart';

class OtpScreen extends StatelessWidget {

  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {

    final otpController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Text("OTP sent to $phoneNumber"),

            const SizedBox(height: 20),

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter OTP",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateMpinScreen(),
                  ),
                );
              },
              child: const Text("Verify"),
            )
          ],
        ),
      ),
    );
  }
}