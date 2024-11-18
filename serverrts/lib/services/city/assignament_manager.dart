import 'package:serverrts/models/buildings/barracks.dart';
import 'package:serverrts/models/buildings/farm.dart';
import 'package:serverrts/models/buildings/quarry.dart';
import 'package:serverrts/models/buildings/sawmill.dart';
import 'package:serverrts/models/buildings/senate.dart';
import 'package:serverrts/models/buildings/silvermine.dart';
import 'package:serverrts/models/buildings/warehouse.dart';
import 'package:serverrts/models/city.dart';
import 'package:serverrts/models/island.dart';
import 'package:serverrts/services/core/db_services.dart';
import 'package:uuid/uuid.dart';

class AssignmentManager {
  static final Uuid uuid = Uuid();

  /// Obtener ciudad desde la base de datos
  static Future<City?> getCityFromDatabase(String userId) async {
    final cityMap =
        await DbService.citiesCollection.findOne({'ownerId': userId});
    return cityMap != null ? City.fromMap(cityMap) : null;
  }

  /// Asignar nueva ciudad a un jugador
  static Future<City?> assignCityToPlayer(String userId) async {
    final islandMap = await DbService.islandsCollection.findOne({
      'slots': {
        '\$elemMatch': {'\$eq': null}
      },
    });

    if (islandMap == null) {
      print("AssignmentManager: No available island slots for user $userId");
      return null;
    }

    final island = Island.fromMap(islandMap);
    final slotIndex = island.slots.indexOf(null);

    final cityId = uuid.v4();

    // Crear edificios iniciales como instancias completas
    final buildings = {
      'Senado': Senate(level: 1),
      'Cuartel': Barracks(level: 1),
      'Granja': Farm(level: 1),
      'Aserradero': Sawmill(level: 1),
      'Cantera': Quarry(level: 1),
      'Mina de Plata': SilverMine(level: 1),
      'Almacén': Warehouse(level: 1),
    };

    // Crear ciudad
    final city = City(
      cityId: cityId,
      ownerId: userId,
      islandId: island.islandId,
      slotIndex: slotIndex,
      buildings: buildings,
      resources: {'wood': 1000, 'stone': 1000, 'silver': 1000},
      constructionQueue: [],
    );

    // Insertar ciudad en la base de datos
    await DbService.citiesCollection.insertOne(city.toMap());

    // Actualizar la isla con el nuevo slot asignado
    island.slots[slotIndex] = cityId;
    await DbService.islandsCollection.replaceOne(
      {'islandId': island.islandId},
      island.toMap(),
    );

    print("AssignmentManager: Assigned city $cityId to user $userId");
    return city;
  }
}
