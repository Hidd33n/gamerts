import 'package:serverrts/models/buildings/building.dart';
import 'package:serverrts/models/buildings/farm.dart';
import 'package:serverrts/models/buildings/harbor.dart';
import 'package:serverrts/models/buildings/sawmill.dart';
import 'package:serverrts/models/buildings/senate.dart';
import 'package:serverrts/models/buildings/silvermine.dart';
import 'package:serverrts/models/buildings/wall.dart';
import 'package:serverrts/models/buildings/warehouse.dart';

class BuildingUtilities {
  static Building? createBuildingInstance(String name, int level) {
    switch (name) {
      case 'Senado':
        return Senate(level: level);
      case 'Aserradero':
        return Sawmill(level: level);
      case 'Mina de Plata':
        return SilverMine(level: level);
      case 'Muralla':
        return Wall(level: level);
      case 'Almacén':
        return Warehouse(level: level);
      case 'Puerto':
        return Harbor(level: level);
      case 'Granja':
        return Farm(level: level);
      default:
        return null;
    }
  }

  static bool hasEnoughResources(
      Map<String, int> resources, int wood, int stone, int silver) {
    return resources['wood']! >= wood &&
        resources['stone']! >= stone &&
        resources['silver']! >= silver;
  }
}
