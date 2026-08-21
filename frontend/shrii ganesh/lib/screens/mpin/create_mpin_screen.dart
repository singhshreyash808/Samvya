import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/local_storage_service.dart';
import '../dashboard/main_dashboard.dart';

class CreateMpinScreen extends StatefulWidget {
  const CreateMpinScreen({super.key});

  @override
  State<CreateMpinScreen> createState() => _CreateMpinScreenState();
}

class _CreateMpinScreenState extends State<CreateMpinScreen> {
  final TextEditingController mpinController = TextEditingController();
  final TextEditingController confirmMpinController =
  TextEditingController();

  Future<void> createMpin() async {
    String mpin = mpinController.text.trim();
    String confirm = confirmMpinController.text.trim();

    if (mpin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("mpin.error_digits".tr()),
        ),
      );
      return;
    }

    if (mpin != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("mpin.error_mismatch".tr()),
        ),
      );
      return;
    }

    if (mpin == "1234" ||
        mpin == "1111" ||
        mpin == "0000" ||
        mpin == "9999") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("mpin.error_weak".tr()),
        ),
      );
      return;
    }

    await LocalStorageService.saveMPIN(mpin);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("mpin.success_created".tr()),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainDashboard(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("mpin.create_title".tr()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            const Icon(
              Icons.lock,
              size: 80,
              color: Colors.teal,
            ),

            const SizedBox(height: 20),

            Text(
              "mpin.create_instruction".tr(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: mpinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: "mpin.enter_mpin".tr(),
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: confirmMpinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: "mpin.confirm_mpin".tr(),
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: createMpin,
                child: Text(
                  "mpin.continue".tr(),
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    mpinController.dispose();
    confirmMpinController.dispose();
    super.dispose();
  }
}