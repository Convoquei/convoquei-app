class UserModel {
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isEmailVerified;

  const UserModel({
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.isEmailVerified,
  });

  String get nameAbbreviation {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1]}';
    }
    return name;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        name: json['name'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'isEmailVerified': isEmailVerified,
      };
}