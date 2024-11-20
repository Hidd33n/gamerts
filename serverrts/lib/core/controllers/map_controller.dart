import 'package:serverrts/core/services/map/map_services.dart';

class MapController {
  final dynamic webSocket;

  MapController(this.webSocket);

  /// Manejar la solicitud para obtener el mapa
  Future<void> handleGetMap(Function(Map<String, dynamic>) send) async {
    try {
      // Obtener los datos del mapa desde la base de datos
      final mapData = await MapService.getMapData();

      if (mapData != null) {
        send({'action': 'map_data', 'data': mapData});
        print('Mapa enviado al cliente.');
      } else {
        print('No se encontró un mapa existente. Generando uno nuevo...');
        await MapService.generateMap(50, 10); // Tamaño 50x50, 10 islas
        final newMapData = await MapService.getMapData();
        if (newMapData != null) {
          send({'action': 'map_data', 'data': newMapData});
          print('Nuevo mapa generado y enviado al cliente.');
        } else {
          print('Error al generar un nuevo mapa.');
          send({'action': 'error', 'message': 'Mapa no disponible.'});
        }
      }
    } catch (e) {
      print('Error en handleGetMap: $e');
      send({'action': 'error', 'message': 'Error al obtener el mapa.'});
    }
  }

  /// Enviar datos al cliente
  void send(Map<String, dynamic> response) {
    webSocket.sink.add(response); // Se asume que webSocket maneja JSON
  }
}
