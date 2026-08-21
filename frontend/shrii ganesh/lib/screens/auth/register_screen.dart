import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/api_service.dart';
import '../../services/device_service.dart';
import '../../services/local_storage_service.dart';
import '../auth/dpdpa_consent_screen.dart';
import '../profile/language_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final nameController = TextEditingController();

  final mobileController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController =
  TextEditingController();

  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("auth.register_title".tr()),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // ── Language Picker ──────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.language, size: 18, color: Color(0xFF0F9D8A)),
                const SizedBox(width: 6),
                const Text('Language:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(width: 8),
                ...[('EN','en'),('हिं','hi'),('ଓଡ଼','or'),('தமி','ta')].map((lang) {
                  final isActive = context.locale.languageCode == lang.$2;
                  return GestureDetector(
                    onTap: () async => await context.setLocale(Locale(lang.$2)),
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF0F9D8A) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        lang.$1,
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.black87,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "auth.full_name".tr(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "auth.mobile_number".tr(),
                prefixIcon: const Icon(Icons.phone),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "auth.email".tr(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "auth.password".tr(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "auth.confirm_password".tr(),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(

              onPressed: () async {

                if (nameController.text.trim().isEmpty ||
                    mobileController.text.trim().isEmpty ||
                    passwordController.text.trim().isEmpty) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill all required fields"),
                    ),
                  );

                  return;
                }

                if (passwordController.text !=
                    confirmPasswordController.text) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Passwords do not match"),
                    ),
                  );

                  return;
                }

                final device = await DeviceService.getDeviceInfo();

                // Send null for empty email — backend accepts Optional[EmailStr]
                // Empty string "" would fail Pydantic EmailStr validation
                final emailValue = emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim();

                final response = await apiService.register({

                  "full_name": nameController.text.trim(),

                  "mobile": mobileController.text.trim(),

                  "email": emailValue,

                  "password": passwordController.text.trim(),

                  "device": device,

                });

                if (!mounted) return;

                if (response["success"] == true) {

                  await LocalStorageService.saveUser(

                    name: nameController.text.trim(),

                    mobile: mobileController.text.trim(),

                    email: emailController.text.trim(),

                  );

                  ScaffoldMessenger.of(context).showSnackBar(

                    const SnackBar(

                      content: Text("Registration Successful"),

                    ),

                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DpdpaConsentScreen(),
                    ),
                  );

                } else {

                  ScaffoldMessenger.of(context).showSnackBar(

                    SnackBar(

                      content: Text(
                        response["message"]?.toString() ??
                            "Registration failed. Please try again.",
                      ),

                    ),

                  );

                }
              },
              child: Text("auth.create_account".tr()),
            ),

            const SizedBox(height: 20),
            
            const Divider(),
            const SizedBox(height: 10),

            Text(
              "auth.already_have_account".tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              child: Text("auth.login_here".tr()),
            ),

          ],
        ),
      ),
    );
  }

  @override
  void dispose() {

    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

}