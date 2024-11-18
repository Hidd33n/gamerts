// lib/models/map_tile.dart

class MapTile {
  final int x;
  final int y;
  final String? islandId; // ID de la isla si hay una en este tile

  MapTile({
    required this.x,
    required this.y,
    this.islandId,
  });

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'islandId': islandId,
    };
  }

  factory MapTile.fromMap(Map<String, dynamic> map) {
    return MapTile(
      x: map['x'] as int,
      y: map['y'] as int,
      islandId: map['islandId'] as String?,
    );
  }
}
