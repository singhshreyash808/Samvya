import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samvya/models/bank_account_model.dart';
import 'package:samvya/services/bank_account_service.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  final BankAccountService _service = BankAccountService();
  List<BankAccount> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    final accounts = await _service.getAccounts();
    if (mounted) {
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    }
  }

  void _showAddAccountDialog() {
    final bankNameCtrl = TextEditingController();
    final accountNumberCtrl = TextEditingController();
    final ifscCtrl = TextEditingController();
    final holderNameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final tpinCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance, color: Color(0xFF0F9D8A)),
                        const SizedBox(width: 12),
                        const Text("Link New Bank Account",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        )
                      ],
                    ),
                    const Divider(height: 24),
                    _buildField("Bank Name", bankNameCtrl, hint: "e.g. State Bank of India"),
                    _buildField("Account Number", accountNumberCtrl,
                        hint: "e.g. 1234567890", type: TextInputType.number),
                    _buildField("IFSC Code", ifscCtrl, hint: "e.g. SBIN0001234"),
                    _buildField("Account Holder Name", holderNameCtrl, hint: "As per bank records"),
                    _buildField("Phone Number", phoneCtrl,
                        hint: "Linked mobile number", type: TextInputType.phone),
                    _buildField("Set TPIN (4–6 digits)", tpinCtrl,
                        hint: "Create a secure TPIN",
                        type: TextInputType.number,
                        isObscure: true,
                        maxLength: 6),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setSheetState(() => isSaving = true);
                                final result = await _service.addAccount(
                                  bankName: bankNameCtrl.text.trim(),
                                  accountNumber: accountNumberCtrl.text.trim(),
                                  ifscCode: ifscCtrl.text.trim().toUpperCase(),
                                  accountHolderName: holderNameCtrl.text.trim(),
                                  phoneNumber: phoneCtrl.text.trim(),
                                  tpin: tpinCtrl.text.trim(),
                                );
                                setSheetState(() => isSaving = false);
                                if (!ctx.mounted) return;
                                Navigator.pop(ctx);
                                if (result['success'] == true) {
                                  await _loadAccounts();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("✅ Account linked successfully!"),
                                      backgroundColor: Color(0xFF0F9D8A),
                                    ),
                                  );
                                } else {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result['message'] ?? "Failed."),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        icon: isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.link, color: Colors.white),
                        label: Text(isSaving ? "Linking..." : "Link Account",
                            style: const TextStyle(color: Colors.white, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F9D8A),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    String? hint,
    TextInputType type = TextInputType.text,
    bool isObscure = false,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        obscureText: isObscure,
        maxLength: maxLength,
        inputFormatters: type == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          counterText: "",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0F9D8A), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return "$label is required";
          if (label.contains("TPIN") && value.length < 4) return "TPIN must be at least 4 digits";
          return null;
        },
      ),
    );
  }

  Future<void> _confirmDelete(BankAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Account"),
        content: Text(
            "Are you sure you want to remove your ${account.bankName} account (${account.maskedNumber})?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Remove", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final success = await _service.deleteAccount(account.id);
      if (success) {
        await _loadAccounts();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account removed."), backgroundColor: Colors.orange),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("My Accounts"),
        backgroundColor: const Color(0xFF0F9D8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAccountDialog,
        backgroundColor: const Color(0xFF0F9D8A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Account"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F9D8A)))
          : _accounts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_outlined, size: 72, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text("No accounts linked yet",
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
                      const SizedBox(height: 8),
                      Text("Tap + Add Account to link your bank",
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAccounts,
                  color: const Color(0xFF0F9D8A),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _accounts.length,
                    itemBuilder: (context, index) {
                      final account = _accounts[index];
                      return _buildAccountCard(account);
                    },
                  ),
                ),
    );
  }

  Widget _buildAccountCard(BankAccount account) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF095A50), Color(0xFF0F9D8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F9D8A).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    account.bankName,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 22),
                  onPressed: () => _confirmDelete(account),
                  tooltip: "Remove Account",
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              account.accountHolderName,
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              account.maskedNumber,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("IFSC", style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Text(account.ifscCode,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Phone", style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Text(account.phoneNumber,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}