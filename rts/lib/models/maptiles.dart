// lib/models/maptile.dart

import 'package:rts/models/island.dart';

class MapTile {
  final int x;
  final int y;
  final String? islandId;
  Island? island; // Se asignará después de parsear las islas

  MapTile({
    required this.x,
    required this.y,
    this.islandId,
    this.island,
  });

  factory MapTile.fromMap(Map<String, dynamic> map) {
    return MapTile(
      x: map['x'] as int,
      y: map['y'] as int,
      islandId: map['islandId'] as String?,
    );
  }

  bool get isIsland => islandId != null;
}
