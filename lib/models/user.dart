class User {
  const User({
    required this.id,
    required this.email,
  });

  final int id;
  final String email;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse('${json['id']}') ?? 0,
      email: (json['email'] ?? '').toString(),
    );
  }
}

class AuthToken {
  const AuthToken({
    required this.accessToken,
    this.tokenType = 'bearer',
  });

  final String accessToken;
  final String tokenType;

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: (json['access_token'] ?? '').toString(),
      tokenType: (json['token_type'] ?? 'bearer').toString(),
    );
  }
}
