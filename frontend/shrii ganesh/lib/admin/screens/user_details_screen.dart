import 'package:flutter/material.dart';
import 'package:samvya/admin/widgets/admin_status_badge.dart';

class UserDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isActive = user["is_active"] ?? true;
    final isVerified = user["is_verified"] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text("User Profile Overview", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            // Header Profile Card
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
                    radius: 36,
                    backgroundColor: const Color(0xFF0F9D8A).withOpacity(0.2),
                    child: Text(
                      (user["full_name"] ?? "U")[0].toUpperCase(),
                      style: const TextStyle(fontSize: 28, color: Color(0xFF0F9D8A), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user["full_name"] ?? "Unknown User",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            AdminStatusBadge(status: isActive ? "ACTIVE" : "SUSPENDED"),
                            const SizedBox(width: 8),
                            AdminStatusBadge(status: isVerified ? "VERIFIED" : "UNVERIFIED"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile Details Card
            const Text("User Profile Information", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
                  _buildDetailRow("User ID", user["id"] ?? "N/A"),
                  const Divider(color: Colors.white10),
                  _buildDetailRow("Full Name", user["full_name"] ?? "N/A"),
                  const Divider(color: Colors.white10),
                  _buildDetailRow("Mobile Number", user["mobile"] ?? "N/A"),
                  const Divider(color: Colors.white10),
                  _buildDetailRow("Email Address", user["email"] ?? "N/A"),
                  const Divider(color: Colors.white10),
                  _buildDetailRow("Registration Date", user["created_at"]?.toString().split('T').first ?? "N/A"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Security & Bank Linking Card
            const Text("Linked Bank & Security Overview", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
                  _buildDetailRow("Bank Account", "State Bank of India (XXXX1234)"),
                  const Divider(color: Colors.white10),
                  _buildDetailRow("Device Status", "Primary Device Linked & Verified"),
                  const Divider(color: Colors.white10),
                  _buildDetailRow("MPIN Status", "Set & Encrypted"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 14)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
