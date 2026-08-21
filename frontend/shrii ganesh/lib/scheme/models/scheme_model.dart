import 'package:samvya/scheme/models/category_model.dart'; // Adjust import if needed

class GovernmentScheme {
  final String id;
  final String name;
  final String categoryId;
  final String ministry;
  final String description;
  final String? benefits;
  final String? applicationProcess;
  final String? requiredDocumentsText;
  final String? officialWebsite;
  final String? helpline;
  final String? faqText;
  final String? stateAvailability;
  final bool isActive;
  final String lastUpdatedDate;

  // Dynamically populated fields
  final bool? isEligible;
  final double? matchScore;
  final SchemeCategory? category;

  GovernmentScheme({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.ministry,
    required this.description,
    this.benefits,
    this.applicationProcess,
    this.requiredDocumentsText,
    this.officialWebsite,
    this.helpline,
    this.faqText,
    this.stateAvailability,
    required this.isActive,
    required this.lastUpdatedDate,
    this.isEligible,
    this.matchScore,
    this.category,
  });

  factory GovernmentScheme.fromJson(Map<String, dynamic> json) {
    return GovernmentScheme(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryId: json['category_id'] as String,
      ministry: json['ministry'] as String,
      description: json['description'] as String,
      benefits: json['benefits'] as String?,
      applicationProcess: json['application_process'] as String?,
      requiredDocumentsText: json['required_documents_text'] as String?,
      officialWebsite: json['official_website'] as String?,
      helpline: json['helpline'] as String?,
      faqText: json['faq_text'] as String?,
      stateAvailability: json['state_availability'] as String?,
      isActive: json['is_active'] as bool,
      lastUpdatedDate: json['last_updated_date'] as String,
      isEligible: json['is_eligible'] as bool?,
      matchScore: (json['match_score'] as num?)?.toDouble(),
      category: json['category'] != null 
          ? SchemeCategory.fromJson(json['category']) 
          : null,
    );
  }
}
