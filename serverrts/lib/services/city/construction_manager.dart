import 'package:serverrts/models/buildings/building.dart';
import 'package:serverrts/models/buildings/farm.dart';
import 'package:serverrts/models/buildings/harbor.dart';
import 'package:serverrts/models/buildings/sawmill.dart';
import 'package:serverrts/models/buildings/senate.dart';
import 'package:serverrts/models/buildings/wall.dart';
import 'package:serverrts/models/buildings/warehouse.dart';
import 'package:serverrts/models/city.dart';
import 'package:serverrts/services/core/db_services.dart';

import '../../models/buildings/silvermine.dart';

class ConstructionManager {
  /// Actualizar la cola de construcción
  static bool updateConstructionQueue(City city) {
    final now = DateTime.now();
    bool updated = false;

    city.constructionQueue.removeWhere((queueItem) {
      final finishTime = DateTime.parse(queueItem['finishTime']);
      if (now.isAfter(finishTime)) {
        final buildingName = queueItem['buildingName'];
        final level = queueItem['level'];

        final currentBuilding = city.buildings[buildingName];
        if (currentBuilding != null) {
          city.buildings[buildingName] =
              currentBuilding.upgrade(); // Mejorar el edificio
          updated = true;
        }
        return true; // Eliminar de la cola
      }
      return false; // Mantener en la cola
    });

    if (updated) {
      city.lastUpdated = now.toIso8601String();
      DbService.citiesCollection.updateOne(
        {'cityId': city.cityId},
        {'\$set': city.toMap()},
      );
    }

    return updated;
  }

  static Future<bool> cancelConstruction(City city, int queueIndex) async {
    if (queueIndex >= city.constructionQueue.length) return false;

    final queueItem = city.constructionQueue[queueIndex];
    final level = queueItem['level'];

    city.resources['wood'] =
        ((city.resources['wood'] ?? 0) + (level * 100 * 0.25)).toInt();
    city.resources['stone'] =
        ((city.resources['stone'] ?? 0) + (level * 80 * 0.25)).toInt();
    city.resources['silver'] =
        ((city.resources['silver'] ?? 0) + (level * 60 * 0.25)).toInt();

    city.constructionQueue.removeAt(queueIndex);

    await DbService.citiesCollection.updateOne(
      {'cityId': city.cityId},
      {'\$set': city.toMap()},
    );

    return true;
  }

  static Future<bool> upgradeBuilding(City city, String buildingName) async {
    final currentBuilding = city.buildings[buildingName];
    if (currentBuilding == null || city.constructionQueue.length >= 3) {
      return false; // Verificar que el edificio existe y que la cola no está llena
    }

    final nextLevel = currentBuilding.level + 1;
    if (nextLevel > currentBuilding.maxLevel) {
      return false; // El edificio ya está en el nivel máximo
    }

    final woodCost = nextLevel * 100;
    final stoneCost = nextLevel * 80;
    final silverCost = nextLevel * 60;

    if (!_hasEnoughResources(city, woodCost, stoneCost, silverCost)) {
      return false; // No hay suficientes recursos
    }

    // Reducir los recursos
    city.resources['wood'] = (city.resources['wood'] ?? 0) - woodCost;
    city.resources['stone'] = (city.resources['stone'] ?? 0) - stoneCost;
    city.resources['silver'] = (city.resources['silver'] ?? 0) - silverCost;

    // Calcular el tiempo de construcción
    final baseTime = currentBuilding.constructionTime;
    final reductionFactor = (city.buildings['Senado']?.level ?? 0) * 0.01;
    final finalTime = baseTime * (1 - reductionFactor);

    final startTime = DateTime.now();
    final finishTime = startTime.add(finalTime);

    city.constructionQueue.add({
      'buildingName': buildingName,
      'startTime': startTime.toIso8601String(),
      'finishTime': finishTime.toIso8601String(),
      'level': nextLevel,
    });

    // Actualizar en la base de datos
    await DbService.citiesCollection.updateOne(
      {'cityId': city.cityId},
      {'\$set': city.toMap()},
    );

    return true;
  }

  static Building? _createBuildingInstance(String name, int level) {
    switch (name) {
      case 'Senado':
        return Senate(level: level);
      case 'Aserradero':
        return Sawmill(level: level);
      case 'Mina de Plata':
        return SilverMine(level: level);
      case 'Muralla':
        return Wall(level: level);
      case 'Almacén':
        return Warehouse(level: level);
      case 'Puerto':
        return Harbor(level: level);
      case 'Granja':
        return Farm(level: level);
      default:
        return null;
    }
  }

  static bool _hasEnoughResources(City city, int wood, int stone, int silver) {
    return city.resources['wood']! >= wood &&
        city.resources['stone']! >= stone &&
        city.resources['silver']! >= silver;
  }
}
