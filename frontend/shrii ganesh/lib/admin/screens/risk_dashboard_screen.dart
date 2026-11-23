import 'package:flutter/material.dart';
import 'package:samvya/admin/widgets/admin_app_bar.dart';
import 'package:samvya/admin/widgets/admin_sidebar.dart';
import 'package:samvya/admin/widgets/admin_status_badge.dart';
import 'package:samvya/services/admin_api_service.dart';

class RiskDashboardScreen extends StatefulWidget {
  const RiskDashboardScreen({super.key});

  @override
  State<RiskDashboardScreen> createState() => _RiskDashboardScreenState();
}

class _RiskDashboardScreenState extends State<RiskDashboardScreen> {
  bool _isLoading = true;
  List<dynamic> _riskEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchRiskEvents();
  }

  Future<void> _fetchRiskEvents() async {
    setState(() => _isLoading = true);
    final res = await AdminApiService().getRiskEvents();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res["success"] == true) {
          _riskEvents = res["risk_events"] ?? [];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AdminAppBar(
        title: "Isolation Forest Risk & Fraud Portal",
        onRefresh: _fetchRiskEvents,
      ),
      drawer: const AdminSidebar(activeRoute: "Risk"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ML Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.psychology_rounded, color: Colors.redAccent, size: 32),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Isolation Forest Fraud Detection Engine",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Monitors transactions for behavioral anomalies, rapid multi-account transfers, and location mismatches.",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text("Flagged Suspicious Activity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F9D8A)))
                  : _riskEvents.isEmpty
                      ? const Center(child: Text("No high-risk transactions detected.", style: TextStyle(color: Colors.white54, fontSize: 16)))
                      : ListView.separated(
                          itemCount: _riskEvents.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final event = _riskEvents[index];
                            final level = event["risk_level"] ?? "HIGH";
                            final score = event["risk_score"] ?? 0.85;

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: level == "HIGH" ? Colors.red.withOpacity(0.5) : Colors.amber.withOpacity(0.5)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            color: level == "HIGH" ? Colors.redAccent : Colors.amberAccent,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Txn Ref: ${event['transaction_id'] ?? 'TXN_FLAGGED'}",
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                                          ),
                                        ],
                                      ),
                                      AdminStatusBadge(status: "RISK LEVEL: $level"),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    event["reason"] ?? "Anomaly detected by AI classifier",
                                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Anomaly Score: ${(score * 100).toStringAsFixed(1)}%",
                                        style: TextStyle(
                                          color: level == "HIGH" ? Colors.redAccent : Colors.amberAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        "User ID: ${event['user_id'] ?? 'U1042'}",
                                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
