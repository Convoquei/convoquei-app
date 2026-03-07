class OrganizationFunctionModel {
  final String id;
  final String name;
  final String emoji;
  final int memberCount;
  final DateTime createdAt;

  OrganizationFunctionModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.memberCount,
    required this.createdAt,
  });

  OrganizationFunctionModel copyWith({int? memberCount}) {
    return OrganizationFunctionModel(
      id: id,
      name: name,
      emoji: emoji,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt,
    );
  }

  factory OrganizationFunctionModel.fromJson(Map<String, dynamic> json) {
    return OrganizationFunctionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      memberCount: json['memberCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
