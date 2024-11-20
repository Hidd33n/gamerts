import 'dart:math';
import 'package:serverrts/models/island.dart';
import 'package:serverrts/models/map_tiles.dart';
import 'package:serverrts/core/services/city/city_services.dart';
import 'package:serverrts/core/services/core/db_services.dart';
import 'package:uuid/uuid.dart';

class MapService {
  static final Uuid uuid = Uuid();

  /// Generar el mapa y guardar en la base de datos
  static Future<void> generateMap(int size, int numberOfIslands) async {
    List<MapTile> mapTiles = [];
    List<Point<int>> islandPositions = [];
    List<Island> islands = [];
    Random random = Random();

    // Generar posiciones de islas
    while (islandPositions.length < numberOfIslands) {
      int x = random.nextInt(size);
      int y = random.nextInt(size);
      Point<int> point = Point(x, y);

      if (!islandPositions.contains(point)) {
        islandPositions.add(point);

        // Crear una nueva isla
        String islandId = uuid.v4();
        Island island = Island(
          islandId: islandId,
          x: x,
          y: y,
          width: random.nextInt(3) + 2, // Ancho entre 2 y 4 tiles
          height: random.nextInt(3) + 2, // Alto entre 2 y 4 tiles
          slots: List<String?>.filled(5, null), // 5 slots vacíos
          resources: {
            'wood': random.nextInt(500) + 500, // Recursos iniciales aleatorios
            'stone': random.nextInt(500) + 500,
            'silver': random.nextInt(500) + 500,
          },
        );

        islands.add(island);

        // Agregar los tiles correspondientes a la isla
        for (int dx = 0; dx < island.width; dx++) {
          for (int dy = 0; dy < island.height; dy++) {
            mapTiles.add(MapTile(
              x: x + dx,
              y: y + dy,
              islandId: islandId,
            ));
          }
        }
      }
    }

    // Generar tiles de agua para el resto del mapa
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        if (!islandPositions.contains(Point(x, y))) {
          mapTiles.add(MapTile(x: x, y: y));
        }
      }
    }

    // Guardar islas y mapa en la base de datos
    await DbService.islandsCollection
        .insertMany(islands.map((island) => island.toMap()).toList());
    await DbService.mapsCollection.insertOne({
      'size': size,
      'tiles': mapTiles.map((tile) => tile.toMap()).toList(),
    });
  }

  /// Asignar una ciudad a un jugador en una isla con slots disponibles
  static Future<Island?> assignCityToPlayer(String userId) async {
    // Buscar una isla con slots disponibles
    var islandMap = await DbService.islandsCollection.findOne({
      'slots': {
        '\$elemMatch': {'\$eq': null}
      },
    });

    if (islandMap != null) {
      Island island = Island.fromMap(islandMap);

      // Asignar el primer slot disponible
      int slotIndex = island.slots.indexOf(null);

      // Asignar la ciudad al jugador
      await CityService.assignCityToPlayer(userId);

      // Actualizar el slot en la isla
      island.slots[slotIndex] = userId; // Ocupamos el slot con el userId
      await DbService.islandsCollection
          .replaceOne({'islandId': island.islandId}, island.toMap());

      return island;
    }

    return null;
  }

  /// Obtener los datos del mapa desde la base de datos
  static Future<Map<String, dynamic>?> getMapData() async {
    var mapData = await DbService.mapsCollection.findOne();
    if (mapData != null) {
      // Obtener todas las islas relacionadas desde la base de datos
      var islandsData = await DbService.islandsCollection.find().toList();

      // Agregar los datos de las islas al mapa
      mapData['islands'] =
          islandsData.map((island) => Island.fromMap(island).toMap()).toList();
      return mapData;
    }
    return null;
  }
}
