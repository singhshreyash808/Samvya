import 'package:flutter/material.dart';
import 'package:samvya/admin/widgets/admin_app_bar.dart';
import 'package:samvya/admin/widgets/admin_sidebar.dart';
import 'package:samvya/admin/widgets/admin_status_badge.dart';
import 'package:samvya/services/admin_api_service.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  bool _isLoading = true;
  List<dynamic> _admins = [];

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    setState(() => _isLoading = true);
    final res = await AdminApiService().getAdmins();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res["success"] == true) {
          _admins = res["admins"] ?? [];
        }
      });
    }
  }

  void _showAddAdminDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedRole = "OPERATIONS_OFFICER";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulWidgetBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: const Text("Create New Admin Officer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Full Name", labelStyle: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Email Address", labelStyle: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Password", labelStyle: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      dropdownColor: const Color(0xFF0F172A),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Assigned Role", labelStyle: TextStyle(color: Colors.white70)),
                      items: const [
                        DropdownMenuItem(value: "SUPER_ADMIN", child: Text("Super Admin")),
                        DropdownMenuItem(value: "SECURITY_OFFICER", child: Text("Security Officer")),
                        DropdownMenuItem(value: "OPERATIONS_OFFICER", child: Text("Operations Officer")),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedRole = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty) return;
                    Navigator.pop(context);
                    final res = await AdminApiService().createAdmin({
                      "full_name": nameCtrl.text.trim(),
                      "email": emailCtrl.text.trim(),
                      "password": passCtrl.text.trim(),
                      "role": selectedRole,
                    });
                    if (res["success"] == true) {
                      _fetchAdmins();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Admin user created!"), backgroundColor: Color(0xFF0F9D8A)),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(res["detail"] ?? "Creation failed"), backgroundColor: Colors.redAccent),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F9D8A)),
                  child: const Text("Create Admin", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AdminAppBar(
        title: "Admin & Role Management",
        onRefresh: _fetchAdmins,
      ),
      drawer: const AdminSidebar(activeRoute: "Admins"),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAdminDialog,
        backgroundColor: const Color(0xFF0F9D8A),
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text("Add Admin Officer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F9D8A)))
            : ListView.separated(
                itemCount: _admins.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final a = _admins[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF0F9D8A).withOpacity(0.2),
                        child: Text(
                          (a["full_name"] ?? "A")[0].toUpperCase(),
                          style: const TextStyle(color: Color(0xFF0F9D8A), fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            a["full_name"] ?? "Admin",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          AdminStatusBadge(status: a["role"] ?? "OPERATIONS_OFFICER"),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text("Email: ${a['email'] ?? 'N/A'}", style: const TextStyle(color: Colors.white60, fontSize: 13)),
                      ),
                      trailing: const Icon(Icons.verified_user_rounded, color: Color(0xFF0F9D8A)),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
