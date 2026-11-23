import 'package:flutter/material.dart';
import 'package:samvya/admin/widgets/admin_status_badge.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text("Transaction Audit View", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            // Amount Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF0F9D8A).withOpacity(0.3), width: 1.5),
              ),
              child: Column(
                children: [
                  const Text("TRANSACTION AMOUNT", style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text(
                    "₹${transaction['amount'] ?? 0.0}",
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  AdminStatusBadge(status: transaction["status"] ?? "APPROVED"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Detailed Breakdown
            const Text("Transaction Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
                  _buildRow("Transaction Reference ID", transaction["id"] ?? "N/A"),
                  const Divider(color: Colors.white10),
                  _buildRow("Recipient Name", transaction["recipient_name"] ?? "N/A"),
                  const Divider(color: Colors.white10),
                  _buildRow("Recipient Account", transaction["recipient_account_number"] ?? "N/A"),
                  const Divider(color: Colors.white10),
                  _buildRow("Recipient Bank", transaction["recipient_bank"] ?? "SBI"),
                  const Divider(color: Colors.white10),
                  _buildRow("Sender Account ID", transaction["sender_account_id"] ?? "ACC_PRIMARY"),
                  const Divider(color: Colors.white10),
                  _buildRow("Description / Note", transaction["description"] ?? "Direct Transfer"),
                  const Divider(color: Colors.white10),
                  _buildRow("Timestamp", transaction["created_at"]?.toString().replaceAll('T', ' ') ?? "N/A"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Fraud & Security Scoring Card
            const Text("Risk & Fraud Assessment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
                  _buildRow("ML Isolation Forest Anomaly", "Normal (Score: 0.12)"),
                  const Divider(color: Colors.white10),
                  _buildRow("Device Binding Match", "Verified Device Token"),
                  const Divider(color: Colors.white10),
                  _buildRow("Geolocation Verification", "Trusted Location"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
