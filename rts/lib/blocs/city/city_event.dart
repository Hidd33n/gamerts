import 'package:equatable/equatable.dart';

abstract class CityEvent extends Equatable {
  const CityEvent();

  @override
  List<Object?> get props => [];
}

class LoadCity extends CityEvent {}

class UpgradeBuilding extends CityEvent {
  final String buildingName;

  const UpgradeBuilding(this.buildingName);

  @override
  List<Object?> get props => [buildingName];
}

class CancelConstruction extends CityEvent {
  final int queueIndex;

  const CancelConstruction(this.queueIndex);

  @override
  List<Object?> get props => [queueIndex];
}

class CityUpdated extends CityEvent {
  final Map<String, dynamic> cityData;

  const CityUpdated(this.cityData);

  @override
  List<Object?> get props => [cityData];
}

class ConstructionCancelRequested extends CityEvent {
  final int queueIndex;

  const ConstructionCancelRequested(this.queueIndex);

  @override
  List<Object?> get props => [queueIndex];
}

class BuildingUpgradeRequested extends CityEvent {
  final String buildingName;

  const BuildingUpgradeRequested(this.buildingName);

  @override
  List<Object?> get props => [buildingName];
}

class CityLoadRequested extends CityEvent {}
