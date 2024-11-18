// lib/models/silvermine.dart
import 'building.dart';

class SilverMine extends Building {
  SilverMine({int level = 1})
      : super(
          name: 'Mina de Plata',
          level: level,
          maxLevel: 40,
        );

  @override
  int get resourceProductionRate => level * 10;

  @override
  SilverMine upgrade() {
    if (level < maxLevel) {
      return SilverMine(level: level + 1);
    }
    return this;
  }
}
