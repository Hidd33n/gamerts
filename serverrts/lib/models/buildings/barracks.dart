// lib/models/barracks.dart
import 'building.dart';

class Barracks extends Building {
  Barracks({int level = 1})
      : super(
          name: 'Cuartel',
          level: level,
          maxLevel: 30,
        );

  /// Reducción de tiempo de entrenamiento
  double get trainingTimeReduction => level * 0.02;

  @override
  Barracks upgrade() {
    if (level < maxLevel) {
      return Barracks(level: level + 1);
    }
    return this;
  }
}
