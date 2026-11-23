import 'package:flutter/material.dart';
import 'package:samvya/screens/welcome/welcome_screen.dart';
import 'package:samvya/admin/screens/admin_login_screen.dart';
import 'package:samvya/services/local_storage_service.dart';
import 'package:samvya/screens/mpin/verify_mpin_screen.dart';

class PortalSelectionScreen extends StatelessWidget {
  const PortalSelectionScreen({super.key});

  Future<void> _navigateToCustomerApp(BuildContext context) async {
    bool registered = await LocalStorageService.isRegistered();
    if (!context.mounted) return;
    if (registered) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VerifyMpinScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  void _navigateToAdminPortal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF042722),
              Color(0xFF063B34),
              Color(0xFF0A6E61),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Logo Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Image.asset(
                    "assets/icons/logo samvya.png",
                    height: 80,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "SAMVYA",
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  "Select Application Portal to Continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                // Option 1: Customer Banking App
                _buildPortalCard(
                  context,
                  title: "Customer Banking App",
                  subtitle: "Access personal accounts, money transfers, audio assistant & government schemes",
                  icon: Icons.person_rounded,
                  badgeText: "Mobile Portal",
                  gradientColors: [const Color(0xFF0F9D8A), const Color(0xFF0A6E61)],
                  onTap: () => _navigateToCustomerApp(context),
                ),

                const SizedBox(height: 20),

                // Option 2: Admin Portal
                _buildPortalCard(
                  context,
                  title: "Admin Portal",
                  subtitle: "Operations, User management, Complaints, Risk & Security Monitoring, Audit logs",
                  icon: Icons.admin_panel_settings_rounded,
                  badgeText: "Admin Portal",
                  gradientColors: [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                  borderColor: const Color(0xFF0F9D8A).withOpacity(0.6),
                  onTap: () => _navigateToAdminPortal(context),
                ),

                const Spacer(),

                const Text(
                  "Powered by SAMVYA FastAPI Core Banking System",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortalCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
    required List<Color> gradientColors,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F9D8A).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF0F9D8A), width: 0.8),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
