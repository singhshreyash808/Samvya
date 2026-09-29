import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:samvya/models/bank_account_model.dart';
import 'package:samvya/services/bank_account_service.dart';
import '../../services/local_storage_service.dart';
import 'profile_screen.dart';
import '../devices/pending_devices_screen.dart';
import '../profile/my_account_screen.dart';
import '../../widgets/pending_transactions_widget.dart';
import '../../widgets/transaction_history_widget.dart';
import 'transfer_money_screen.dart';
import 'account_transactions_screen.dart';
import 'history_screen.dart';
import 'package:samvya/services/voice_assistant_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'qr_scan_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = "User";
  Timer? _autoPlayTimer;
  int _currentPage = 0;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  final BankAccountService _accountService = BankAccountService();
  List<BankAccount> _accounts = [];
  bool _isOffline = false;
  bool _accountsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _accountsLoading = true);
    try {
      final accounts = await _accountService.getAccounts();
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _isOffline = false;
          _accountsLoading = false;
        });
        _startAutoPlay();
      }
    } on DioException {
      if (mounted) {
        setState(() {
          _isOffline = true;
          _accountsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isOffline = true;
          _accountsLoading = false;
        });
      }
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (_accounts.isEmpty) return;
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && _accounts.isNotEmpty) {
        _currentPage = (_currentPage + 1) % _accounts.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final name = await LocalStorageService.getName();
    if (mounted) setState(() => userName = name.isNotEmpty ? name : "User");
  }

  // ─── TPIN Dialog ──────────────────────────────────────────────────────────────
  void _showTpinDialog(BankAccount account) {
    final tpinCtrl = TextEditingController();
    final VoiceAssistantService voiceService = VoiceAssistantService();
    bool isVerifying = false;
    String? errorMsg;
    
    // Play voice prompt
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        voiceService.speak(
          "voice.enter_tpin".tr(),
          languageCode: VoiceAssistantService.getLanguageCode(context.locale),
        );
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F9D8A).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, color: Color(0xFF0F9D8A), size: 32),
                ),
                const SizedBox(height: 12),
                Text("dashboard.enter_tpin".tr(), style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  account.bankName,
                  style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tpinCtrl,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 10),
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "••••",
                    hintStyle: const TextStyle(letterSpacing: 10),
                    errorText: errorMsg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0F9D8A), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(account.maskedNumber,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("dashboard.cancel".tr()),
              ),
              ElevatedButton(
                onPressed: isVerifying
                    ? null
                    : () async {
                        if (tpinCtrl.text.length < 4) {
                          setDState(() => errorMsg = "dashboard.tpin_min_digits".tr());
                          return;
                        }
                        setDState(() {
                          isVerifying = true;
                          errorMsg = null;
                        });
                        final result = await _accountService.verifyTpin(account.id, tpinCtrl.text);
                        if (!ctx.mounted) return;
                        if (result['success'] == true) {
                          Navigator.pop(ctx);
                          _onTpinVerified(account);
                        } else {
                          voiceService.speak(
                            "voice.incorrect_tpin".tr(),
                            languageCode: VoiceAssistantService.getLanguageCode(context.locale),
                          );
                          setDState(() {
                            isVerifying = false;
                            errorMsg = result['message'] ?? "Incorrect TPIN";
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F9D8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isVerifying
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text("dashboard.verify".tr()),
              ),
            ],
          );
        });
      },
    );
  }

  void _onTpinVerified(BankAccount account) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F9D8A).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, color: Color(0xFF0F9D8A)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("dashboard.account_access_granted".tr(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(account.bankName,
                              style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Balance display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("dashboard.live_bank_balance".tr(),
                        style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(account.formattedBalance,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(account.maskedNumber,
                        style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _detailRow(Icons.person, "dashboard.account_holder".tr(), account.accountHolderName),
              _detailRow(Icons.code, "dashboard.ifsc_code".tr(), account.ifscCode),
              const SizedBox(height: 24),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TransferMoneyScreen(senderAccount: account),
                            ),
                          ).then((_) => _loadAccounts());
                        },
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        label: Text("dashboard.transfer_money".tr(),
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F9D8A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AccountTransactionsScreen(account: account),
                            ),
                          );
                        },
                        icon: const Icon(Icons.receipt_long, color: Color(0xFF0F9D8A), size: 18),
                        label: Text("dashboard.check_txn".tr(),
                            style: TextStyle(color: Color(0xFF0F9D8A), fontSize: 14, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0F9D8A)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0F9D8A)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Bills Bottom Sheet ───────────────────────────────────────────────────────
  void _showBillsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("dashboard.bills_and_recharge".tr(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  quickButton(Icons.phone_android, "dashboard.mobile".tr(), () {}),
                  quickButton(Icons.tv, "dashboard.dth".tr(), () {}),
                  quickButton(Icons.lightbulb_outline, "dashboard.electricity".tr(), () {}),
                  quickButton(Icons.directions_car, "dashboard.fastag".tr(), () {}),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("dashboard.filter_by_account".tr(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 16),
              ..._accounts.map((acc) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200)),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: const Color(0xFF0F9D8A).withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.account_balance_wallet, color: Color(0xFF0F9D8A)),
                      ),
                      title: Text(acc.bankName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(acc.maskedNumber),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AccountTransactionsScreen(account: acc),
                          ),
                        );
                      },
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAccounts,
          color: const Color(0xFF0F9D8A),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Header
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF095A50), Color(0xFF0F9D8A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("app_name".tr(),
                              style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const ProfileScreen()));
                            },
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white,
                              child: Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                    color: Color(0xFF0F9D8A), fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "profile.welcome".tr(namedArgs: {"name": userName}),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),

                // ─── Account Cards Slider ─────────────────────────────────────
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: _accountsLoading
                      ? const SizedBox(
                          height: 160,
                          child: Center(child: CircularProgressIndicator(color: Color(0xFF0F9D8A))),
                        )
                      : _accounts.isEmpty
                          ? GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const MyAccountScreen()));
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                      color: const Color(0xFF0F9D8A).withOpacity(0.3),
                                      style: BorderStyle.solid,
                                      width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8))
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add_circle_outline, size: 40, color: Color(0xFF0F9D8A)),
                                    const SizedBox(height: 12),
                                    Text("dashboard.link_first_account".tr(),
                                        style: TextStyle(
                                            color: Color(0xFF0F9D8A),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text("dashboard.tap_to_add_account".tr(),
                                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 180,
                              child: PageView.builder(
                                itemCount: _accounts.length,
                                controller: _pageController,
                                onPageChanged: (page) => _currentPage = page,
                                itemBuilder: (context, index) {
                                  final acc = _accounts[index];
                                  return GestureDetector(
                                    onTap: () => _showTpinDialog(acc),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF095A50), Color(0xFF0F9D8A)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                              color: const Color(0xFF0F9D8A).withOpacity(0.35),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8))
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(12)),
                                                child: Text(acc.bankName,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold)),
                                              ),
                                              const Icon(Icons.lock, color: Colors.white54, size: 18),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          Text(acc.accountHolderName,
                                              style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  letterSpacing: 0.5)),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              const Icon(Icons.credit_card, size: 16, color: Colors.white54),
                                              const SizedBox(width: 6),
                                              Text(acc.maskedNumber,
                                                  style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14)),
                                              const Spacer(),
                                              Text("dashboard.tap_to_unlock".tr(),
                                                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),

                // ─── Quick Actions ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text("dashboard.quick_actions".tr(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: quickButton(Icons.qr_code_scanner, "dashboard.scan_qr".tr(), () async {
                            final scannedCode = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const QRScanScreen()),
                            );
                            if (scannedCode != null && scannedCode is String && mounted) {
                              if (_accounts.isNotEmpty) {
                                String recipientAccount = scannedCode;
                                String recipientName = "";
                                if (scannedCode.startsWith("upi://pay")) {
                                   final uri = Uri.tryParse(scannedCode);
                                   if (uri != null) {
                                      recipientAccount = uri.queryParameters['pa'] ?? scannedCode;
                                      recipientName = uri.queryParameters['pn'] ?? "";
                                   }
                                }
                                
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TransferMoneyScreen(
                                      senderAccount: _accounts.first,
                                      initialRecipientAccount: recipientAccount,
                                      initialRecipientName: recipientName,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please link a bank account first."), backgroundColor: Colors.orange),
                                );
                              }
                            }
                          })),
                          Expanded(child: quickButton(Icons.receipt_long, "dashboard.bills".tr(), _showBillsBottomSheet)),
                          Expanded(child: quickButton(Icons.send_rounded, "dashboard.transfer".tr(), () {})),
                          Expanded(child: quickButton(Icons.filter_list, "dashboard.check_txn".tr(), _showFilterBottomSheet)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: quickButton(Icons.devices, "dashboard.devices".tr(), () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const PendingDevicesScreen()));
                          })),
                          Expanded(child: quickButton(Icons.account_balance, "dashboard.accounts".tr(), () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const MyAccountScreen())).then((_) => _loadAccounts());
                          })),
                          const Expanded(child: SizedBox()),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ─── Bank Services ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Text(
                    "dashboard.bank_services".tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      serviceBox(Icons.history, "dashboard.history".tr(), () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                      }),
                      serviceBox(Icons.account_balance_wallet, "dashboard.balance".tr(), () {}),
                      serviceBox(Icons.download_rounded, "dashboard.statement".tr(), () {}),
                    ],
                  ),
                ),

                // ─── Pending Transactions ─────────────────────────────────
                const SizedBox(height: 24),
                const PendingTransactionsWidget(),

                // ─── Offline / Pending Indicator ──────────────────────────────
                if (_isOffline)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off_rounded, color: Colors.orange.shade700, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("dashboard.pending_connection".tr(),
                                  style: TextStyle(
                                      color: Colors.orange.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              Text("dashboard.services_unavailable_retry".tr(),
                                  style: TextStyle(color: Colors.orange.shade700, fontSize: 12)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _loadAccounts,
                          child: Icon(Icons.refresh, color: Colors.orange.shade700),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget quickButton(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Icon(icon, color: const Color(0xFF0F9D8A), size: 28),
          ),
          const SizedBox(height: 10),
          Text(text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget serviceBox(IconData icon, String title, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))
            ],
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFF0F9D8A).withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: const Color(0xFF0F9D8A), size: 26),
              ),
              const SizedBox(height: 12),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
        ),
      ),
    );
  }
}