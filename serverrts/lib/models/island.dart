// lib/models/island.dart

class Island {
  final String islandId;
  final int x; // Coordenada superior izquierda de la isla
  final int y; // Coordenada superior izquierda de la isla
  final int width; // Ancho de la isla en tiles
  final int height; // Altura de la isla en tiles
  final List<String?> slots; // IDs de ciudades en la isla (máximo 5)
  final Map<String, int> resources; // Recursos únicos generados por la isla

  Island({
    required this.islandId,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.slots,
    required this.resources,
  });

  Map<String, dynamic> toMap() {
    return {
      'islandId': islandId,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'slots': slots,
      'resources': resources,
    };
  }

  factory Island.fromMap(Map<String, dynamic> map) {
    return Island(
      islandId: map['islandId'] as String,
      x: map['x'] as int,
      y: map['y'] as int,
      width: map['width'] as int,
      height: map['height'] as int,
      slots: List<String?>.from(map['slots']),
      resources: Map<String, int>.from(map['resources']),
    );
  }
}
