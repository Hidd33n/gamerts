import 'package:serverrts/services/city/city_services.dart';
import 'package:serverrts/services/city/user_conection_manager.dart';
import 'package:serverrts/services/core/unit_services.dart';

class CityController {
  final dynamic webSocket;

  CityController(this.webSocket);

  Future<void> handleGetCity(
      String userId, Function(Map<String, dynamic>) send) async {
    try {
      var city = await CityService.getCityByUserId(userId);
      if (city == null) {
        city = await CityService.assignCityToPlayer(userId);
        if (city == null) {
          send({
            'action': 'error',
            'message': 'No se pudo asignar una ciudad al jugador.'
          });
          return;
        }
      }

      send({'action': 'city_data', 'data': city.toMap()});
    } catch (e) {
      print('CityController: Error in handleGetCity: $e');
      send({'action': 'error', 'message': 'Error al obtener la ciudad.'});
    }
  }

  Future<void> handleUpgradeBuilding(String userId, Map<String, dynamic> data,
      Function(Map<String, dynamic>) send) async {
    try {
      final buildingName = data['buildingName'] ?? '';
      final result = await CityService.upgradeBuilding(userId, buildingName);
      if (result) {
        send({'action': 'building_upgraded', 'buildingName': buildingName});
      } else {
        send({'action': 'error', 'message': 'No se pudo mejorar el edificio.'});
      }
    } catch (e) {
      print('Error en handleUpgradeBuilding: $e');
      send({'action': 'error', 'message': 'Error al mejorar el edificio.'});
    }
  }

  Future<void> handleTrainUnit(String userId, Map<String, dynamic> data,
      Function(Map<String, dynamic>) send) async {
    try {
      final unitName = data['unitName'];
      final buildingType = data['buildingType'];

      if (unitName == null || buildingType == null) {
        send({
          'action': 'error',
          'message':
              'Parámetros inválidos. Se requieren unitName y buildingType.'
        });
        return;
      }

      final city = await CityService.getCityByUserId(userId);
      if (city == null) {
        send({
          'action': 'error',
          'message': 'No se encontró la ciudad del jugador.'
        });
        return;
      }

      final success =
          await UnitService.createUnit(city, buildingType, unitName);
      if (success) {
        send({
          'action': 'unit_training_started',
          'unitName': unitName,
          'message': 'Entrenamiento de unidad iniciado con éxito.'
        });
      } else {
        send({
          'action': 'error',
          'message': 'Entrenamiento fallido. Verifica recursos o cola.'
        });
      }
    } catch (e) {
      print('CityController: Error en handleTrainUnit: $e');
      send({
        'action': 'error',
        'message': 'Error interno al entrenar la unidad.'
      });
    }
  }

  Future<void> handleCancelConstruction(String userId,
      Map<String, dynamic> data, Function(Map<String, dynamic>) send) async {
    try {
      final queueIndex = data['queueIndex'] as int;
      final result = await CityService.cancelConstruction(userId, queueIndex);
      if (result) {
        send({'action': 'construction_cancelled', 'queueIndex': queueIndex});
      } else {
        send({
          'action': 'error',
          'message': 'No se pudo cancelar la construcción.'
        });
      }
    } catch (e) {
      print('Error en handleCancelConstruction: $e');
      send(
          {'action': 'error', 'message': 'Error al cancelar la construcción.'});
    }
  }

  void handleUserDisconnect(String userId) {
    CityService.handleUserDisconnect(userId);
  }
}
