import 'package:flutter/material.dart';
import 'package:samvya/widgets/transaction_history_widget.dart';

class MoneyScreen extends StatelessWidget {
  const MoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("All Transactions", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F9D8A),
        elevation: 0,
        automaticallyImplyLeading: false, // It's a bottom nav tab
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 10, bottom: 40),
            child: TransactionHistoryWidget(showHeader: false),
          ),
        ),
      ),
    );
  }
}
