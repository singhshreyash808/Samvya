import 'package:flutter/material.dart';
import 'package:samvya/admin/widgets/admin_app_bar.dart';
import 'package:samvya/admin/widgets/admin_sidebar.dart';
import 'package:samvya/services/admin_api_service.dart';
import 'package:samvya/screens/portal_selection_screen.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  String _adminName = "Super Admin";
  String _adminRole = "SUPER_ADMIN";

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
  }

  Future<void> _loadAdminInfo() async {
    final name = await AdminApiService().getAdminName();
    final role = await AdminApiService().getAdminRole();
    if (mounted) {
      setState(() {
        _adminName = name ?? "Super Admin";
        _adminRole = role ?? "SUPER_ADMIN";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: const AdminAppBar(title: "Admin Settings & Configuration"),
      drawer: const AdminSidebar(activeRoute: "Settings"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Profile Overview Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF0F9D8A).withOpacity(0.3), width: 1.2),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF0F9D8A),
                    child: Text(
                      _adminName.isNotEmpty ? _adminName[0].toUpperCase() : "A",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _adminName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Role: $_adminRole",
                          style: const TextStyle(fontSize: 13, color: Color(0xFF0F9D8A), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text("System Environment & Database", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _buildSettingRow("Backend Engine", "FastAPI (Python 3.11)"),
                  const Divider(color: Colors.white10),
                  _buildSettingRow("Database System", "PostgreSQL (Relational Storage)"),
                  const Divider(color: Colors.white10),
                  _buildSettingRow("Authentication", "JWT (JSON Web Tokens) with RBAC"),
                  const Divider(color: Colors.white10),
                  _buildSettingRow("ML Risk Model", "Isolation Forest Anomaly Classifier"),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await AdminApiService().logout();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const PortalSelectionScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text("LOGOUT OF ADMIN PORTAL", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          Text(subtitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
