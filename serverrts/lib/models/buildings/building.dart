import 'package:serverrts/models/buildings/library.dart';
import 'package:serverrts/models/buildings/quarry.dart';
import 'package:serverrts/models/buildings/sawmill.dart';
import 'package:serverrts/models/buildings/silvermine.dart';
import 'package:serverrts/models/buildings/warehouse.dart';
import 'package:serverrts/models/buildings/senate.dart';
import 'package:serverrts/models/buildings/harbor.dart';
import 'package:serverrts/models/buildings/wall.dart';
import 'package:serverrts/models/buildings/farm.dart';
import 'package:serverrts/models/buildings/barracks.dart';

class Building {
  final String name;
  final int level;
  final int maxLevel;

  Building({
    required this.name,
    required this.level,
    required this.maxLevel,
  });

  int get resourceProductionRate => 0;
  int get storageCapacity => 0;

  // Método para calcular el tiempo de mejora
  Duration get constructionTime {
    return Duration(minutes: level * 2); // Tiempo base: 2 minutos por nivel
  }

  Building upgrade() {
    return this;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'level': level,
      'maxLevel': maxLevel,
    };
  }

  factory Building.fromMap(Map<String, dynamic> map) {
    switch (map['name']) {
      case 'Aserradero':
        return Sawmill(level: map['level']);
      case 'Mina de Plata':
        return SilverMine(level: map['level']);
      case 'Cantera':
        return Quarry(level: map['level']);
      case 'Almacén':
        return Warehouse(level: map['level']);
      case 'Senado':
        return Senate(level: map['level']);
      case 'Biblioteca': // Agregar el caso de Biblioteca
        return Library(level: map['level']);
      case 'Puerto':
        return Harbor(level: map['level']);
      case 'Muralla':
        return Wall(level: map['level']);
      case 'Granja':
        return Farm(level: map['level']);
      case 'Cuartel':
        return Barracks(level: map['level']);
      default:
        throw Exception('Unknown building type: ${map['name']}');
    }
  }
}
