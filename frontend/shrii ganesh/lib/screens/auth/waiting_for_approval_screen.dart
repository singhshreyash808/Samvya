import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../mpin/create_mpin_screen.dart';

class WaitingForApprovalScreen extends StatefulWidget {
  final String requestId;

  const WaitingForApprovalScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<WaitingForApprovalScreen> createState() =>
      _WaitingForApprovalScreenState();
}

class _WaitingForApprovalScreenState
    extends State<WaitingForApprovalScreen> {

  final ApiService api = ApiService();

  Timer? timer;

  int seconds = 300;

  bool checking = false;
  int _consecutiveErrors = 0;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 5),
          (_) => checkStatus(),
    );

    startCountdown();
  }

  void startCountdown() {

    Timer.periodic(
      const Duration(seconds: 1),
          (t) {

        if (!mounted) {
          t.cancel();
          return;
        }

        if (seconds == 0) {

          t.cancel();

          timer?.cancel();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Approval request expired.",
              ),
            ),
          );

          Navigator.pop(context);

          return;
        }

        setState(() {
          seconds--;
        });

      },
    );
  }

  Future<void> checkStatus() async {

    if (checking) return;

    checking = true;

    final response = await api.checkDeviceStatus(
      widget.requestId,
    );

    checking = false;

    if (!mounted) return;

    // Handle network / server error
    if (response["success"] == false && response["approved"] == null) {
      _consecutiveErrors++;
      if (_consecutiveErrors >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Unable to reach server. Please check your connection.",
            ),
            backgroundColor: Colors.orange,
          ),
        );
        _consecutiveErrors = 0; // reset so we don't spam
      }
      return;
    }

    _consecutiveErrors = 0;

    if (response["approved"] == true) {

      timer?.cancel();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Device Approved Successfully",
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(

        context,

        MaterialPageRoute(
          builder: (_) => const CreateMpinScreen(),
        ),

            (route) => false,

      );

      return;
    }

    if (response["rejected"] == true) {

      timer?.cancel();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Login request rejected.",
          ),
        ),
      );

      Navigator.pop(context);

      return;
    }

    if (response["expired"] == true) {

      timer?.cancel();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Approval request expired.",
          ),
        ),
      );

      Navigator.pop(context);

    }

  }

  @override
  void dispose() {

    timer?.cancel();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    final minutes = (seconds ~/ 60)
        .toString()
        .padLeft(2, '0');

    final sec = (seconds % 60)
        .toString()
        .padLeft(2, '0');

    return Scaffold(

      appBar: AppBar(

        title: const Text("Waiting for Approval"),

        backgroundColor: const Color(0xFF5ED3C5),

      ),

      body: Center(

        child: Padding(

          padding: const EdgeInsets.all(24),

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              const Icon(

                Icons.phonelink_lock,

                size: 90,

                color: Color(0xFF5ED3C5),

              ),

              const SizedBox(height: 25),

              const Text(

                "Approval Required",

                style: TextStyle(

                  fontSize: 26,

                  fontWeight: FontWeight.bold,

                ),

              ),

              const SizedBox(height: 15),

              const Text(

                "A login request has been sent to your trusted device.\n\nPlease approve it to continue.",

                textAlign: TextAlign.center,

                style: TextStyle(

                  fontSize: 16,

                ),

              ),

              const SizedBox(height: 35),

              CircularProgressIndicator(),

              const SizedBox(height: 25),

              Text(

                "$minutes:$sec",

                style: const TextStyle(

                  fontSize: 28,

                  fontWeight: FontWeight.bold,

                ),

              ),

              const SizedBox(height: 10),

              const Text(

                "Waiting for approval...",

                style: TextStyle(

                  color: Colors.grey,

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}