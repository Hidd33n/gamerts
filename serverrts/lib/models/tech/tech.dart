class Technology {
  final String name;
  final int requiredAcademyLevel;
  final Map<String, int> cost;
  final Duration researchTime;
  final String effect;

  Technology({
    required this.name,
    required this.requiredAcademyLevel,
    required this.cost,
    required this.researchTime,
    required this.effect,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'requiredAcademyLevel': requiredAcademyLevel,
      'cost': cost,
      'researchTime': researchTime.inSeconds,
      'effect': effect,
    };
  }

  factory Technology.fromMap(Map<String, dynamic> map) {
    return Technology(
      name: map['name'],
      requiredAcademyLevel: map['requiredAcademyLevel'],
      cost: Map<String, int>.from(map['cost']),
      researchTime: Duration(seconds: map['researchTime']),
      effect: map['effect'],
    );
  }
}
