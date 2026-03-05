class OrganizationGroupModel {
  final String id;
  final String name;
  final String emoji;
  final int participantCount;
  final DateTime createdAt;

  OrganizationGroupModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.participantCount,
    required this.createdAt,
  });

  factory OrganizationGroupModel.fromJson(Map<String, dynamic> json) {
    return OrganizationGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      participantCount: json['participantCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}