import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dashboard_screen.dart';
import 'money_screen.dart';
import 'scan_screen.dart';
import 'gov_schemes_screen.dart';
import 'profile_screen.dart';
import '../../widgets/voice_assistant_overlay.dart';
import '../../utils/session_manager.dart';
import '../mpin/verify_mpin_screen.dart';
import '../../services/bank_account_service.dart';
import 'qr_scan_screen.dart';
import 'transfer_money_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int currentIndex = 0;

  final pages = [
    const DashboardScreen(),
    const MoneyScreen(),
    const ScanScreen(),
    const GovSchemesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    SessionManager().initialize(() {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const VerifyMpinScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    SessionManager().stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => SessionManager().resetSession(),
      child: PopScope(
        canPop: currentIndex == 0,
        onPopInvoked: (didPop) {
          if (!didPop) {
            setState(() {
              currentIndex = 0;
            });
          }
        },
        child: Scaffold(
          body: pages[currentIndex],

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              VoiceAssistantOverlay.show(
                context,
                onNavigate: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              );
            },
            backgroundColor: const Color(0xFF0F9D8A),
            child: const Icon(Icons.mic, color: Colors.white),
          ),

          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,

            onTap: (index) async {
              if (index == 2) {
                // Launch the QR Scanner instead of switching to a placeholder tab
                final scannedCode = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QRScanScreen()),
                );

                if (scannedCode != null && scannedCode is String && mounted) {
                  final accounts = await BankAccountService().getAccounts();
                  if (accounts.isNotEmpty && mounted) {
                    String recipientAccount = scannedCode;
                    String recipientName = "";
                    if (scannedCode.startsWith("upi://pay")) {
                      final uri = Uri.tryParse(scannedCode);
                      if (uri != null) {
                        recipientAccount =
                            uri.queryParameters['pa'] ?? scannedCode;
                        recipientName = uri.queryParameters['pn'] ?? "";
                      }
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransferMoneyScreen(
                          senderAccount: accounts.first,
                          initialRecipientAccount: recipientAccount,
                          initialRecipientName: recipientName,
                        ),
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please link a bank account first."),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
                return;
              }

              setState(() {
                currentIndex = index;
              });
            },

            type: BottomNavigationBarType.fixed,

            selectedItemColor: const Color(0xFF0F9D8A),
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,

            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),

            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: "nav_home".tr(),
              ),

              BottomNavigationBarItem(
                icon: const Icon(Icons.currency_rupee),
                label: "nav_money".tr(),
              ),

              BottomNavigationBarItem(
                icon: const Icon(Icons.qr_code_scanner),
                label: "nav_scan".tr(),
              ),

              BottomNavigationBarItem(
                icon: const Icon(Icons.account_balance),
                label: "nav_gov_schemes".tr(),
              ),

              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: "nav_you".tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
