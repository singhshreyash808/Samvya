import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:samvya/screens/profile/contact_us_screen.dart';
import 'package:samvya/screens/profile/my_profile_screen.dart';
import '../auth/login_screen.dart';
import '../profile/my_account_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    String userName = user?.email?.split("@")[0] ?? "User";

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
                    Image.asset(
                      "assets/icons/logo.png",
                      height: 90,
                    ),
                    const SizedBox(height: 15),
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
                      "Welcome, $userName 👋",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.email ?? "",
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ACCOUNT CARD
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                    )
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account Number",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "XXXX XXXX 5678",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    Text(
                      "Available Balance",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "₹25,000",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _menuTile(
                context,
                Icons.person,
                "My Profile",
                const MyProfileScreen(),
              ),

              _menuTile(
                context,
                Icons.account_balance,
                "My Account",
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
                  title: const Text("Settings"),
                  children: const [
                    ListTile(
                      leading: Icon(Icons.lock),
                      title: Text("Change MPIN"),
                    ),
                    ListTile(
                      leading: Icon(Icons.fingerprint),
                      title: Text("Face ID / Touch ID"),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone_android),
                      title: Text("Device ID"),
                    ),
                    ListTile(
                      leading: Icon(Icons.info),
                      title: Text("App Version"),
                      subtitle: Text("v1.0.0"),
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
                  title: const Text("Service Requests"),
                  children: const [
                    ListTile(
                      leading: Icon(Icons.download),
                      title: Text("Download Account Statement"),
                    ),
                    ListTile(
                      leading: Icon(Icons.verified_user),
                      title: Text("Re-KYC"),
                    ),
                    ListTile(
                      leading: Icon(Icons.edit),
                      title: Text("Update Profile"),
                    ),
                    ListTile(
                      leading: Icon(Icons.receipt_long),
                      title: Text("Generate Interest Certificate"),
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
                  title: const Text("About Samvya"),
                  children: const [
                    ListTile(
                      leading: Icon(Icons.description),
                      title: Text("Terms & Conditions"),
                    ),
                    ListTile(
                      leading: Icon(Icons.privacy_tip),
                      title: Text("Privacy Policy"),
                    ),
                  ],
                ),
              ),

              _menuTile(
                context,
                Icons.contact_phone,
                "Contact Us",
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
                    label: const Text(
                      "Logout",
                      style: TextStyle(
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
                            title: const Text("Logout"),
                            content: const Text(
                              "Are you sure you want to logout?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text("Logout"),
                              ),
                            ],
                          );
                        },
                      );

                      if (logout == true) {
                        await FirebaseAuth.instance.signOut();

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

  // FIXED: Added BuildContext, targetScreen parameter, and an onTap navigation listener
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