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

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        name: json['name'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      );
}