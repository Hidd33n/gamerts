// lib/utils/jwt_utils.dart

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtUtils {
  static const String _secretKey = 'TU_CLAVE_SECRETA_AQUÍ';

  static String generateToken(String userId, String username) {
    final jwt = JWT(
      {
        'userId': userId,
        'username': username,
      },
      issuer: 'game_server',
    );

    return jwt.sign(
      SecretKey(_secretKey),
      expiresIn: const Duration(hours: 24),
    );
  }

  static Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secretKey));
      return jwt.payload as Map<String, dynamic>;
    } on JWTExpiredException {
      print('Token JWT expirado');
      return null;
    } on JWTException catch (ex) {
      print('Error JWT: $ex');
      return null;
    }
  }
}
