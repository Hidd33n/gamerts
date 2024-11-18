class Island {
  final String islandId;
  final int x;
  final int y;
  final List<String?> slots; // Lista de cityIds o null

  Island({
    required this.islandId,
    required this.x,
    required this.y,
    required this.slots,
  });

  factory Island.fromMap(Map<String, dynamic> map) {
    return Island(
      islandId: map['islandId'] as String,
      x: map['x'] as int,
      y: map['y'] as int,
      slots: List<String?>.from(map['slots'] as List),
    );
  }
}
