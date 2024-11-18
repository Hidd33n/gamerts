// lib/models/sawmill.dart
import 'building.dart';

class Sawmill extends Building {
  Sawmill({int level = 1})
      : super(
          name: 'Aserradero',
          level: level,
          maxLevel: 40,
        );

  @override
  int get resourceProductionRate => level * 10;

  @override
  Sawmill upgrade() {
    if (level < maxLevel) {
      return Sawmill(level: level + 1);
    }
    return this;
  }
}
