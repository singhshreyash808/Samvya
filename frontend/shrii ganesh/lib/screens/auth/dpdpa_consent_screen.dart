import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/local_storage_service.dart';
import '../mpin/create_mpin_screen.dart';

class DpdpaConsentScreen extends StatefulWidget {
  const DpdpaConsentScreen({super.key});

  @override
  State<DpdpaConsentScreen> createState() => _DpdpaConsentScreenState();
}

class _DpdpaConsentScreenState extends State<DpdpaConsentScreen> {
  bool _agreed = false;
  bool _isLoading = false;


  Future<void> _onAccept() async {
    if (!_agreed) return;
    setState(() => _isLoading = true);
    await LocalStorageService.setConsentGiven();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CreateMpinScreen()),
    );
  }

  void _onDecline() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('consent.sure_title'.tr()),
        content: Text('consent.sure_msg'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('consent.stay'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).popUntil((route) => false);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('consent.exit'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageChip(String label, String code) {
    final current = context.locale.languageCode == code;
    return GestureDetector(
      onTap: () async => await context.setLocale(Locale(code)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: current ? const Color(0xFF0F9D8A) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: current ? Colors.white : Colors.black87,
            fontWeight: current ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dataPoints = [
      {'icon': Icons.person_outline, 'text': 'consent.collect_1'.tr()},
      {'icon': Icons.phone_android_outlined, 'text': 'consent.collect_2'.tr()},
      {'icon': Icons.location_on_outlined, 'text': 'consent.collect_3'.tr()},
      {'icon': Icons.fingerprint, 'text': 'consent.collect_4'.tr()},
      {'icon': Icons.notifications_outlined, 'text': 'consent.collect_5'.tr()},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF063B34), Color(0xFF0F9D8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language selector chips
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildLanguageChip('EN', 'en'),
                      _buildLanguageChip('हिं', 'hi'),
                      _buildLanguageChip('ଓଡ଼', 'or'),
                      _buildLanguageChip('தமி', 'ta'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Icon(Icons.security_outlined, color: Colors.white70, size: 36),
                  const SizedBox(height: 10),
                  Text(
                    'consent.title'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'consent.subtitle'.tr(),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('consent.what_we_collect'.tr()),
                    const SizedBox(height: 12),
                    ...dataPoints.map((d) => _dataItem(d['icon'] as IconData, d['text'] as String)),

                    const SizedBox(height: 24),
                    _sectionTitle('consent.why_we_collect'.tr()),
                    const SizedBox(height: 12),
                    _textCard('consent.why_desc'.tr()),

                    const SizedBox(height: 24),
                    _sectionTitle('consent.rights'.tr()),
                    const SizedBox(height: 12),
                    _textCard('consent.rights_desc'.tr()),

                    const SizedBox(height: 28),

                    // Agreement checkbox
                    GestureDetector(
                      onTap: () => setState(() => _agreed = !_agreed),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _agreed ? const Color(0xFF0F9D8A).withOpacity(0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _agreed ? const Color(0xFF0F9D8A) : Colors.grey.shade300,
                            width: _agreed ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _agreed ? const Color(0xFF0F9D8A) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _agreed ? const Color(0xFF0F9D8A) : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: _agreed
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'consent.agreement'.tr(),
                                style: const TextStyle(fontSize: 13.5, height: 1.5, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _agreed && !_isLoading ? _onAccept : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F9D8A),
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : Text(
                                'consent.agree_btn'.tr(),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: _onDecline,
                        child: Text(
                          'consent.decline_btn'.tr(),
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF063B34)),
      );

  Widget _dataItem(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF0F9D8A), size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4))),
          ],
        ),
      );

  Widget _textCard(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(text, style: const TextStyle(fontSize: 13.5, height: 1.6, color: Colors.black87)),
      );
}
