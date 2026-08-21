import 'package:flutter/material.dart';
import 'package:samvya/models/bank_account_model.dart';
import 'package:samvya/widgets/transaction_history_widget.dart';

class AccountTransactionsScreen extends StatelessWidget {
  final BankAccount account;

  const AccountTransactionsScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Account Statement", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F9D8A),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F9D8A), Color(0xFF5ED3C5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      account.bankName,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      account.maskedNumber,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Transactions List
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 40),
                child: TransactionHistoryWidget(
                  accountId: account.id,
                  showHeader: false, // We don't need the header since the screen itself is clear
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
