// lib/models/wall.dart
import 'building.dart';

class Wall extends Building {
  Wall({int level = 1})
      : super(
          name: 'Muralla',
          level: level,
          maxLevel: 20,
        );

  /// Incremento en la defensa
  int get defenseBonus => level * 50;

  @override
  Wall upgrade() {
    if (level < maxLevel) {
      return Wall(level: level + 1);
    }
    return this;
  }
}
