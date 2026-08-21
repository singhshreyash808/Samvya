import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/transaction_history_widget.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("dashboard.history".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF095A50),
        foregroundColor: Colors.white,
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: TransactionHistoryWidget(), // Shows recent transactions for all accounts
          ),
        ),
      ),
    );
  }
}
