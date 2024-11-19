// lib/services/unit_service.dart

import 'package:serverrts/models/city.dart';
import 'package:serverrts/services/core/db_services.dart';

class UnitService {
  /// Inicializar unidades en la base de datos
  static Future<void> initializeUnits() async {
    final units = [
      {
        'building': 'Barracks',
        'name': 'Infantry_X001',
        'attack': 12,
        'defense': {'arrows': 8, 'piercing': 6, 'swords': 10},
        'speed': 3,
        'cost': {'wood': 100, 'stone': 50, 'silver': 20},
        'trainingTime': 30,
      },
      {
        'building': 'Barracks',
        'name': 'Archer_X002',
        'attack': 15,
        'defense': {'arrows': 5, 'piercing': 3, 'swords': 4},
        'speed': 5,
        'cost': {'wood': 120, 'stone': 30, 'silver': 15},
        'trainingTime': 40,
      },
      {
        'building': 'Barracks',
        'name': 'Lancer_X003',
        'attack': 10,
        'defense': {'arrows': 7, 'piercing': 12, 'swords': 8},
        'speed': 4,
        'cost': {'wood': 80, 'stone': 100, 'silver': 25},
        'trainingTime': 50,
      },
      {
        'building': 'Harbor',
        'name': 'TransportShip_Y001',
        'attack': 0,
        'defense': {'arrows': 5, 'piercing': 5, 'swords': 5},
        'speed': 7,
        'cost': {'wood': 200, 'stone': 100, 'silver': 50},
        'trainingTime': 60,
      },
      {
        'building': 'Harbor',
        'name': 'FireShip_Y002',
        'attack': 20,
        'defense': {'arrows': 8, 'piercing': 6, 'swords': 7},
        'speed': 4,
        'cost': {'wood': 300, 'stone': 150, 'silver': 100},
        'trainingTime': 90,
      },
      {
        'building': 'Harbor',
        'name': 'BastionShip_Y003',
        'attack': 25,
        'defense': {'arrows': 15, 'piercing': 10, 'swords': 20},
        'speed': 3,
        'cost': {'wood': 400, 'stone': 200, 'silver': 150},
        'trainingTime': 120,
      },
    ];

    for (var unit in units) {
      await DbService.unitsCollection.updateOne(
        {'name': unit['name']},
        {'\$set': unit},
        upsert: true,
      );
    }

    print('UnitService: Unidades inicializadas.');
  }

  /// Crear una unidad y añadirla a la cola de entrenamiento
  static Future<bool> createUnit(
      City city, String buildingType, String unitName) async {
    final unitData = await DbService.unitsCollection
        .findOne({'building': buildingType, 'name': unitName});

    if (unitData == null) return false;

    // Verificar recursos
    final cost = unitData['cost'] as Map<String, dynamic>;
    if ((city.resources['wood'] ?? 0) < (cost['wood'] as int) ||
        (city.resources['stone'] ?? 0) < (cost['stone'] as int) ||
        (city.resources['silver'] ?? 0) < (cost['silver'] as int)) {
      return false;
    }

    // Reducir recursos
    city.resources['wood'] = (city.resources['wood']! - (cost['wood'] as int));
    city.resources['stone'] =
        (city.resources['stone']! - (cost['stone'] as int));
    city.resources['silver'] =
        (city.resources['silver']! - (cost['silver'] as int));

    // Añadir a la cola de entrenamiento
    final startTime = DateTime.now();
    final finishTime =
        startTime.add(Duration(seconds: unitData['trainingTime'] as int));

    city.trainingQueue.add({
      'unitName': unitName,
      'startTime': startTime.toIso8601String(),
      'finishTime': finishTime.toIso8601String(),
    });

    // Guardar ciudad en la base de datos
    await DbService.citiesCollection.updateOne(
      {'cityId': city.cityId},
      {'\$set': city.toMap()},
    );

    return true;
  }

  /// Procesar la cola de entrenamiento de una ciudad
  static void processTrainingQueue(City city) {
    final now = DateTime.now();

    city.trainingQueue.removeWhere((queueItem) {
      final finishTime = DateTime.parse(queueItem['finishTime']);
      if (now.isAfter(finishTime)) {
        city.units.add(queueItem['unitName']);
        return true;
      }
      return false;
    });

    DbService.citiesCollection.updateOne(
      {'cityId': city.cityId},
      {'\$set': city.toMap()},
    );
  }
}
