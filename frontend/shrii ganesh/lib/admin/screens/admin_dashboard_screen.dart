import 'package:flutter/material.dart';
import 'package:samvya/admin/widgets/admin_app_bar.dart';
import 'package:samvya/admin/widgets/admin_sidebar.dart';
import 'package:samvya/admin/widgets/dashboard_stat_card.dart';
import 'package:samvya/admin/widgets/admin_status_badge.dart';
import 'package:samvya/admin/screens/users_screen.dart';
import 'package:samvya/admin/screens/transactions_screen.dart';
import 'package:samvya/admin/screens/complaints_screen.dart';
import 'package:samvya/admin/screens/risk_dashboard_screen.dart';
import 'package:samvya/admin/screens/security_events_screen.dart';
import 'package:samvya/services/admin_api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<dynamic> _recentTxns = [];
  List<dynamic> _recentSecurity = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final data = await AdminApiService().getDashboard();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (data["success"] == true) {
          _stats = data["stats"] ?? {};
          _recentTxns = data["recent_transactions"] ?? [];
          _recentSecurity = data["recent_security"] ?? [];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AdminAppBar(
        title: "Admin Executive Dashboard",
        onRefresh: _loadDashboardData,
      ),
      drawer: const AdminSidebar(activeRoute: "Dashboard"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F9D8A)))
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: const Color(0xFF0F9D8A),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Banner
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF063B34), Color(0xFF0A6E61), Color(0xFF0F9D8A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F9D8A).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Welcome to SAMVYA Admin Portal 👋",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Real-time overview of users, transactions, isolation-forest risk, complaints, and security audit logs.",
                                  style: TextStyle(fontSize: 13, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 36),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Metrics Grid (Responsive Layout)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 2);
                        double childAspectRatio = constraints.maxWidth > 600 ? 1.4 : 1.25;

                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: childAspectRatio,
                          children: [
                            DashboardStatCard(
                              title: "Total Users",
                              value: "${_stats['total_users'] ?? 0}",
                              icon: Icons.people_alt_rounded,
                              color: const Color(0xFF3B82F6),
                              subtitle: "${_stats['active_users'] ?? 0} Active Users",
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersScreen())),
                            ),
                            DashboardStatCard(
                              title: "Total Transactions",
                              value: "${_stats['total_transactions'] ?? 0}",
                              icon: Icons.receipt_long_rounded,
                              color: const Color(0xFF10B981),
                              subtitle: "${_stats['successful_transactions'] ?? 0} Success | ${_stats['failed_transactions'] ?? 0} Failed",
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen())),
                            ),
                            DashboardStatCard(
                              title: "Pending Complaints",
                              value: "${_stats['pending_complaints'] ?? 0}",
                              icon: Icons.report_problem_rounded,
                              color: const Color(0xFFF59E0B),
                              subtitle: "Requires Resolution",
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintsScreen())),
                            ),
                            DashboardStatCard(
                              title: "High-Risk Events",
                              value: "${_stats['high_risk_events'] ?? 0}",
                              icon: Icons.warning_rounded,
                              color: const Color(0xFFEF4444),
                              subtitle: "Flagged by ML Risk Model",
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RiskDashboardScreen())),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),

                    // Section 1: Recent Transactions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Recent Transactions",
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen())),
                          icon: const Text("View All", style: TextStyle(color: Color(0xFF0F9D8A))),
                          label: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF0F9D8A), size: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: _recentTxns.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: Text("No transactions recorded yet.", style: TextStyle(color: Colors.white54))),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _recentTxns.length,
                              separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
                              itemBuilder: (context, index) {
                                final txn = _recentTxns[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF0F9D8A).withOpacity(0.15),
                                    child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF0F9D8A)),
                                  ),
                                  title: Text(
                                    txn["recipient"] ?? "Transfer",
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    "Txn ID: ${txn['id']?.toString().substring(0, 8) ?? 'N/A'}",
                                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "₹${txn['amount'] ?? 0.0}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      AdminStatusBadge(status: txn["status"] ?? "PENDING"),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 28),

                    // Section 2: Security & Alert Stream
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Security & System Alerts",
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityEventsScreen())),
                          icon: const Text("Security Log", style: TextStyle(color: Color(0xFF0F9D8A))),
                          label: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF0F9D8A), size: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: _recentSecurity.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: Text("No security events recorded.", style: TextStyle(color: Colors.white54))),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _recentSecurity.length,
                              separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
                              itemBuilder: (context, index) {
                                final sec = _recentSecurity[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.red.withOpacity(0.15),
                                    child: const Icon(Icons.security_rounded, color: Colors.redAccent),
                                  ),
                                  title: Text(
                                    sec["event_type"] ?? "Security Alert",
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    sec["description"] ?? "",
                                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                                  ),
                                  trailing: AdminStatusBadge(status: sec["severity"] ?? "WARNING"),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
