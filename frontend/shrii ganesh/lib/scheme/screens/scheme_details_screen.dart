import 'package:flutter/material.dart';
import 'package:samvya/scheme/models/scheme_model.dart';

class SchemeDetailsScreen extends StatelessWidget {
  final GovernmentScheme scheme;

  const SchemeDetailsScreen({super.key, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scheme Details"),
        backgroundColor: const Color(0xFF006B5F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF006B5F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                scheme.ministry,
                style: const TextStyle(color: Color(0xFF006B5F), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              scheme.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.3),
            ),
            const SizedBox(height: 24),
            _buildSection("Description", scheme.description),
            if (scheme.benefits != null) _buildSection("Benefits", scheme.benefits!),
            if (scheme.applicationProcess != null) _buildSection("Application Process", scheme.applicationProcess!),
            if (scheme.requiredDocumentsText != null) _buildSection("Required Documents", scheme.requiredDocumentsText!),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // In real app, open WebView or launch URL to scheme.officialWebsite
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Redirecting to Official Portal...")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006B5F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Apply Now / View Portal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }
}
