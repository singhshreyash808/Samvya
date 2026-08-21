import 'package:flutter/material.dart';
import 'package:samvya/scheme/models/scheme_model.dart';
import 'package:samvya/scheme/services/scheme_service.dart';
import 'package:samvya/scheme/screens/scheme_details_screen.dart';
import 'package:samvya/scheme/screens/ai_assistant_chat_screen.dart';

class SchemeDashboardScreen extends StatefulWidget {
  const SchemeDashboardScreen({super.key});

  @override
  State<SchemeDashboardScreen> createState() => _SchemeDashboardScreenState();
}

class _SchemeDashboardScreenState extends State<SchemeDashboardScreen> {
  final SchemeService _schemeService = SchemeService();
  bool _isLoading = true;
  List<GovernmentScheme> _recommendedSchemes = [];
  List<GovernmentScheme> _allSchemes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        _schemeService.getRecommendations(),
        _schemeService.getSchemes(),
      ]);
      _recommendedSchemes = futures[0] as List<GovernmentScheme>;
      _allSchemes = futures[1] as List<GovernmentScheme>;
    } catch (e) {
      print("Error loading dashboard data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Government Schemes"),
        backgroundColor: const Color(0xFF006B5F), // Samvya theme color
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: "AI Assistant",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiAssistantChatScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF006B5F)))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF006B5F),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 24),
                  
                  if (_recommendedSchemes.isNotEmpty) ...[
                    const Text(
                      "Recommended For You",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildHorizontalList(_recommendedSchemes),
                    const SizedBox(height: 24),
                  ],

                  const Text(
                    "Explore All Schemes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._allSchemes.map((s) => _buildSchemeCard(s)).toList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiAssistantChatScreen()),
          );
        },
        backgroundColor: const Color(0xFF006B5F),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.smart_toy),
        label: const Text("Ask AI"),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF006B5F), Color(0xFF009B8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Discover Your Benefits",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Find and apply for government welfare schemes easily. Let our AI assistant guide you.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<GovernmentScheme> schemes) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: schemes.length,
        itemBuilder: (context, index) {
          final scheme = schemes[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SchemeDetailsScreen(scheme: scheme)),
              );
            },
            child: Container(
              width: 240,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006B5F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      scheme.category?.name ?? "Welfare",
                      style: const TextStyle(fontSize: 10, color: Color(0xFF006B5F), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    scheme.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "${scheme.matchScore?.toInt() ?? 80}% Match",
                        style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSchemeCard(GovernmentScheme scheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(scheme.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            scheme.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SchemeDetailsScreen(scheme: scheme)),
          );
        },
      ),
    );
  }
}
