import 'package:serverrts/models/buildings/building.dart';

class City {
  String cityId;
  String ownerId;
  String islandId;
  int slotIndex;
  Map<String, Building> buildings;
  Map<String, int> resources;
  List<Map<String, dynamic>> constructionQueue;
  List<Map<String, dynamic>> trainingQueue;
  Map<String, int> units; // Cambiar de lista a mapa para almacenar cantidades
  String lastUpdated;

  City({
    required this.cityId,
    required this.ownerId,
    required this.islandId,
    required this.slotIndex,
    required this.buildings,
    required this.resources,
    required this.constructionQueue,
    required this.trainingQueue,
    required this.units, // Inicializar el mapa de unidades
    String? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now().toIso8601String();

  /// Método para convertir a un mapa
  Map<String, dynamic> toMap() {
    return {
      'cityId': cityId,
      'ownerId': ownerId,
      'islandId': islandId,
      'slotIndex': slotIndex,
      'buildings': buildings.map((key, value) => MapEntry(key, value.toMap())),
      'resources': resources,
      'constructionQueue': constructionQueue,
      'trainingQueue': trainingQueue,
      'units': units, // Incluir el mapa de unidades
      'lastUpdated': lastUpdated,
    };
  }

  /// Crear una ciudad desde un mapa
  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      cityId: map['cityId'] as String,
      ownerId: map['ownerId'] as String,
      islandId: map['islandId'] as String,
      slotIndex: map['slotIndex'] as int,
      buildings: (map['buildings'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, Building.fromMap(value)),
      ),
      resources: Map<String, int>.from(map['resources'] as Map),
      constructionQueue:
          List<Map<String, dynamic>>.from(map['constructionQueue']),
      trainingQueue: List<Map<String, dynamic>>.from(
          map['trainingQueue'] ?? []), // Convertir cola de entrenamiento
      units: Map<String, int>.from(
          map['units'] ?? {}), // Convertir mapa de unidades
      lastUpdated:
          map['lastUpdated'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
