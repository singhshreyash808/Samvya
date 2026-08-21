import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';

class ChangeMpinScreen extends StatefulWidget {
  const ChangeMpinScreen({super.key});

  @override
  State<ChangeMpinScreen> createState() => _ChangeMpinScreenState();
}

class _ChangeMpinScreenState extends State<ChangeMpinScreen> {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  bool loading = false;

  Future<void> changeMpin() async {
    setState(() {
      loading = true;
    });

    String? savedMpin = await LocalStorageService.getMPIN();

    if (savedMpin != currentController.text) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Current MPIN is incorrect"),
        ),
      );
      return;
    }

    if (newController.text.length != 4) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("MPIN must be 4 digits"),
        ),
      );
      return;
    }

    if (newController.text != confirmController.text) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("MPIN does not match"),
        ),
      );
      return;
    }

    await LocalStorageService.saveMPIN(
      newController.text,
    );

    setState(() {
      loading = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("MPIN Changed Successfully"),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change MPIN"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: currentController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: "Current MPIN",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: newController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: "New MPIN",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: "Confirm MPIN",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : changeMpin,
                child: loading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text("Change MPIN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}