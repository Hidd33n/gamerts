// lib/models/quarry.dart
import 'building.dart';

class Quarry extends Building {
  Quarry({int level = 1})
      : super(
          name: 'Cantera',
          level: level,
          maxLevel: 40,
        );

  @override
  int get resourceProductionRate => level * 10;

  @override
  Quarry upgrade() {
    if (level < maxLevel) {
      return Quarry(level: level + 1);
    }
    return this;
  }
}
