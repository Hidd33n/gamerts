import 'package:serverrts/core/services/core/db_services.dart';
import 'package:serverrts/models/alliance/alliance.dart';

class AllianceService {
  /// Crear una nueva alianza
  static Future<bool> createAlliance(
      String leaderId, String name, String description) async {
    final existingAlliance =
        await DbService.alliancesCollection.findOne({'name': name});
    if (existingAlliance != null) return false; // El nombre ya está en uso

    final alliance = Alliance(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      leaderId: leaderId,
      members: [leaderId],
      createdAt: DateTime.now(),
    );

    await DbService.alliancesCollection.insertOne(alliance.toMap());
    return true;
  }

  /// Unirse a una alianza
  static Future<bool> joinAlliance(String playerId, String allianceId) async {
    final alliance =
        await DbService.alliancesCollection.findOne({'id': allianceId});
    if (alliance == null) return false;

    if ((alliance['members'] as List).contains(playerId))
      return false; // Ya es miembro

    alliance['members'].add(playerId);

    await DbService.alliancesCollection.updateOne(
      {'id': allianceId},
      {
        '\$set': {'members': alliance['members']}
      },
    );
    return true;
  }

  /// Salir de una alianza
  static Future<bool> leaveAlliance(String playerId, String allianceId) async {
    final alliance =
        await DbService.alliancesCollection.findOne({'id': allianceId});
    if (alliance == null) return false;

    alliance['members'].remove(playerId);

    // Si el líder abandona, se asigna un nuevo líder o se disuelve la alianza
    if (alliance['leaderId'] == playerId) {
      if (alliance['members'].isEmpty) {
        await DbService.alliancesCollection.deleteOne({'id': allianceId});
        return true; // Alianza disuelta
      }
      alliance['leaderId'] = alliance['members'].first;
    }

    await DbService.alliancesCollection.updateOne(
      {'id': allianceId},
      {'\$set': alliance},
    );
    return true;
  }

  /// Obtener una lista de alianzas
  static Future<List<Alliance>> getAllAlliances() async {
    final alliances = await DbService.alliancesCollection.find().toList();
    return alliances.map((map) => Alliance.fromMap(map)).toList();
  }
}
