import 'dart:async';
import 'package:serverrts/models/city.dart';
import 'package:serverrts/services/city/assignament_manager.dart';
import 'package:serverrts/services/city/construction_manager.dart';
import 'package:serverrts/services/city/user_conection_manager.dart';
import 'package:serverrts/services/core/db_services.dart';
import 'package:serverrts/services/core/socket_services.dart';

class CityService {
  static final Map<String, City> cityCache = {};

  /// Obtener ciudad por userId
  static Future<City?> getCityByUserId(String userId) async {
    final cityMap =
        await DbService.citiesCollection.findOne({'ownerId': userId});
    if (cityMap == null) return null;

    final city = City.fromMap(cityMap);
    cityCache[userId] = city;
    return city;
  }

  /// Asignar nueva ciudad
  static Future<City?> assignCityToPlayer(String userId) async {
    final city = await AssignmentManager.assignCityToPlayer(userId);
    if (city != null) cityCache[userId] = city;
    return city;
  }

  /// Mejorar un edificio
  static Future<bool> upgradeBuilding(
      String userId, String buildingName) async {
    final city = cityCache[userId] ?? await getCityByUserId(userId);
    if (city == null) return false;
    return await ConstructionManager.upgradeBuilding(city, buildingName);
  }

  /// Cancelar construcción
  static Future<bool> cancelConstruction(String userId, int queueIndex) async {
    final city = cityCache[userId] ?? await getCityByUserId(userId);
    if (city == null) return false;
    return await ConstructionManager.cancelConstruction(city, queueIndex);
  }

  /// Manejar actualizaciones de la ciudad

  /// Enviar actualización de la ciudad
  static void sendCityUpdate(String userId, City city) {
    SocketService.sendToUser(
      userId,
      {'action': 'city_update', 'data': city.toMap()},
    );
  }

  /// Manejar desconexión del usuario
  static void handleUserDisconnect(String userId) {
    UserConnectionManager.stopUpdates(userId);
    cityCache.remove(userId);
  }
}
