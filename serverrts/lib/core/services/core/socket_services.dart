import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  static final Map<String, WebSocketChannel> _connectedClients = {};

  /// Registrar un cliente cuando se conecta
  static void registerClient(String userId, WebSocketChannel channel) {
    _connectedClients[userId]?.sink.close(); // Cerrar conexiones anteriores
    _connectedClients[userId] = channel;
  }

  /// Eliminar un cliente cuando se desconecta
  static void unregisterClient(String userId) {
    _connectedClients[userId]?.sink.close();
    _connectedClients.remove(userId);
  }

  /// Enviar un mensaje a un cliente específico
  static void sendToUser(String userId, Map<String, dynamic> message) {
    final channel = _connectedClients[userId];
    if (channel != null) {
      try {
        channel.sink.add(jsonEncode(message));
      } catch (e) {
        unregisterClient(userId);
      }
    }
  }

  /// Enviar un mensaje a todos los clientes conectados
  static void broadcast(Map<String, dynamic> message) {
    final encodedMessage = jsonEncode(message);
    _connectedClients.forEach((userId, channel) {
      try {
        channel.sink.add(encodedMessage);
      } catch (e) {
        unregisterClient(userId);
      }
    });
  }
}
