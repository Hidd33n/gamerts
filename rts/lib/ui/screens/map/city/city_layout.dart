import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rts/blocs/city/city_bloc.dart';
import 'package:rts/blocs/city/city_event.dart';
import 'package:rts/models/city.dart';

class CityLayout extends StatelessWidget {
  final City city;

  const CityLayout({Key? key, required this.city}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("CityLayout: Building layout for city: ${city.cityId}");
    return Expanded(
      // Aseguramos que el GridView tenga límites
      child: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(8.0),
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        children: city.buildings.entries.map((entry) {
          final buildingName = entry.key;
          final dynamic rawLevel = entry.value;
          final level = rawLevel is int
              ? rawLevel
              : rawLevel is Map<String, dynamic>
                  ? rawLevel['level'] as int? ?? 0
                  : 0;
          print("CityLayout: Building $buildingName at level $level");
          return GestureDetector(
            onTap: () => _showUpgradeDialog(context, buildingName, level),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getBuildingIcon(buildingName),
                  size: 50,
                  color: Colors.amberAccent,
                ),
                const SizedBox(height: 4),
                Text(
                  '$buildingName\nNivel $level',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showUpgradeDialog(
      BuildContext context, String buildingName, int currentLevel) {
    print(
        "CityLayout: Showing upgrade dialog for $buildingName at level $currentLevel");
    final nextLevel = currentLevel + 1;
    final woodCost = nextLevel * 100;
    final stoneCost = nextLevel * 80;
    final silverCost = nextLevel * 60;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Mejorar $buildingName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nivel actual: $currentLevel'),
              Text('Nuevo nivel: $nextLevel'),
              Text('Costo de Madera: $woodCost'),
              Text('Costo de Piedra: $stoneCost'),
              Text('Costo de Plata: $silverCost'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                print("CityLayout: Upgrade canceled for $buildingName");
              },
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                print("CityLayout: Upgrade confirmed for $buildingName");

                // Enviar el evento al CityBloc
                context
                    .read<CityBloc>()
                    .add(BuildingUpgradeRequested(buildingName));

                print(
                    "CityLayout: BuildingUpgradeRequested event added for $buildingName");
              },
              child: const Text('Confirmar',
                  style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  IconData _getBuildingIcon(String buildingName) {
    switch (buildingName) {
      case 'Aserradero':
        return Icons.local_florist;
      case 'Cantera':
        return Icons.terrain;
      case 'Mina de Plata':
        return Icons.attach_money;
      case 'Granja':
        return Icons.grass;
      case 'Senado':
        return Icons.account_balance;
      case 'Cuartel':
        return Icons.shield;
      case 'Muralla':
        return Icons.security;
      case 'Puerto':
        return Icons.directions_boat;
      case 'Almacén':
        return Icons.store;
      default:
        return Icons.location_city;
    }
  }
}
