import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class ConnectedDevicesScreen extends StatefulWidget {
  const ConnectedDevicesScreen({super.key});

  @override
  State<ConnectedDevicesScreen> createState() => _ConnectedDevicesScreenState();
}

class _ConnectedDevicesScreenState extends State<ConnectedDevicesScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _devices = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _api.getAllDevices();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result["success"] == true) {
        _devices = result["devices"] ?? [];
      } else {
        _error = result["message"] ?? "Failed to load connected devices";
      }
    });
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return "Never";
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Linked Devices",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F9D8A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDevices,
        color: const Color(0xFF0F9D8A),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0F9D8A)),
              )
            : _error != null
                ? _buildError()
                : _devices.isEmpty
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
                  Icons.devices,
                  size: 64,
                  color: Color(0xFF0F9D8A),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "No Connected Devices",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2340),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    final bool isConnectionError = (_error ?? "").toLowerCase().contains("connect") ||
        (_error ?? "").toLowerCase().contains("server") ||
        (_error ?? "").toLowerCase().contains("ip");

    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Icon(
                  isConnectionError ? Icons.wifi_off : Icons.error_outline,
                  size: 64,
                  color: isConnectionError ? Colors.orange : Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  isConnectionError ? "Connection Failed" : "Something went wrong",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2340),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _error ?? "Unknown error",
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                if (isConnectionError) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.4)),
                    ),
                    child: const Text(
                      "💡 Make sure your phone and server are on the same WiFi, and the IP in the app matches your computer's local IP.",
                      style: TextStyle(color: Colors.orange, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadDevices,
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
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final d = _devices[index];
        final bool isPrimary = d["is_primary"] ?? false;
        final bool approved = d["approved"] ?? false;
        final bool isBlocked = d["is_blocked"] ?? false;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: isPrimary 
                  ? const Color(0xFF0F9D8A).withOpacity(0.1) 
                  : Colors.grey.withOpacity(0.1),
              child: Icon(
                isPrimary ? Icons.star : Icons.phone_android,
                color: isPrimary ? const Color(0xFF0F9D8A) : Colors.grey,
              ),
            ),
            title: Text(
              d["device_name"] ?? "Unknown Device",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              isPrimary ? "Primary Device" : "Secondary Device",
              style: TextStyle(
                color: isPrimary ? const Color(0xFF0F9D8A) : Colors.grey,
                fontSize: 12,
              ),
            ),
            trailing: _buildStatusBadge(approved, isBlocked),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.branding_watermark, "Brand", d["brand"] ?? "N/A"),
                    const SizedBox(height: 8),
                    _buildDetailRow(Icons.phone_iphone, "Model", d["model"] ?? "N/A"),
                    const SizedBox(height: 8),
                    _buildDetailRow(Icons.android, "Android Version", d["android_version"] ?? "N/A"),
                    const SizedBox(height: 8),
                    _buildDetailRow(Icons.vignette, "App Version", d["app_version"] ?? "N/A"),
                    const SizedBox(height: 8),
                    _buildDetailRow(Icons.access_time, "Last Active", _formatDate(d["last_login"])),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(bool approved, bool isBlocked) {
    Color color = Colors.orange;
    String label = "Pending";

    if (isBlocked) {
      color = Colors.red;
      label = "Blocked";
    } else if (approved) {
      color = Colors.green;
      label = "Approved";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0F9D8A)),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
