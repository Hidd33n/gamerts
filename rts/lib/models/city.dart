class City {
  final String cityId;
  final String ownerId;
  final String islandId;
  final int slotIndex;
  final Map<String, dynamic>
      buildings; // Cambiado a `dynamic` para flexibilidad
  final Map<String, int> resources;
  final List<Map<String, dynamic>> constructionQueue;

  City({
    required this.cityId,
    required this.ownerId,
    required this.islandId,
    required this.slotIndex,
    required this.buildings,
    required this.resources,
    required this.constructionQueue,
  });

  /// Crear un objeto `City` a partir de un mapa
  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      cityId: map['cityId'] ?? '',
      ownerId: map['ownerId'] ?? '',
      islandId: map['islandId'] ?? '',
      slotIndex: map['slotIndex'] ?? 0,
      buildings: Map<String, dynamic>.from(map['buildings'] ?? {}),
      resources: Map<String, int>.from(map['resources'] ?? {}),
      constructionQueue: List<Map<String, dynamic>>.from(
        map['constructionQueue'] ?? [],
      ),
    );
  }

  /// Convertir el objeto `City` a un mapa
  Map<String, dynamic> toMap() {
    return {
      'cityId': cityId,
      'ownerId': ownerId,
      'islandId': islandId,
      'slotIndex': slotIndex,
      'buildings': buildings,
      'resources': resources,
      'constructionQueue': constructionQueue,
    };
  }
}
