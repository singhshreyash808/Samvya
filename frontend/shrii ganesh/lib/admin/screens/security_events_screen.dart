import 'package:flutter/material.dart';
import 'package:samvya/admin/widgets/admin_app_bar.dart';
import 'package:samvya/admin/widgets/admin_sidebar.dart';
import 'package:samvya/admin/widgets/admin_status_badge.dart';
import 'package:samvya/services/admin_api_service.dart';

class SecurityEventsScreen extends StatefulWidget {
  const SecurityEventsScreen({super.key});

  @override
  State<SecurityEventsScreen> createState() => _SecurityEventsScreenState();
}

class _SecurityEventsScreenState extends State<SecurityEventsScreen> {
  bool _isLoading = true;
  List<dynamic> _securityEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchSecurityEvents();
  }

  Future<void> _fetchSecurityEvents() async {
    setState(() => _isLoading = true);
    final res = await AdminApiService().getSecurityEvents();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res["success"] == true) {
          _securityEvents = res["security_events"] ?? [];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AdminAppBar(
        title: "Security & Authentication Stream",
        onRefresh: _fetchSecurityEvents,
      ),
      drawer: const AdminSidebar(activeRoute: "Security"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F9D8A)))
            : _securityEvents.isEmpty
                ? const Center(child: Text("No security events logged.", style: TextStyle(color: Colors.white54, fontSize: 16)))
                : ListView.separated(
                    itemCount: _securityEvents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final s = _securityEvents[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.red.withOpacity(0.15),
                              child: const Icon(Icons.security_rounded, color: Colors.redAccent),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        s["event_type"] ?? "Security Alert",
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                                      ),
                                      AdminStatusBadge(status: s["severity"] ?? "WARNING"),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(s["description"] ?? "", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                  const SizedBox(height: 8),
                                  Text(
                                    "IP: ${s['ip_address'] ?? '192.168.1.1'} | Device: ${s['device_info'] ?? 'Unknown'}",
                                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
