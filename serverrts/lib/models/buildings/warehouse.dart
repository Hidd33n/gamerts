// lib/models/warehouse.dart
import 'building.dart';

class Warehouse extends Building {
  Warehouse({int level = 1})
      : super(
          name: 'Almacén',
          level: level,
          maxLevel: 30,
        );

  @override
  int get storageCapacity => 1500 + (level - 1) * 500;

  @override
  Warehouse upgrade() {
    if (level < maxLevel) {
      return Warehouse(level: level + 1);
    }
    return this;
  }
}
