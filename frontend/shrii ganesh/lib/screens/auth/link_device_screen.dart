import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:samvya/screens/mpin/verify_mpin_screen.dart';
import 'package:samvya/screens/dashboard/main_dashboard.dart';

import '../../services/api_service.dart';
import '../../services/device_service.dart';
import '../../services/local_storage_service.dart';
import '../mpin/create_mpin_screen.dart';
import 'waiting_for_approval_screen.dart';

class LinkDeviceScreen extends StatefulWidget {
  const LinkDeviceScreen({super.key});

  @override
  State<LinkDeviceScreen> createState() => _LinkDeviceScreenState();
}

class _LinkDeviceScreenState extends State<LinkDeviceScreen> {
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  final ApiService apiService = ApiService();

  @override
  void dispose() {
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Link New Device"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F9D8A).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.phonelink_setup,
                          size: 64,
                          color: Color(0xFF0F9D8A),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Link Device",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF063B34),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Login to link this new device to your account",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: "auth.mobile_number".tr(),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: "auth.password".tr(),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      setState(() => _isLoading = true);
                      FocusScope.of(context).unfocus();
                      final device = await DeviceService.getDeviceInfo();
                      final response = await apiService.login({
                        "mobile": mobileController.text.trim(),
                        "password": passwordController.text.trim(),
                        "device": device,
                      });
                      setState(() => _isLoading = false);
                      if (!mounted) return;
                      if (response["device_status"] == "pending") {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => WaitingForApprovalScreen(requestId: response["request_id"])));
                        return;
                      }
                      
                      if (response["success"] == true) {
                        String? savedMpin = await LocalStorageService.getMPIN();
                        if (savedMpin == null) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CreateMpinScreen()));
                        } else {
                          if (response["is_primary"] == true) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainDashboard()));
                          } else {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const VerifyMpinScreen()));
                          }
                        }
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response["message"] ?? "Failed to link device")));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5ED3C5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Link Device",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
