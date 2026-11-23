import 'package:flutter/material.dart';
import 'package:samvya/admin/widgets/admin_app_bar.dart';
import 'package:samvya/admin/widgets/admin_sidebar.dart';
import 'package:samvya/admin/widgets/admin_status_badge.dart';
import 'package:samvya/services/admin_api_service.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  bool _isLoading = true;
  List<dynamic> _requests = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    final res = await AdminApiService().getServiceRequests();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res["success"] == true) {
          _requests = res["requests"] ?? [];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AdminAppBar(
        title: "Service Requests Management",
        onRefresh: _fetchRequests,
      ),
      drawer: const AdminSidebar(activeRoute: "Requests"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F9D8A)))
            : _requests.isEmpty
                ? const Center(child: Text("No service requests pending.", style: TextStyle(color: Colors.white54, fontSize: 16)))
                : ListView.separated(
                    itemCount: _requests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final req = _requests[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  req["category"] ?? "Account Service",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                AdminStatusBadge(status: req["status"] ?? "PENDING"),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(req["description"] ?? "", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("User ID: ${req['user_id'] ?? 'N/A'}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                Text("Date: ${req['created_at']?.toString().split('T').first ?? ''}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              ],
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
