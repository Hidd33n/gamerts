class Alliance {
  String id; // ID único de la alianza
  String name; // Nombre de la alianza
  String description; // Descripción de la alianza
  String leaderId; // ID del jugador líder
  List<String> members; // Lista de IDs de jugadores en la alianza
  DateTime createdAt; // Fecha de creación

  Alliance({
    required this.id,
    required this.name,
    required this.description,
    required this.leaderId,
    required this.members,
    required this.createdAt,
  });

  /// Convertir a un mapa para guardar en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'leaderId': leaderId,
      'members': members,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Crear una alianza desde un mapa
  factory Alliance.fromMap(Map<String, dynamic> map) {
    return Alliance(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      leaderId: map['leaderId'],
      members: List<String>.from(map['members']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
