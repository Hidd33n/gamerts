// lib/controllers/auth_controller.dart

import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:serverrts/models/user.dart';
import 'package:serverrts/core/services/core/db_services.dart';
import 'package:serverrts/utils/jwt.dart';
import 'package:uuid/uuid.dart';

class AuthController {
  final Uuid uuid = Uuid();

  Future<void> handleMessage(Map<String, dynamic> data, Function send) async {
    String action = data['action'];

    switch (action) {
      case 'register':
        await _handleRegister(data, send);
        break;
      case 'login':
        await _handleLogin(data, send);
        break;
      default:
        send({'action': 'error', 'message': 'Acción no reconocida.'});
        break;
    }
  }

  Future<void> _handleRegister(Map<String, dynamic> data, Function send) async {
    String username = data['username'];
    String email = data['email'];
    String password = data['password'];

    // Validar los datos de entrada
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      send({
        'action': 'register_failure',
        'message': 'Todos los campos son obligatorios.'
      });
      return;
    }

    try {
      // Verificar si el usuario o el email ya existen
      var existingUser = await DbService.usersCollection.findOne({
        '\$or': [
          {'username': username},
          {'email': email}
        ]
      });

      if (existingUser != null) {
        send({
          'action': 'register_failure',
          'message': 'El nombre de usuario o email ya está en uso.'
        });
        return;
      }

      // Generar hash de la contraseña
      String passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

      // Crear el nuevo usuario
      var userId = uuid.v4();
      var newUser = User(
        userId: userId,
        username: username,
        email: email,
        passwordHash: passwordHash,
      );

      // Intentar insertar en la base de datos
      await DbService.usersCollection.insert(newUser.toMap());

      // Enviar respuesta de éxito al cliente
      send({'action': 'register_success', 'userId': userId});
    } catch (e, stacktrace) {
      print('Error al registrar usuario: $e');
      print(stacktrace);
      send({
        'action': 'register_failure',
        'message': 'Error interno del servidor.'
      });
    }
  }

  Future<void> _handleLogin(Map<String, dynamic> data, Function send) async {
    String username = data['username'];
    String password = data['password'];

    // Validar los datos de entrada
    if (username.isEmpty || password.isEmpty) {
      send({
        'action': 'login_failure',
        'message': 'Todos los campos son obligatorios.'
      });
      return;
    }

    // Buscar al usuario por nombre de usuario
    var userMap =
        await DbService.usersCollection.findOne({'username': username});

    if (userMap == null) {
      send({
        'action': 'login_failure',
        'message': 'Usuario o contraseña incorrectos.'
      });
      return;
    }

    var user = User.fromMap(userMap);

    // Verificar la contraseña
    if (!BCrypt.checkpw(password, user.passwordHash)) {
      send({
        'action': 'login_failure',
        'message': 'Usuario o contraseña incorrectos.'
      });
      return;
    }

    // Generar token de sesión (JWT)
    String token = JwtUtils.generateToken(user.userId, user.username);

    // Enviar respuesta de éxito al cliente con el token
    send({'action': 'login_success', 'token': token});
  }
}
