import 'package:serverrts/models/buildings/building.dart';
import 'package:serverrts/models/city.dart';
import 'package:serverrts/services/core/db_services.dart';

class ConstructionManager {
  /// Procesar la cola de construcción y actualizar edificios terminados
  static bool updateConstructionQueue(City city) {
    final now = DateTime.now();

    if (city.constructionQueue.isEmpty) return false;

    final currentConstruction = city.constructionQueue.first;
    final finishTime = DateTime.parse(currentConstruction['finishTime']);

    if (now.isAfter(finishTime)) {
      final buildingName = currentConstruction['buildingName'];

      // Mejorar el edificio
      final currentBuilding = city.buildings[buildingName];
      if (currentBuilding != null) {
        city.buildings[buildingName] = currentBuilding.upgrade();
      }

      // Eliminar de la cola
      city.constructionQueue.removeAt(0);

      // Actualizar en la base de datos
      DbService.citiesCollection.updateOne(
        {'cityId': city.cityId},
        {'\$set': city.toMap()},
      );

      return true;
    }

    return false;
  }

  /// Cancelar construcción en progreso
  static Future<bool> cancelConstruction(City city, int queueIndex) async {
    if (queueIndex >= city.constructionQueue.length) return false;

    final queueItem = city.constructionQueue[queueIndex];
    final level = queueItem['level'];

    // Devolver recursos proporcionalmente
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

  /// Iniciar una mejora de edificio
  static Future<bool> upgradeBuilding(City city, String buildingName) async {
    final currentBuilding = city.buildings[buildingName];
    if (currentBuilding == null || city.constructionQueue.length >= 3) {
      return false;
    }

    final nextLevel = currentBuilding.level + 1;
    if (nextLevel > currentBuilding.maxLevel) return false;

    final woodCost = nextLevel * 100;
    final stoneCost = nextLevel * 80;
    final silverCost = nextLevel * 60;

    if (!_hasEnoughResources(city, woodCost, stoneCost, silverCost)) {
      return false;
    }

// Reducir recursos asegurándote de que no sean null
    city.resources['wood'] = (city.resources['wood'] ?? 0) - woodCost;
    city.resources['stone'] = (city.resources['stone'] ?? 0) - stoneCost;
    city.resources['silver'] = (city.resources['silver'] ?? 0) - silverCost;

    // Calcular tiempo de construcción
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

    // Persistir cambios
    await DbService.citiesCollection.updateOne(
      {'cityId': city.cityId},
      {'\$set': city.toMap()},
    );

    return true;
  }

  /// Verificar si hay suficientes recursos
  static bool _hasEnoughResources(City city, int wood, int stone, int silver) {
    return city.resources['wood']! >= wood &&
        city.resources['stone']! >= stone &&
        city.resources['silver']! >= silver;
  }
}
