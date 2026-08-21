import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:samvya/models/transaction_model.dart';
import 'package:samvya/services/transaction_service.dart';

class TransactionHistoryWidget extends StatefulWidget {
  final String? accountId;
  final int? limit;
  final bool showHeader;

  const TransactionHistoryWidget({
    super.key, 
    this.accountId, 
    this.limit,
    this.showHeader = true,
  });

  @override
  State<TransactionHistoryWidget> createState() => _TransactionHistoryWidgetState();
}

class _TransactionHistoryWidgetState extends State<TransactionHistoryWidget> {
  final TransactionService _service = TransactionService();
  List<BankTransaction> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final txns = await _service.getTransactions(accountId: widget.accountId);
    if (mounted) {
      setState(() {
        _transactions = widget.limit != null ? txns.take(widget.limit!).toList() : txns;
        _loading = false;
      });
    }
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} • $hour:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF0F9D8A))),
      );
    }

    if (_transactions.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            "dashboard.no_transactions".tr(),
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "dashboard.recent_transactions".tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                GestureDetector(
                  onTap: _load,
                  child: const Icon(Icons.refresh, color: Colors.grey, size: 20),
                ),
              ],
            ),
          ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _transactions.length,
          itemBuilder: (context, index) => _buildTransactionCard(_transactions[index]),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(BankTransaction txn) {
    final bool isApproved = txn.isApproved;
    final bool isRejected = txn.isRejected;
    final bool isPending = txn.isPending;
    
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.pending;
    
    if (isApproved) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (isRejected) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_balance, color: const Color(0xFF0F9D8A)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.recipientName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(txn.createdAt.toLocal()),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "- ${txn.formattedAmount}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    txn.status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
