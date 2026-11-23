import 'package:flutter/material.dart';
import 'package:samvya/admin/screens/admin_dashboard_screen.dart';
import 'package:samvya/admin/screens/users_screen.dart';
import 'package:samvya/admin/screens/transactions_screen.dart';
import 'package:samvya/admin/screens/complaints_screen.dart';
import 'package:samvya/admin/screens/requests_screen.dart';
import 'package:samvya/admin/screens/risk_dashboard_screen.dart';
import 'package:samvya/admin/screens/security_events_screen.dart';
import 'package:samvya/admin/screens/audit_logs_screen.dart';
import 'package:samvya/admin/screens/admin_management_screen.dart';
import 'package:samvya/admin/screens/admin_settings_screen.dart';
import 'package:samvya/screens/portal_selection_screen.dart';
import 'package:samvya/services/admin_api_service.dart';

class AdminSidebar extends StatelessWidget {
  final String activeRoute;

  const AdminSidebar({super.key, required this.activeRoute});

  void _navigate(BuildContext context, String routeName, Widget targetScreen) {
    if (activeRoute == routeName) {
      if (Scaffold.of(context).isDrawerOpen) {
        Navigator.pop(context);
      }
      return;
    }

    if (Scaffold.of(context).isDrawerOpen) {
      Navigator.pop(context);
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      height: double.infinity,
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          // Sidebar Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F9D8A).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shield_outlined, color: Color(0xFF0F9D8A), size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SAMVYA",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      "Admin Portal MVP",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF0F9D8A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _buildMenuItem(
                  context,
                  title: "Dashboard",
                  icon: Icons.grid_view_rounded,
                  routeName: "Dashboard",
                  targetScreen: const AdminDashboardScreen(),
                ),
                _buildMenuItem(
                  context,
                  title: "User Management",
                  icon: Icons.people_alt_rounded,
                  routeName: "Users",
                  targetScreen: const UsersScreen(),
                ),
                _buildMenuItem(
                  context,
                  title: "Transactions",
                  icon: Icons.account_balance_wallet_rounded,
                  routeName: "Transactions",
                  targetScreen: const TransactionsScreen(),
                ),
                _buildMenuItem(
                  context,
                  title: "Complaints",
                  icon: Icons.report_problem_rounded,
                  routeName: "Complaints",
                  targetScreen: const ComplaintsScreen(),
                ),
                _buildMenuItem(
                  context,
                  title: "Service Requests",
                  icon: Icons.assignment_rounded,
                  routeName: "Requests",
                  targetScreen: const RequestsScreen(),
                ),
                _buildMenuItem(
                  context,
                  title: "Risk & Fraud",
                  icon: Icons.warning_rounded,
                  routeName: "Risk",
                  targetScreen: const RiskDashboardScreen(),
                ),
                _buildMenuItem(
                  context,
                  title: "Security Events",
                  icon: Icons.security_rounded,
                  routeName: "Security",
                  targetScreen: const SecurityEventsScreen(),
                ),
                _buildMenuItem(
                  context,
                  title: "Audit Logs",
                  icon: Icons.history_edu_rounded,
                  routeName: "AuditLogs",
                  targetScreen: const AuditLogsScreen(),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Color(0xFF1E293B)),
                ),
                _buildMenuItem(
                  context,
                  title: "Admins & Roles",
                  icon: Icons.admin_panel_settings_rounded,
                  routeName: "Admins",
                  targetScreen: const AdminManagementScreen(),
                ),
                _buildMenuItem(
                  context,
                  title: "Settings & Profile",
                  icon: Icons.settings_rounded,
                  routeName: "Settings",
                  targetScreen: const AdminSettingsScreen(),
                ),
              ],
            ),
          ),

          // Bottom Logout / Switch Portal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const PortalSelectionScreen()),
                      (route) => false,
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.swap_horiz_rounded, color: Colors.white70, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Switch Portal",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    await AdminApiService().logout();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const PortalSelectionScreen()),
                      (route) => false,
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Admin Logout",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String routeName,
    required Widget targetScreen,
  }) {
    final isActive = activeRoute == routeName;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigate(context, routeName, targetScreen),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF0F9D8A).withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isActive
                  ? Border.all(color: const Color(0xFF0F9D8A).withOpacity(0.5), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? const Color(0xFF0F9D8A) : Colors.white60,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive ? Colors.white : Colors.white70,
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
