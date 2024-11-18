import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServerConnection {
  // Singleton: Instancia única
  static final ServerConnection _instance = ServerConnection._internal();

  // Constructor privado
  ServerConnection._internal();

  // Factory constructor para obtener la instancia única
  factory ServerConnection() {
    return _instance;
  }

  late IOWebSocketChannel _channel; // Inicializado en connect()
  bool _isConnected = false; // Bandera para verificar si ya está conectado
  final _storage = const FlutterSecureStorage();
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  void connect() {
    // Verificar si ya está conectado para evitar múltiples conexiones
    if (_isConnected) return;

    _channel = IOWebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8080'));
    _isConnected = true; // Marcar como conectado

    _channel.stream.listen(
      (message) {
        final data = jsonDecode(message);
        print("Mensaje recibido en ServerConnection: $data");
        _controller.add(data);
      },
      onDone: () {
        print('Conexión cerrada. Intentando reconectar...');
        _isConnected = false;
        _reconnect(); // Intentar reconectar si la conexión se cierra
      },
      onError: (error) {
        print('Error en la conexión: $error');
        _isConnected = false;
        _reconnect(); // Intentar reconectar si ocurre un error
      },
    );
  }

  void _reconnect() async {
    await Future.delayed(
        const Duration(seconds: 5)); // Esperar antes de reconectar
    connect(); // Reconectar al servidor
  }

  void disconnect() {
    if (_isConnected) {
      _channel.sink.close();
      _controller.close();
      _isConnected = false;
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    if (!_isConnected) {
      throw StateError(
          'WebSocket no está conectado. Llama a connect() primero.');
    }
    _channel.sink.add(jsonEncode(message));
  }

  Future<void> register(String username, String email, String password) async {
    sendMessage({
      'action': 'register',
      'username': username,
      'email': email,
      'password': password,
    });
  }

  Future<void> login(String username, String password) async {
    sendMessage({
      'action': 'login',
      'username': username,
      'password': password,
    });
  }

  Future<void> getMap() async {
    String? token = await _storage.read(key: 'auth_token');
    sendMessage({
      'action': 'get_map',
      'token': token,
    });
  }

  Future<Map<String, dynamic>> getCity() async {
    if (!_isConnected) {
      throw StateError(
          'WebSocket no está conectado. Llama a connect() primero.');
    }

    String? token = await _storage.read(key: 'auth_token');
    final completer = Completer<Map<String, dynamic>>();

    // Escuchar la respuesta del servidor
    StreamSubscription? subscription;
    subscription = stream.listen((data) {
      if (data['action'] == 'city_data') {
        completer.complete(data['data']);
        subscription?.cancel();
      }
    });

    sendMessage({
      'action': 'get_city',
      'token': token,
    });

    return completer.future;
  }

  Future<void> upgradeBuilding(String buildingName) async {
    if (!_isConnected) {
      throw StateError(
          'WebSocket no está conectado. Llama a connect() primero.');
    }

    String? token = await _storage.read(key: 'auth_token');
    sendMessage({
      'action': 'upgrade_building',
      'token': token,
      'buildingName': buildingName,
    });
  }

  Future<void> cancelConstruction(int queueIndex) async {
    if (!_isConnected) {
      throw StateError(
          'WebSocket no está conectado. Llama a connect() primero.');
    }

    String? token = await _storage.read(key: 'auth_token');
    sendMessage({
      'action': 'cancel_construction',
      'token': token,
      'queueIndex': queueIndex,
    });
  }
}
