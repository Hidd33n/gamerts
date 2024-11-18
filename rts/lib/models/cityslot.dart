// lib/models/city_slot.dart
import 'package:equatable/equatable.dart';
import 'city.dart';

class CitySlot extends Equatable {
  final int slotNumber;
  City? city;

  CitySlot({required this.slotNumber, this.city});

  @override
  List<Object?> get props => [slotNumber, city];
}
