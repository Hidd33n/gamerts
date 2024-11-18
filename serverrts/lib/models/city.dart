import 'package:serverrts/models/buildings/building.dart';

class City {
  String cityId;
  String ownerId;
  String islandId;
  int slotIndex;
  Map<String, Building>
      buildings; // Cambiar de Map<String, int> a Map<String, Building>
  Map<String, int> resources;
  List<Map<String, dynamic>> constructionQueue;
  String lastUpdated;

  City({
    required this.cityId,
    required this.ownerId,
    required this.islandId,
    required this.slotIndex,
    required this.buildings,
    required this.resources,
    required this.constructionQueue,
    String? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now().toIso8601String();

  /// Método para convertir a un mapa, serializando edificios
  Map<String, dynamic> toMap() {
    return {
      'cityId': cityId,
      'ownerId': ownerId,
      'islandId': islandId,
      'slotIndex': slotIndex,
      'buildings': buildings.map((key, value) => MapEntry(key, value.toMap())),
      'resources': resources,
      'constructionQueue': constructionQueue,
      'lastUpdated': lastUpdated,
    };
  }

  /// Crear una ciudad desde un mapa, deserializando edificios
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
      lastUpdated:
          map['lastUpdated'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
