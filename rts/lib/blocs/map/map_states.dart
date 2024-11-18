// lib/blocs/map/map_state.dart

import 'package:rts/models/city.dart';
import 'package:rts/models/maptiles.dart';

abstract class MapState {}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final List<MapTile> mapTiles;
  final City? playerCity;

  MapLoaded({required this.mapTiles, required this.playerCity});
}

class MapError extends MapState {
  final String message;

  MapError({required this.message});
}
