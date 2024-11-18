import 'package:equatable/equatable.dart';
import 'package:rts/models/city.dart';

abstract class CityState extends Equatable {
  const CityState();

  @override
  List<Object?> get props => [];
}

class CityInitial extends CityState {}

class CityLoading extends CityState {}

class CityLoaded extends CityState {
  final City city;

  const CityLoaded(this.city);

  @override
  List<Object?> get props => [city];
}

class CityError extends CityState {
  final String message;

  const CityError(this.message);

  @override
  List<Object?> get props => [message];
}
