import 'package:serverrts/models/city.dart';
import 'package:serverrts/models/tech/tech.dart';
import 'package:serverrts/core/services/city/city_services.dart';
import 'package:serverrts/core/services/city/user_conection_manager.dart';
import 'package:serverrts/core/services/core/battle_services.dart';
import 'package:serverrts/core/services/core/db_services.dart';
import 'package:serverrts/core/services/core/unit_services.dart';

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
      final quantity = data['quantity'];

      if (unitName == null || buildingType == null || quantity == null) {
        send({
          'action': 'error',
          'message':
              'Parámetros inválidos. Se requieren unitName, buildingType y quantity.'
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
          await UnitService.createUnit(city, buildingType, unitName, quantity);
      if (success) {
        send({
          'action': 'unit_training_started',
          'unitName': unitName,
          'quantity': quantity,
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

  static Future<bool> cancelTraining(City city, int queueIndex) async {
    if (queueIndex >= city.trainingQueue.length) return false;

    final queueItem = city.trainingQueue[queueIndex];
    final String unitName = queueItem['unitName'] as String;
    final int quantity = (queueItem['quantity'] ?? 1) as int;

    // Buscar datos de la unidad
    final unitData =
        await DbService.unitsCollection.findOne({'name': unitName});
    if (unitData == null) return false;

    final Map<String, dynamic> cost = unitData['cost'] as Map<String, dynamic>;

    // Convertir valores a int de manera explícita
    final int woodCost = (cost['wood'] as num).toInt();
    final int stoneCost = (cost['stone'] as num).toInt();
    final int silverCost = (cost['silver'] as num).toInt();

    // Sumar recursos, asegurándonos que `city.resources` sea consistente
    city.resources['wood'] =
        ((city.resources['wood'] ?? 0) + (woodCost * quantity)).toInt();
    city.resources['stone'] =
        ((city.resources['stone'] ?? 0) + (stoneCost * quantity)).toInt();
    city.resources['silver'] =
        ((city.resources['silver'] ?? 0) + (silverCost * quantity)).toInt();

    // Remover de la cola
    city.trainingQueue.removeAt(queueIndex);

    // Persistir cambios
    await DbService.citiesCollection.updateOne(
      {'cityId': city.cityId},
      {'\$set': city.toMap()},
    );

    return true;
  }

  Future<void> handleBattle(String userId, Map<String, dynamic> data,
      Function(Map<String, dynamic>) send) async {
    try {
      final targetCityId = data['targetCityId'];
      final attackingUnits = Map<String, int>.from(data['attackingUnits']);

      final attackerCity = await CityService.getCityByUserId(userId);
      if (attackerCity == null) {
        send({'action': 'error', 'message': 'Ciudad atacante no encontrada.'});
        return;
      }

      final defenderCity = await CityService.getCityByCityId(
          targetCityId); // Implementa esta función
      if (defenderCity == null) {
        send({'action': 'error', 'message': 'Ciudad defensora no encontrada.'});
        return;
      }

      final battle = await BattleService.initiateBattle(
          attackerCity, defenderCity, attackingUnits);

      send({
        'action': 'battle_result',
        'result': battle.result,
        'battleDetails': battle.toMap(),
      });
    } catch (e) {
      print('Error en handleBattle: $e');
      send({
        'action': 'error',
        'message': 'Error interno al iniciar la batalla.'
      });
    }
  }

  static void processResearchQueue(City city) {
    final now = DateTime.now();

    city.trainingQueue.removeWhere((queueItem) {
      if (queueItem['type'] == 'Research') {
        final finishTime = DateTime.parse(queueItem['finishTime']);
        if (now.isAfter(finishTime)) {
          city.technologies.add(queueItem['technology']);
          return true;
        }
      }
      return false;
    });

    DbService.citiesCollection.updateOne(
      {'cityId': city.cityId},
      {'\$set': city.toMap()},
    );
  }
}
