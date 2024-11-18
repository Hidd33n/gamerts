// lib/models/resources.dart
import 'package:equatable/equatable.dart';

class Resources extends Equatable {
  final int wood;
  final int stone;
  final int silver;

  const Resources({
    this.wood = 0,
    this.stone = 0,
    this.silver = 0,
  });

  Resources copyWith({int? wood, int? stone, int? silver}) {
    return Resources(
      wood: wood ?? this.wood,
      stone: stone ?? this.stone,
      silver: silver ?? this.silver,
    );
  }

  @override
  List<Object?> get props => [wood, stone, silver];
}
