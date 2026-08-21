import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:samvya/screens/profile/contact_us_screen.dart';
import 'package:samvya/screens/profile/my_profile_screen.dart';
import '../auth/login_screen.dart';
import '../profile/my_account_screen.dart';
import '../profile/setting_screen.dart';
import '../profile/service_request_screen.dart';
import '../profile/change_mpin_screen.dart';
import '../../services/biometric_service.dart';
import '../../services/local_storage_service.dart';
import '../devices/connected_devices_screen.dart';
import '../../utils/session_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:samvya/screens/profile/language_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool biometricEnabled = false;
  String userName = "User";
  String userMobile = "";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    loadBiometric();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    try {
      final name = await LocalStorageService.getName();
      final mobile = await LocalStorageService.getMobile();
      final email = await LocalStorageService.getEmail();
      if (mounted) {
        setState(() {
          userName = name.isNotEmpty ? name : "User";
          userMobile = mobile;
          userEmail = email;
        });
      }
    } catch (e) {
      debugPrint("Error loading user info: $e");
    }
  }

  Future<void> loadBiometric() async {
    // Wrapped in a try-catch block to prevent unhandled crashes if local storage fails
    try {
      bool status = await LocalStorageService.getBiometric();
      setState(() {
        biometricEnabled = status;
      });
    } catch (e) {
      debugPrint("Error loading biometric status: $e");
    }
  }

  // Handle toggle logic for biometric switch
  Future<void> toggleBiometric(bool value) async {
    setState(() {
      biometricEnabled = value;
    });
    try {
      LocalStorageService.saveBiometric(value);
    } catch (e) {
      debugPrint("Error saving biometric status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0F9D8A),
                      Color(0xFF5ED3C5),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(
                        userName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "profile.welcome".tr(namedArgs: {"name": userName}),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (userMobile.isNotEmpty)
                      Text(
                        userMobile,
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    if (userEmail.isNotEmpty)
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SESSION TIMER CARD
              ValueListenableBuilder<int>(
                valueListenable: SessionManager().remainingSeconds,
                builder: (context, remaining, child) {
                  final minutes = (remaining / 60).floor().toString().padLeft(2, '0');
                  final seconds = (remaining % 60).toString().padLeft(2, '0');
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer, color: Colors.orange),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            "profile.session_expires_in".tr(),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "$minutes:$seconds",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              _menuTile(
                context,
                Icons.person,
                "profile.my_profile".tr(),
                const MyProfileScreen(),
              ),

              _menuTile(
                context,
                Icons.account_balance,
                "profile.my_account".tr(),
                const MyAccountScreen(),
              ),

              Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: ExpansionTile(
                  leading: const Icon(
                    Icons.settings,
                    color: Color(0xFF0F9D8A),
                  ),
                  title: Text("profile.settings".tr()),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text("profile.app_language".tr()),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LanguageScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: Text("profile.change_mpin".tr()),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangeMpinScreen(),
                          ),
                        );
                      },
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.fingerprint),
                      title: Text("profile.enable_biometric".tr()),
                      value: biometricEnabled,

                      onChanged: (value) async {

                        bool success =
                        await BiometricService.authenticate();

                        if (success) {

                          setState(() {
                            biometricEnabled = value;
                          });

                          await LocalStorageService.saveBiometric(value);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value
                                    ? "Biometric Enabled"
                                    : "Biometric Disabled",
                              ),
                            ),
                          );

                        } else {

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Authentication Failed",
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone_android),
                      title: Text("profile.device_id".tr()),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ConnectedDevicesScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: Text("profile.app_version".tr()),
                      subtitle: const Text("v1.0.0"),
                    ),
                  ],
                ),
              ),

              Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: ExpansionTile(
                  leading: const Icon(
                    Icons.miscellaneous_services,
                    color: Color(0xFF0F9D8A),
                  ),
                  title: Text("profile.service_requests".tr()),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: Text("profile.download_statement".tr()),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ServiceRequestScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.verified_user),
                      title: Text("profile.re_kyc".tr()),
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: Text("profile.update_profile".tr()),
                    ),
                    ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text("profile.interest_certificate".tr()),
                    ),
                  ],
                ),
              ),

              Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: ExpansionTile(
                  leading: const Icon(
                    Icons.info,
                    color: Color(0xFF0F9D8A),
                  ),
                  title: Text("profile.about_samvya".tr()),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: Text("profile.terms_conditions".tr()),
                    ),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: Text("profile.privacy_policy".tr()),
                    ),
                  ],
                ),
              ),

              _menuTile(
                context,
                Icons.contact_phone,
                "profile.contact_us".tr(),
                const ContactUsScreen(),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: Text(
                      "profile.logout".tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ),
                    ),
                    onPressed: () async {
                      bool? logout = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("profile.logout_confirm_title".tr()),
                            content: Text("profile.logout_confirm_msg".tr()),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: Text("profile.cancel".tr()),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: Text("profile.logout".tr()),
                              ),
                            ],
                          );
                        },
                      );

                      if (logout == true) {
                        await ApiService().logout();

                        if (!context.mounted) return;

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                              (route) => false,
                        );
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _menuTile(
      BuildContext context,
      IconData icon,
      String title,
      Widget targetScreen,
      ) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFF0F9D8A),
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        },
      ),
    );
  }
}