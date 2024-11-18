// lib/models/user.dart

class User {
  final String userId;
  final String username;
  final String email;
  final String passwordHash;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.passwordHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'],
      username: map['username'],
      email: map['email'],
      passwordHash: map['passwordHash'],
    );
  }
}
