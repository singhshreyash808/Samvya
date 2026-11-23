import 'package:flutter/material.dart';
import 'package:samvya/admin/widgets/admin_app_bar.dart';
import 'package:samvya/admin/widgets/admin_sidebar.dart';
import 'package:samvya/admin/widgets/admin_status_badge.dart';
import 'package:samvya/admin/screens/user_details_screen.dart';
import 'package:samvya/services/admin_api_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  bool _isLoading = true;
  List<dynamic> _users = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers([String? search]) async {
    setState(() => _isLoading = true);
    final res = await AdminApiService().getUsers(search: search);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res["success"] == true) {
          _users = res["users"] ?? [];
        }
      });
    }
  }

  Future<void> _toggleStatus(String userId, bool currentStatus) async {
    final res = await AdminApiService().toggleUserStatus(userId, !currentStatus);
    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Status updated"), backgroundColor: const Color(0xFF0F9D8A)),
      );
      _fetchUsers(_searchController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["detail"] ?? "Failed to update status"), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AdminAppBar(
        title: "User Account Management",
        onRefresh: () => _fetchUsers(_searchController.text),
      ),
      drawer: const AdminSidebar(activeRoute: "Users"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => _fetchUsers(val),
              decoration: InputDecoration(
                hintText: "Search by Name, Mobile Number, or Email...",
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0F9D8A)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          _fetchUsers();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Users List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F9D8A)))
                  : _users.isEmpty
                      ? const Center(
                          child: Text(
                            "No users found.",
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _users.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final u = _users[index];
                            final isActive = u["is_active"] ?? true;
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: const Color(0xFF0F9D8A).withOpacity(0.2),
                                  child: Text(
                                    (u["full_name"] ?? "U")[0].toUpperCase(),
                                    style: const TextStyle(color: Color(0xFF0F9D8A), fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      u["full_name"] ?? "User",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    AdminStatusBadge(status: isActive ? "ACTIVE" : "SUSPENDED"),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    "Mobile: ${u['mobile'] ?? 'N/A'} | Email: ${u['email'] ?? 'N/A'}",
                                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isActive ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                                        color: isActive ? Colors.redAccent : const Color(0xFF10B981),
                                      ),
                                      tooltip: isActive ? "Suspend User" : "Activate User",
                                      onPressed: () => _toggleStatus(u["id"], isActive),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => UserDetailsScreen(user: u)),
                                        );
                                      },
                                    ),
                                  ],
                                ),
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
