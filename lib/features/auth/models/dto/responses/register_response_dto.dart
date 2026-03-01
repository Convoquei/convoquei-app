class RegisterResponseDto {
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isEmailVerified;

  const RegisterResponseDto({
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.isEmailVerified,
  });

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) =>
      RegisterResponseDto(
        name: json['name'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      );
}

