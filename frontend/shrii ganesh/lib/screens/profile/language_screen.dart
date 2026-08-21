import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Current active locale
    final currentLocale = context.locale;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("language.select_language".tr()),
        backgroundColor: const Color(0xFF0F9D8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLanguageOption(
                context, 
                title: "language.english".tr(), 
                localeCode: 'en',
                isSelected: currentLocale.languageCode == 'en',
              ),
              const SizedBox(height: 12),
              _buildLanguageOption(
                context, 
                title: "language.hindi".tr(), 
                localeCode: 'hi',
                isSelected: currentLocale.languageCode == 'hi',
              ),
              const SizedBox(height: 12),
              _buildLanguageOption(
                context, 
                title: "language.odia".tr(), 
                localeCode: 'or',
                isSelected: currentLocale.languageCode == 'or',
              ),
              const SizedBox(height: 12),
              _buildLanguageOption(
                context, 
                title: "language.tamil".tr(), 
                localeCode: 'ta',
                isSelected: currentLocale.languageCode == 'ta',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, {required String title, required String localeCode, required bool isSelected}) {
    return InkWell(
      onTap: () async {
        await context.setLocale(Locale(localeCode));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Language changed to $title"),
              backgroundColor: const Color(0xFF0F9D8A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F9D8A) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF0F9D8A).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF0F9D8A) : Colors.black87,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF0F9D8A)),
          ],
        ),
      ),
    );
  }
}
