import 'package:serverrts/models/buildings/building.dart';

class Library extends Building {
  Library({required int level})
      : super(name: 'Biblioteca', level: level, maxLevel: 10);

  @override
  int get resourceProductionRate => 0;

  @override
  Duration get constructionTime {
    return Duration(
        minutes: 5 + (level * 2)); // Base de 5 minutos más 2 por nivel.
  }

  @override
  Building upgrade() {
    if (level < maxLevel) {
      return Library(level: level + 1);
    }
    return this;
  }

  int get researchSpeedBoost {
    return level * 5; // Porcentaje de reducción de tiempo (5% por nivel).
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
    };
  }

  factory Library.fromMap(Map<String, dynamic> map) {
    return Library(level: map['level']);
  }
}
