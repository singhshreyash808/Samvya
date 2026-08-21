import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PendingDevicesScreen extends StatefulWidget {
  const PendingDevicesScreen({super.key});

  @override
  State<PendingDevicesScreen> createState() => _PendingDevicesScreenState();
}

class _PendingDevicesScreenState extends State<PendingDevicesScreen> {
  final ApiService _api = ApiService();

  List<dynamic> _pending = [];
  bool _loading = true;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadPending();
    // Auto-refresh every 10 seconds
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadPending(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPending() async {
    final result = await _api.getPendingDevices();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result["success"] == true) {
        _pending = result["pending"] ?? [];
        _error = null;
      } else {
        _error = result["message"] ?? "Failed to load";
      }
    });
  }

  Future<void> _approve(String deviceUuid, String deviceName) async {
    _showLoadingDialog("Approving $deviceName...");
    final result = await _api.approveDevice(deviceUuid);
    if (!mounted) return;
    Navigator.pop(context); // close loading dialog

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result["success"] == true
              ? "✅ $deviceName approved successfully!"
              : result["message"] ?? "Approval failed",
        ),
        backgroundColor:
            result["success"] == true ? const Color(0xFF0F9D8A) : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    if (result["success"] == true) _loadPending();
  }

  Future<void> _reject(String deviceUuid, String deviceName) async {
    // Confirm before rejecting
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Reject Device?"),
        content: Text(
          "Are you sure you want to reject and block \"$deviceName\"?\nThis device will not be able to log in.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Reject", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    _showLoadingDialog("Rejecting $deviceName...");
    final result = await _api.rejectDevice(deviceUuid);
    if (!mounted) return;
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result["success"] == true
              ? "🚫 $deviceName rejected."
              : result["message"] ?? "Rejection failed",
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    if (result["success"] == true) _loadPending();
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Row(
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF0F9D8A),
            ),
            const SizedBox(width: 20),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _loadPending,
        color: const Color(0xFF0F9D8A),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0F9D8A)),
              )
            : _error != null
                ? _buildError()
                : _pending.isEmpty
                    ? _buildEmpty()
                    : _buildList(),
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F9D8A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.devices_other,
                  size: 64,
                  color: Color(0xFF0F9D8A),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "No Pending Requests",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2340),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "When someone tries to log in\nfrom a new device, it will appear here.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            children: [
              const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _error ?? "Something went wrong",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadPending,
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F9D8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pending.length,
      itemBuilder: (context, index) {
        final device = _pending[index];
        return _DeviceRequestCard(
          deviceName: device["device_name"] ?? "Unknown Device",
          brand: device["brand"] ?? "",
          model: device["model"] ?? "",
          androidVersion: device["android_version"] ?? "",
          appVersion: device["app_version"] ?? "",
          createdAt: device["created_at"] ?? "",
          onApprove: () => _approve(
            device["device_uuid"],
            device["device_name"] ?? "this device",
          ),
          onReject: () => _reject(
            device["device_uuid"],
            device["device_name"] ?? "this device",
          ),
        );
      },
    );
  }
}

// ─── Device Request Card ───────────────────────────────────────────────────────

class _DeviceRequestCard extends StatelessWidget {
  final String deviceName;
  final String brand;
  final String model;
  final String androidVersion;
  final String appVersion;
  final String createdAt;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _DeviceRequestCard({
    required this.deviceName,
    required this.brand,
    required this.model,
    required this.androidVersion,
    required this.appVersion,
    required this.createdAt,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F9D8A), Color(0xFF5ED3C5)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.phonelink_lock, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deviceName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "$brand · Android $androidVersion",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "PENDING",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _infoRow(Icons.phone_android, "Model", "$brand $model"),
                const SizedBox(height: 8),
                _infoRow(Icons.system_update, "Android", androidVersion),
                const SizedBox(height: 8),
                _infoRow(Icons.apps, "App Version", "v$appVersion"),
                const SizedBox(height: 8),
                _infoRow(
                  Icons.access_time,
                  "Requested",
                  _formatDate(createdAt),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    // Reject
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.block, size: 18),
                        label: const Text("Reject"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Approve
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: onApprove,
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text("Approve"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F9D8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0F9D8A)),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF1A2340),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return "${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return raw;
    }
  }
}
