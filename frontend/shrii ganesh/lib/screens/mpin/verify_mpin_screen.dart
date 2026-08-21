import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';
import '../../services/biometric_service.dart';
import '../auth/register_screen.dart';
import '../dashboard/main_dashboard.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/voice_assistant_service.dart';
import 'face_verify_screen.dart';

class VerifyMpinScreen extends StatefulWidget {
  const VerifyMpinScreen({super.key});

  @override
  State<VerifyMpinScreen> createState() => _VerifyMpinScreenState();
}

class _VerifyMpinScreenState extends State<VerifyMpinScreen> {

  final TextEditingController mpinController = TextEditingController();
  final VoiceAssistantService _voiceService = VoiceAssistantService();

  @override
  void initState() {
    super.initState();
    biometricLogin();

    // Play voice prompt after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _voiceService.speak(
          "voice.enter_mpin".tr(),
          languageCode: VoiceAssistantService.getLanguageCode(context.locale),
        );
      }
    });
  }

  Future<void> biometricLogin() async {
    bool enabled = await LocalStorageService.getBiometric();
    if (!enabled) return;

    DateTime? blockUntil = await LocalStorageService.getBlockUntil();
    if (blockUntil != null && DateTime.now().isBefore(blockUntil)) {
      if (!mounted) return;
      int remainingMinutes = blockUntil.difference(DateTime.now()).inMinutes;
      int remainingSeconds = blockUntil.difference(DateTime.now()).inSeconds % 60;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Too many failed attempts. Try again in $remainingMinutes m $remainingSeconds s."),
        ),
      );
      return;
    }

    bool success = await BiometricService.authenticate();
    if (!mounted) return;

    if (success) {
      await LocalStorageService.resetFailedAttempts();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainDashboard()),
      );
    } else {
      await LocalStorageService.incrementFailedAttempts();
      int attempts = await LocalStorageService.getFailedAttempts();
      if (!mounted) return;

      if (attempts >= 3) {
        _showLockoutOptionsDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Fingerprint unrecognized. ${3 - attempts} attempts left."),
          ),
        );
      }
    }
  }

  Future<void> verifyMpin() async {
    DateTime? blockUntil = await LocalStorageService.getBlockUntil();
    if (blockUntil != null && DateTime.now().isBefore(blockUntil)) {
      if (!mounted) return;
      int remainingMinutes = blockUntil.difference(DateTime.now()).inMinutes;
      int remainingSeconds = blockUntil.difference(DateTime.now()).inSeconds % 60;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Too many failed attempts. Try again in $remainingMinutes m $remainingSeconds s."),
        ),
      );
      return;
    }

    String? savedMpin = await LocalStorageService.getMPIN();

    if (savedMpin == mpinController.text.trim()) {
      await LocalStorageService.resetFailedAttempts();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainDashboard()),
      );
    } else {
      await LocalStorageService.incrementFailedAttempts();
      int attempts = await LocalStorageService.getFailedAttempts();
      if (!mounted) return;

      if (attempts >= 3) {
        _showLockoutOptionsDialog();
      } else {
        _voiceService.speak(
          "voice.incorrect_mpin".tr(),
          languageCode: VoiceAssistantService.getLanguageCode(context.locale),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Incorrect MPIN. ${3 - attempts} attempts left."),
          ),
        );
      }
    }
  }

  void _showLockoutOptionsDialog() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                "mpin.too_many_attempts_title".tr(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "mpin.too_many_attempts_msg".tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const FaceVerifyScreen()));
                  },
                  icon: const Icon(Icons.face, color: Colors.white),
                  label: Text("mpin.verify_face".tr(), style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0F9D8A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await LocalStorageService.setBlockUntil(
                      DateTime.now().add(const Duration(minutes: 5)),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("You are blocked for 5 minutes.")),
                      );
                    }
                  },
                  icon: const Icon(Icons.timer),
                  label: Text("mpin.wait_time".tr()),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> languages = [
      {'code': 'en', 'label': 'EN'},
      {'code': 'hi', 'label': 'HI'},
      {'code': 'or', 'label': 'OR'},
      {'code': 'ta', 'label': 'TA'},
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F9D8A).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF0F9D8A).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language, color: Color(0xFF0F9D8A), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    context.locale.languageCode.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF0F9D8A),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Color(0xFF0F9D8A), size: 18),
                ],
              ),
            ),
            onSelected: (String code) async {
              await context.setLocale(Locale(code));
            },
            itemBuilder: (BuildContext ctx) => languages.map((lang) {
              final bool isActive = context.locale.languageCode == lang['code'];
              return PopupMenuItem<String>(
                value: lang['code'],
                child: Row(
                  children: [
                    if (isActive)
                      const Icon(Icons.check, color: Color(0xFF0F9D8A), size: 16)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(
                      lang['label']!,
                      style: TextStyle(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? const Color(0xFF0F9D8A) : Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 45,
                backgroundColor: Color(0xff0F9D8A),
                child: Icon(Icons.lock, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                "mpin.welcome_back".tr(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "mpin.enter_mpin_hint".tr(),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 35),
              TextField(
                controller: mpinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 25, letterSpacing: 12),
                decoration: InputDecoration(
                  hintText: "••••",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0F9D8A),
                  ),
                  onPressed: verifyMpin,
                  child: Text(
                    "mpin.login".tr(),
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              IconButton(
                onPressed: biometricLogin,
                icon: const Icon(Icons.fingerprint, size: 60, color: Color(0xff0F9D8A)),
              ),
              Text(
                "mpin.login_fingerprint".tr(),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Forgot MPIN Coming Soon")),
                  );
                },
                child: Text("mpin.forgot_mpin".tr()),
              ),
              const Divider(),
              const SizedBox(height: 10),
              Text(
                "mpin.new_user".tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: Text("mpin.register_here".tr()),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    mpinController.dispose();
    super.dispose();
  }
}