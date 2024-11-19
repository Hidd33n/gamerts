class Battle {
  String battleId;
  String attackerId;
  String defenderId;
  Map<String, int> attackingUnits; // Unidades del atacante
  Map<String, int> defendingUnits; // Unidades del defensor
  Map<String, int> attackerLosses; // Pérdidas del atacante
  Map<String, int> defenderLosses; // Pérdidas del defensor
  String result; // 'win' o 'lose'
  String timestamp;

  Battle({
    required this.battleId,
    required this.attackerId,
    required this.defenderId,
    required this.attackingUnits,
    required this.defendingUnits,
    required this.attackerLosses,
    required this.defenderLosses,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'battleId': battleId,
      'attackerId': attackerId,
      'defenderId': defenderId,
      'attackingUnits': attackingUnits,
      'defendingUnits': defendingUnits,
      'attackerLosses': attackerLosses,
      'defenderLosses': defenderLosses,
      'result': result,
      'timestamp': timestamp,
    };
  }

  factory Battle.fromMap(Map<String, dynamic> map) {
    return Battle(
      battleId: map['battleId'],
      attackerId: map['attackerId'],
      defenderId: map['defenderId'],
      attackingUnits: Map<String, int>.from(map['attackingUnits']),
      defendingUnits: Map<String, int>.from(map['defendingUnits']),
      attackerLosses: Map<String, int>.from(map['attackerLosses']),
      defenderLosses: Map<String, int>.from(map['defenderLosses']),
      result: map['result'],
      timestamp: map['timestamp'],
    );
  }
}
