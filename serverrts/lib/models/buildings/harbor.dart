// lib/models/harbor.dart
import 'building.dart';

class Harbor extends Building {
  Harbor({int level = 1})
      : super(
          name: 'Puerto',
          level: level,
          maxLevel: 30,
        );

  /// Reducción de tiempo de entrenamiento de barcos
  double get shipTrainingTimeReduction => level * 0.015;

  @override
  Harbor upgrade() {
    if (level < maxLevel) {
      return Harbor(level: level + 1);
    }
    return this;
  }
}
