import 'package:flutter/material.dart';
import 'package:samvya/screens/dashboard/dashboard_screen.dart';
import 'package:samvya/screens/dashboard/main_dashboard.dart';
import 'package:samvya/screens/dashboard/profile_screen.dart';

import '../../services/local_storage_service.dart';
import '../dashboard/profile_screen.dart';

class CreateMpinScreen extends StatefulWidget {
  const CreateMpinScreen({super.key});

  @override
  State<CreateMpinScreen> createState() =>
      _CreateMpinScreenState();
}

class _CreateMpinScreenState
    extends State<CreateMpinScreen> {

  final mpinController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create MPIN",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 20),

            TextField(
              controller: mpinController,
              keyboardType:
              TextInputType.number,

              maxLength: 4,

              obscureText: true,

              decoration:
              const InputDecoration(
                labelText:
                "Enter 4 Digit MPIN",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {

                await LocalStorageService
                    .saveMPIN(
                  mpinController.text,
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const DashboardScreen()
                  ),
                );
              },
              child:
              const Text("Continue"),
            )
          ],
        ),
      ),
    );
  }
}