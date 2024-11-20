import 'package:serverrts/core/services/alliances/alliances_services.dart';

class AllianceController {
  /// Crear una nueva alianza
  Future<void> handleCreateAlliance(String userId, Map<String, dynamic> data,
      Function(Map<String, dynamic>) send) async {
    final name = data['name'];
    final description = data['description'];

    if (name == null || description == null) {
      send({'action': 'error', 'message': 'Faltan parámetros.'});
      return;
    }

    final success =
        await AllianceService.createAlliance(userId, name, description);
    if (success) {
      send({
        'action': 'alliance_created',
        'message': 'Alianza creada exitosamente.'
      });
    } else {
      send({'action': 'error', 'message': 'El nombre ya está en uso.'});
    }
  }

  /// Unirse a una alianza
  Future<void> handleJoinAlliance(String userId, Map<String, dynamic> data,
      Function(Map<String, dynamic>) send) async {
    final allianceId = data['allianceId'];

    if (allianceId == null) {
      send({'action': 'error', 'message': 'Faltan parámetros.'});
      return;
    }

    final success = await AllianceService.joinAlliance(userId, allianceId);
    if (success) {
      send({'action': 'joined_alliance', 'message': 'Te uniste a la alianza.'});
    } else {
      send({'action': 'error', 'message': 'No se pudo unir a la alianza.'});
    }
  }

  /// Salir de una alianza
  Future<void> handleLeaveAlliance(String userId, Map<String, dynamic> data,
      Function(Map<String, dynamic>) send) async {
    final allianceId = data['allianceId'];

    if (allianceId == null) {
      send({'action': 'error', 'message': 'Faltan parámetros.'});
      return;
    }

    final success = await AllianceService.leaveAlliance(userId, allianceId);
    if (success) {
      send({'action': 'left_alliance', 'message': 'Saliste de la alianza.'});
    } else {
      send({'action': 'error', 'message': 'No se pudo salir de la alianza.'});
    }
  }

  /// Obtener todas las alianzas
  Future<void> handleGetAlliances(Function(Map<String, dynamic>) send) async {
    final alliances = await AllianceService.getAllAlliances();
    send({
      'action': 'alliances_list',
      'data': alliances.map((a) => a.toMap()).toList()
    });
  }
}
