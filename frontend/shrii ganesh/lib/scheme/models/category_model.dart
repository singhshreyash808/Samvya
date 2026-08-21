class SchemeCategory {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;

  SchemeCategory({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
  });

  factory SchemeCategory.fromJson(Map<String, dynamic> json) {
    return SchemeCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
    );
  }
}
