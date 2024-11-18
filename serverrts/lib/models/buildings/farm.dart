// lib/models/farm.dart
import 'building.dart';

class Farm extends Building {
  Farm({int level = 1})
      : super(
          name: 'Granja',
          level: level,
          maxLevel: 60,
        );

  /// Método para obtener la población generada
  int get population => level * 10;

  @override
  Farm upgrade() {
    if (level < maxLevel) {
      return Farm(level: level + 1);
    }
    return this;
  }
}
