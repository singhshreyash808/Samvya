import 'package:flutter/material.dart';
import 'package:samvya/models/transaction_model.dart';
import 'package:samvya/services/transaction_service.dart';
import 'package:easy_localization/easy_localization.dart';

/// Self-contained widget displayed on the dashboard
/// showing pending transactions with Approve/Reject actions.
class PendingTransactionsWidget extends StatefulWidget {
  const PendingTransactionsWidget({super.key});

  @override
  State<PendingTransactionsWidget> createState() => _PendingTransactionsWidgetState();
}

class _PendingTransactionsWidgetState extends State<PendingTransactionsWidget> {
  final TransactionService _service = TransactionService();
  List<BankTransaction> _pending = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final txns = await _service.getTransactions(status: 'pending');
    if (mounted) setState(() { _pending = txns; _loading = false; });
  }

  Future<void> _approve(BankTransaction txn) async {
    final ok = await _service.approveTransaction(txn.id);
    if (ok && mounted) {
      setState(() => _pending.remove(txn));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text("dashboard.txn_approved".tr(namedArgs: {"amount": txn.formattedAmount, "name": txn.recipientName})),
          ]),
          backgroundColor: const Color(0xFF0F9D8A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _reject(BankTransaction txn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("dashboard.reject_txn_confirm_title".tr()),
        content: Text("dashboard.reject_txn_confirm_msg".tr(namedArgs: {"amount": "₹" + txn.amount.toStringAsFixed(0), "name": txn.recipientName})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("dashboard.cancel".tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text("dashboard.reject".tr()),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final ok = await _service.rejectTransaction(txn.id);
      if (ok && mounted) {
        setState(() => _pending.remove(txn));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.cancel, color: Colors.white),
              const SizedBox(width: 8),
              Text("dashboard.txn_rejected".tr(namedArgs: {"name": txn.recipientName})),
            ]),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF0F9D8A))),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.pending_actions, color: Colors.orange.shade700, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "dashboard.pending_transactions".tr(),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  if (_pending.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade600,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${_pending.length}",
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
              GestureDetector(
                onTap: _load,
                child: const Icon(Icons.refresh, color: Colors.grey, size: 20),
              ),
            ],
          ),
        ),

        if (_pending.isEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green.shade400, size: 22),
                const SizedBox(width: 10),
                Text(
                  "dashboard.no_pending_transactions".tr(),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _pending.length,
            itemBuilder: (context, index) => _buildPendingCard(_pending[index]),
          ),
      ],
    );
  }

  Widget _buildPendingCard(BankTransaction txn) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Transaction info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      txn.recipientName.isNotEmpty ? txn.recipientName[0].toUpperCase() : "?",
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn.recipientName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "A/C ${txn.recipientAccountNumber}${txn.recipientBank != null ? ' • ${txn.recipientBank}' : ''}",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                      if (txn.description != null && txn.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            txn.description!,
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                // Amount + badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      txn.formattedAmount,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Pending",
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: Colors.orange.shade100),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Reject button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reject(txn),
                    icon: const Icon(Icons.close, size: 16),
                    label: Text("dashboard.reject".tr()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Approve button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approve(txn),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text("Approve"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F9D8A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
