class LoginResponseDto {
  final String accessToken;
  final String refreshToken;

  const LoginResponseDto({
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      LoginResponseDto(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );
}

