import 'package:flutter/material.dart';
import 'package:samvya/admin/widgets/admin_app_bar.dart';
import 'package:samvya/admin/widgets/admin_sidebar.dart';
import 'package:samvya/admin/widgets/admin_status_badge.dart';
import 'package:samvya/services/admin_api_service.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  bool _isLoading = true;
  List<dynamic> _auditLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchAuditLogs();
  }

  Future<void> _fetchAuditLogs() async {
    setState(() => _isLoading = true);
    final res = await AdminApiService().getAuditLogs();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res["success"] == true) {
          _auditLogs = res["audit_logs"] ?? [];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AdminAppBar(
        title: "Immutable Audit Trail Logs",
        onRefresh: _fetchAuditLogs,
      ),
      drawer: const AdminSidebar(activeRoute: "AuditLogs"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F9D8A).withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0F9D8A).withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.history_edu_rounded, color: Color(0xFF0F9D8A), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Algorand-compatible immutable audit logs. Tracks every admin action, resource modification, and system query.",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F9D8A)))
                  : _auditLogs.isEmpty
                      ? const Center(child: Text("No audit logs recorded.", style: TextStyle(color: Colors.white54, fontSize: 16)))
                      : ListView.separated(
                          itemCount: _auditLogs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final log = _auditLogs[index];
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color(0xFF0F9D8A).withOpacity(0.2),
                                    child: const Icon(Icons.assignment_ind_rounded, color: Color(0xFF0F9D8A), size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              log["admin_name"] ?? "Admin",
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.white12,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                log["action"] ?? "ACTION",
                                                style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Resource: ${log['resource'] ?? ''} ${log['details'] != null ? '| ' + log['details'] : ''}",
                                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AdminStatusBadge(status: log["result"] ?? "SUCCESS"),
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
