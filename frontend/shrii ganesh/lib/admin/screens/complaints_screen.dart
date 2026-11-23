import 'package:flutter/material.dart';
import 'package:samvya/admin/widgets/admin_app_bar.dart';
import 'package:samvya/admin/widgets/admin_sidebar.dart';
import 'package:samvya/admin/widgets/admin_status_badge.dart';
import 'package:samvya/admin/screens/complaint_details_screen.dart';
import 'package:samvya/services/admin_api_service.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  bool _isLoading = true;
  List<dynamic> _complaints = [];
  String _selectedStatusFilter = "ALL";

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    setState(() => _isLoading = true);
    final res = await AdminApiService().getComplaints();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res["success"] == true) {
          _complaints = res["complaints"] ?? [];
        }
      });
    }
  }

  List<dynamic> get _filteredComplaints {
    if (_selectedStatusFilter == "ALL") return _complaints;
    return _complaints.where((c) => (c["status"] ?? "").toString().toUpperCase() == _selectedStatusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AdminAppBar(
        title: "Complaint Resolution Portal",
        onRefresh: _fetchComplaints,
      ),
      drawer: const AdminSidebar(activeRoute: "Complaints"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["ALL", "OPEN", "IN_PROGRESS", "RESOLVED", "REJECTED"].map((status) {
                  final isSelected = _selectedStatusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        status.replaceAll('_', ' '),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0F9D8A),
                      backgroundColor: const Color(0xFF1E293B),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedStatusFilter = status);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Complaints List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F9D8A)))
                  : _filteredComplaints.isEmpty
                      ? const Center(
                          child: Text(
                            "No complaints found for this status.",
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filteredComplaints.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final c = _filteredComplaints[index];
                            final priority = c["priority"] ?? "MEDIUM";
                            final status = c["status"] ?? "OPEN";

                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: priority == "HIGH" ? Colors.red.withOpacity(0.4) : Colors.white10,
                                  width: 1.2,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                leading: CircleAvatar(
                                  backgroundColor: priority == "HIGH"
                                      ? Colors.red.withOpacity(0.2)
                                      : const Color(0xFF0F9D8A).withOpacity(0.2),
                                  child: Icon(
                                    Icons.report_problem_rounded,
                                    color: priority == "HIGH" ? Colors.redAccent : const Color(0xFF0F9D8A),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        c["title"] ?? "Complaint",
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    AdminStatusBadge(status: status),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c["description"] ?? "",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Text("User: ${c['user_id'] ?? 'U1001'}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                          const SizedBox(width: 12),
                                          if (c["amount"] != null)
                                            Text("Amount: ₹${c['amount']}", style: const TextStyle(color: Color(0xFF0F9D8A), fontWeight: FontWeight.bold, fontSize: 11)),
                                          const Spacer(),
                                          AdminStatusBadge(status: "PRIORITY: $priority"),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => ComplaintDetailsScreen(complaint: c)),
                                  );
                                  _fetchComplaints();
                                },
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
