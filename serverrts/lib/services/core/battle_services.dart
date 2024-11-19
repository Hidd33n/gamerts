import 'package:serverrts/models/battles.dart';
import 'package:serverrts/models/city.dart';
import 'package:serverrts/services/core/db_services.dart';

class BattleService {
  static Future<Battle> initiateBattle(City attackerCity, City defenderCity,
      Map<String, int> attackingUnits) async {
    final defendingUnits = defenderCity.units;

    // Simular la batalla
    final attackerLosses = <String, int>{};
    final defenderLosses = <String, int>{};
    String result = _simulateBattle(
        attackingUnits, defendingUnits, attackerLosses, defenderLosses);

    // Actualizar las ciudades
    _applyBattleResults(attackerCity, attackerLosses);
    _applyBattleResults(defenderCity, defenderLosses);

    // Guardar los cambios en la base de datos
    await DbService.citiesCollection.updateOne(
      {'cityId': attackerCity.cityId},
      {'\$set': attackerCity.toMap()},
    );
    await DbService.citiesCollection.updateOne(
      {'cityId': defenderCity.cityId},
      {'\$set': defenderCity.toMap()},
    );

    // Registrar la batalla en la base de datos
    final battle = Battle(
      battleId: DateTime.now().millisecondsSinceEpoch.toString(),
      attackerId: attackerCity.ownerId,
      defenderId: defenderCity.ownerId,
      attackingUnits: attackingUnits,
      defendingUnits: defendingUnits,
      attackerLosses: attackerLosses,
      defenderLosses: defenderLosses,
      result: result,
      timestamp: DateTime.now().toIso8601String(),
    );

    await DbService.battlesCollection.insert(battle.toMap());

    return battle;
  }

  static String _simulateBattle(
      Map<String, int> attackingUnits,
      Map<String, int> defendingUnits,
      Map<String, int> attackerLosses,
      Map<String, int> defenderLosses) {
    int attackerPower = 0;
    int defenderPower = 0;

    // Calcular el poder de ataque y defensa
    attackingUnits.forEach((unit, count) {
      attackerPower += (count * 10); // Asume un ataque base por unidad
    });

    defendingUnits.forEach((unit, count) {
      defenderPower += (count * 10); // Asume una defensa base por unidad
    });

    // Simular pérdidas
    attackingUnits.forEach((unit, count) {
      attackerLosses[unit] = (count * 0.5).round(); // Pérdida del 50%
    });

    defendingUnits.forEach((unit, count) {
      defenderLosses[unit] = (count * 0.5).round(); // Pérdida del 50%
    });

    // Determinar el ganador
    return attackerPower > defenderPower ? 'win' : 'lose';
  }

  static void _applyBattleResults(City city, Map<String, int> losses) {
    losses.forEach((unit, count) {
      city.units[unit] = (city.units[unit] ?? 0) - count;
      if (city.units[unit]! <= 0) {
        city.units.remove(unit);
      }
    });
  }
}
