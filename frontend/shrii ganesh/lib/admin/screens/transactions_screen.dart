import 'package:flutter/material.dart';
import 'package:samvya/admin/widgets/admin_app_bar.dart';
import 'package:samvya/admin/widgets/admin_sidebar.dart';
import 'package:samvya/admin/widgets/admin_status_badge.dart';
import 'package:samvya/admin/screens/transaction_details_screen.dart';
import 'package:samvya/services/admin_api_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool _isLoading = true;
  List<dynamic> _transactions = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions([String? search]) async {
    setState(() => _isLoading = true);
    final res = await AdminApiService().getTransactions(search: search);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res["success"] == true) {
          _transactions = res["transactions"] ?? [];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AdminAppBar(
        title: "Transaction Monitoring",
        onRefresh: () => _fetchTransactions(_searchController.text),
      ),
      drawer: const AdminSidebar(activeRoute: "Transactions"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search Input
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => _fetchTransactions(val),
              decoration: InputDecoration(
                hintText: "Search by Recipient Name or Account Number...",
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0F9D8A)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          _fetchTransactions();
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

            // Transactions Table / List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F9D8A)))
                  : _transactions.isEmpty
                      ? const Center(
                          child: Text(
                            "No transactions found.",
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _transactions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final txn = _transactions[index];
                            final status = txn["status"] ?? "APPROVED";
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF0F9D8A).withOpacity(0.2),
                                  child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF0F9D8A)),
                                ),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      txn["recipient_name"] ?? "Transfer",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                                    ),
                                    Text(
                                      "₹${txn['amount'] ?? 0.0}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Acc: ${txn['recipient_account_number'] ?? 'N/A'} (${txn['recipient_bank'] ?? 'Bank'})",
                                        style: const TextStyle(color: Colors.white60, fontSize: 13),
                                      ),
                                      AdminStatusBadge(status: status),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => TransactionDetailsScreen(transaction: txn)),
                                  );
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
