import 'package:flutter/material.dart';
import 'package:samvya/services/admin_api_service.dart';
import 'package:samvya/admin/widgets/admin_status_badge.dart';

class AdminAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onRefresh;

  const AdminAppBar({
    super.key,
    required this.title,
    this.onRefresh,
  });

  @override
  Size get preferredSize => const Size.fromHeight(65);

  @override
  State<AdminAppBar> createState() => _AdminAppBarState();
}

class _AdminAppBarState extends State<AdminAppBar> {
  String _adminName = "Super Admin";
  String _adminRole = "SUPER_ADMIN";

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
  }

  Future<void> _loadAdminInfo() async {
    final name = await AdminApiService().getAdminName();
    final role = await AdminApiService().getAdminRole();
    if (mounted) {
      setState(() {
        _adminName = name ?? "Super Admin";
        _adminRole = role ?? "SUPER_ADMIN";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white70),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (widget.onRefresh != null)
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0F9D8A)),
                onPressed: widget.onRefresh,
                tooltip: "Refresh Data",
              ),
            const SizedBox(width: 8),
            AdminStatusBadge(status: _adminRole),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF0F9D8A),
              child: Text(
                _adminName.isNotEmpty ? _adminName[0].toUpperCase() : "A",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
