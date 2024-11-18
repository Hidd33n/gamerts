// lib/models/unit.dart
import 'package:equatable/equatable.dart';

class Unit extends Equatable {
  final String name;
  final int attack;
  final int defense;
  final int trainingTime;

  const Unit({
    required this.name,
    required this.attack,
    required this.defense,
    required this.trainingTime,
  });

  @override
  List<Object?> get props => [name, attack, defense, trainingTime];
}

class Archer extends Unit {
  const Archer()
      : super(name: 'Arquero', attack: 5, defense: 2, trainingTime: 60);
}

class Infantry extends Unit {
  const Infantry()
      : super(name: 'Infantería', attack: 7, defense: 3, trainingTime: 80);
}
