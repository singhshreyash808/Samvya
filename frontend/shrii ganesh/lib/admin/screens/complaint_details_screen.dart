import 'package:flutter/material.dart';
import 'package:samvya/admin/widgets/admin_status_badge.dart';
import 'package:samvya/services/admin_api_service.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> complaint;

  const ComplaintDetailsScreen({super.key, required this.complaint});

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  late String _currentStatus;
  late String _currentPriority;
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.complaint["status"] ?? "OPEN";
    _currentPriority = widget.complaint["priority"] ?? "MEDIUM";
    _notesController.text = widget.complaint["internal_notes"] ?? "";
  }

  Future<void> _updateComplaint() async {
    setState(() => _isSaving = true);
    final res = await AdminApiService().updateComplaint(
      widget.complaint["id"],
      {
        "status": _currentStatus,
        "priority": _currentPriority,
        "internal_notes": _notesController.text.trim(),
      },
    );
    setState(() => _isSaving = false);

    if (mounted) {
      if (res["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Complaint updated successfully"), backgroundColor: Color(0xFF0F9D8A)),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["detail"] ?? "Update failed"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Text("Complaint #${widget.complaint['id']?.toString().substring(0, 8) ?? ''}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF0F9D8A).withOpacity(0.3), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AdminStatusBadge(status: _currentStatus),
                      AdminStatusBadge(status: "PRIORITY: $_currentPriority"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.complaint["title"] ?? "Customer Complaint",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.complaint["description"] ?? "",
                    style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  if (widget.complaint["amount"] != null)
                    Text(
                      "Claimed Amount: ₹${widget.complaint['amount']}",
                      style: const TextStyle(color: Color(0xFF0F9D8A), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action & Status Controls
            const Text("Update Status & Investigation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Status Workflow", style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _currentStatus,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: ["OPEN", "IN_PROGRESS", "RESOLVED", "REJECTED"].map((s) {
                      return DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' ')));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _currentStatus = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text("Priority Level", style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _currentPriority,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: ["LOW", "MEDIUM", "HIGH"].map((p) {
                      return DropdownMenuItem(value: p, child: Text(p));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _currentPriority = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text("Internal Notes / Investigation Remark", style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Add notes for internal auditing and resolution history...",
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _updateComplaint,
                      icon: _isSaving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.save_rounded),
                      label: const Text("Save & Update Complaint", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F9D8A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
