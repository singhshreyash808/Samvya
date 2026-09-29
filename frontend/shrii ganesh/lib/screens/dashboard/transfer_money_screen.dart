import 'package:flutter/material.dart';
import 'package:samvya/models/bank_account_model.dart';
import 'package:samvya/services/transaction_service.dart';
import 'package:samvya/widgets/cheque_animation_overlay.dart';

class TransferMoneyScreen extends StatefulWidget {
  final BankAccount senderAccount;
  final String? initialRecipientAccount;
  final String? initialRecipientName;

  const TransferMoneyScreen({
    super.key, 
    required this.senderAccount,
    this.initialRecipientAccount,
    this.initialRecipientName,
  });

  @override
  State<TransferMoneyScreen> createState() => _TransferMoneyScreenState();
}

class _TransferMoneyScreenState extends State<TransferMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _recipientNameCtrl;
  late final TextEditingController _recipientAccountCtrl;
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  bool _isLoading = false;
  final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    _recipientNameCtrl = TextEditingController(text: widget.initialRecipientName ?? '');
    _recipientAccountCtrl = TextEditingController(text: widget.initialRecipientAccount ?? '');
  }

  @override
  void dispose() {
    _recipientNameCtrl.dispose();
    _recipientAccountCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _sendMoney() async {
    if (!_formKey.currentState!.validate()) return;
    
    final amount = double.tryParse(_amountCtrl.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid amount")),
      );
      return;
    }

    if (amount > widget.senderAccount.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Insufficient funds")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Call API
    final result = await _transactionService.createTransaction(
      senderAccountId: widget.senderAccount.id,
      recipientName: _recipientNameCtrl.text.trim(),
      recipientAccountNumber: _recipientAccountCtrl.text.trim(),
      amount: amount,
      description: _descCtrl.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // Show cheque animation
      if (mounted) {
        FocusScope.of(context).unfocus(); // hide keyboard
        ChequeAnimationOverlay.show(context, _amountCtrl.text, () {
          // Callback after animation completes
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Transfer of ₹${_amountCtrl.text} initiated successfully!"),
                backgroundColor: const Color(0xFF0F9D8A),
              ),
            );
            Navigator.pop(context); // Go back to dashboard
          }
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Transfer failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Transfer Money", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F9D8A),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender Info
                const Text("From Account", style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.senderAccount.bankName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(widget.senderAccount.maskedNumber, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Balance", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(widget.senderAccount.formattedBalance, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F9D8A))),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Recipient Form
                const Text("To Recipient", style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 12),
                
                TextFormField(
                  controller: _recipientNameCtrl,
                  decoration: InputDecoration(
                    labelText: "Recipient Name",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) => v == null || v.isEmpty ? "Enter recipient name" : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _recipientAccountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Account Number",
                    prefixIcon: const Icon(Icons.credit_card),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) => v == null || v.isEmpty ? "Enter account number" : null,
                ),
                
                const SizedBox(height: 32),
                
                // Amount
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: "Amount (₹)",
                    prefixIcon: const Icon(Icons.currency_rupee, size: 28),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  validator: (v) => v == null || v.isEmpty ? "Enter amount" : null,
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descCtrl,
                  decoration: InputDecoration(
                    labelText: "Remarks (Optional)",
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendMoney,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F9D8A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Send Money", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
