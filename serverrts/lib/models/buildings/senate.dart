// lib/models/senate.dart
import 'building.dart';

class Senate extends Building {
  Senate({int level = 1})
      : super(
          name: 'Senado',
          level: level,
          maxLevel: 30,
        );

  /// Reducción global de tiempo de construcción
  double get constructionTimeReduction => level * 0.01;

  @override
  Senate upgrade() {
    if (level < maxLevel) {
      return Senate(level: level + 1);
    }
    return this;
  }
}
