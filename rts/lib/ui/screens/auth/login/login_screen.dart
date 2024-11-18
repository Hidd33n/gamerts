// lib/ui/screens/login_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rts/data/serverconection.dart';

class LoginScreen extends StatefulWidget {
  final ServerConnection serverConnection;

  const LoginScreen({Key? key, required this.serverConnection})
      : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<Map<String, dynamic>>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.serverConnection.stream.listen(_handleServerMessage);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _handleServerMessage(Map<String, dynamic> data) {
    try {
      String action = data['action'];
      switch (action) {
        case 'login_success':
          String token = data['token'];
          _saveToken(token);
          // Navegar a MapScreen
          Navigator.pushReplacementNamed(context, '/map');
          break;
        case 'login_failure':
        case 'error':
          setState(() {
            _isLoading = false;
            _errorMessage = data['message'];
          });
          break;
        // Otros casos si es necesario
      }
    } catch (e, stackTrace) {
      print('Error en _handleServerMessage: $e');
      print(stackTrace);
    }
  }

  Future<void> _saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      widget.serverConnection.login(_username, _password);
    }
  }

  void _navigateToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Nombre de usuario'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu nombre de usuario';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _username = value;
                      },
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Contraseña'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu contraseña';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _password = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text('Iniciar Sesión'),
                    ),
                    TextButton(
                      onPressed: _navigateToRegister,
                      child: const Text('¿No tienes una cuenta? Regístrate'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
