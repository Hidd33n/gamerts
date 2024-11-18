// lib/blocs/map/map_event.dart

import 'package:rts/models/city.dart';
import 'package:rts/models/maptiles.dart';

abstract class MapEvent {}

class LoadMapEvent extends MapEvent {}

class MapLoadedEvent extends MapEvent {
  final List<MapTile> mapTiles;
  final City? playerCity;

  MapLoadedEvent({required this.mapTiles, required this.playerCity});
}

class MapErrorEvent extends MapEvent {
  final String message;

  MapErrorEvent({required this.message});
}
