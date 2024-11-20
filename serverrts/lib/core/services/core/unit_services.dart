// lib/services/unit_service.dart

import 'package:serverrts/models/city.dart';
import 'package:serverrts/core/services/core/db_services.dart';

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

  static void processTrainingQueue(City city) {
    final now = DateTime.now();

    city.trainingQueue.removeWhere((queueItem) {
      final finishTime = DateTime.parse(queueItem['finishTime']);
      if (now.isAfter(finishTime)) {
        final unitName = queueItem['unitName'] as String;
        final quantity = queueItem['quantity'] as int;

        // Actualizar la cantidad de unidades entrenadas
        city.units[unitName] = (city.units[unitName] ?? 0) + quantity;

        return true; // Eliminar de la cola de entrenamiento
      }
      return false; // Mantener en la cola
    });

    // Persistir los cambios en la base de datos
    DbService.citiesCollection.updateOne(
      {'cityId': city.cityId},
      {'\$set': city.toMap()},
    );
  }

  static Future<bool> createUnit(
      City city, String buildingType, String unitName, int quantity) async {
    final unitData = await DbService.unitsCollection
        .findOne({'building': buildingType, 'name': unitName});

    if (unitData == null) return false;

    final cost = unitData['cost'] as Map<String, dynamic>;
    final totalCost = {
      'wood': cost['wood'] * quantity,
      'stone': cost['stone'] * quantity,
      'silver': cost['silver'] * quantity,
    };

    // Verificar recursos
    if (city.resources['wood']! < totalCost['wood'] ||
        city.resources['stone']! < totalCost['stone'] ||
        city.resources['silver']! < totalCost['silver']) {
      return false;
    }

// Reducir recursos
    city.resources['wood'] =
        (city.resources['wood'] ?? 0) - (totalCost['wood'] as int);
    city.resources['stone'] =
        (city.resources['stone'] ?? 0) - (totalCost['stone'] as int);
    city.resources['silver'] =
        (city.resources['silver'] ?? 0) - (totalCost['silver'] as int);

    // Calcular tiempo de entrenamiento
    final baseTime = unitData['trainingTime'];
    final totalTime = baseTime * quantity;

    final startTime = DateTime.now();
    final finishTime = startTime.add(Duration(seconds: totalTime));

    // Añadir a la cola
    city.trainingQueue.add({
      'unitName': unitName,
      'quantity': quantity,
      'startTime': startTime.toIso8601String(),
      'finishTime': finishTime.toIso8601String(),
    });

    // Persistir cambios
    await DbService.citiesCollection.updateOne(
      {'cityId': city.cityId},
      {'\$set': city.toMap()},
    );

    return true;
  }
}
