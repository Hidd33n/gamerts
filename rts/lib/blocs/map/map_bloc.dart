// lib/blocs/map/map_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rts/blocs/map/map_event.dart';
import 'package:rts/blocs/map/map_states.dart';
import 'package:rts/data/serverconection.dart';
import 'package:rts/models/city.dart';
import 'package:rts/models/island.dart';
import 'package:rts/models/maptiles.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final ServerConnection serverConnection;
  StreamSubscription<Map<String, dynamic>>? _subscription;

  List<MapTile> _mapTiles = [];
  City? _playerCity;
  bool _mapDataReceived = false;
  bool _cityDataReceived = false;

  MapBloc({required this.serverConnection}) : super(MapInitial()) {
    on<LoadMapEvent>(_onLoadMapEvent);
    on<MapLoadedEvent>(_onMapLoadedEvent);
    on<MapErrorEvent>(_onMapErrorEvent);

    // Suscribirse a los mensajes del servidor
    _subscription = serverConnection.stream.listen(_handleServerMessage);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  void _onLoadMapEvent(LoadMapEvent event, Emitter<MapState> emit) async {
    emit(MapLoading());
    _mapDataReceived = false;
    _cityDataReceived = false;
    try {
      // Solicitar el mapa al servidor
      serverConnection.getMap();
      // Solicitar los datos de la ciudad
      serverConnection.getCity();
      // Las respuestas se manejarán en _handleServerMessage
    } catch (e) {
      emit(MapError(message: 'Error al solicitar los datos: $e'));
    }
  }

  // lib/blocs/map/map_bloc.dart

  void _handleServerMessage(Map<String, dynamic> data) {
    try {
      String action = data['action'];
      switch (action) {
        case 'map_data':
          var mapData = data['data'];
          if (mapData != null) {
            _mapTiles = _parseMapData(mapData);
            _mapDataReceived = true;
            _emitIfReady();
          } else {
            add(MapErrorEvent(message: 'Datos del mapa no disponibles.'));
          }
          break;
        case 'city_data':
          var cityData = data['data'];
          if (cityData != null) {
            _playerCity = City.fromMap(cityData);
            _cityDataReceived = true;
            _emitIfReady();
          } else {
            add(MapErrorEvent(message: 'Datos de la ciudad no disponibles.'));
          }
          break;
        case 'error':
          add(MapErrorEvent(message: data['message']));
          break;
        // Otros casos si es necesario
      }
    } catch (e, stackTrace) {
      print('Error en _handleServerMessage de MapBloc: $e');
      print(stackTrace);
      add(MapErrorEvent(message: 'Error al procesar los datos del servidor.'));
    }
  }

  List<MapTile> _parseMapData(Map<String, dynamic> mapData) {
    List<dynamic>? tilesData = mapData['tiles'] as List<dynamic>?;
    List<dynamic>? islandsData = mapData['islands'] as List<dynamic>?;

    if (tilesData == null || islandsData == null) {
      return [];
    }

    // Crear un mapa de islands
    Map<String, Island> islands = {
      for (var islandData in islandsData)
        if (islandData != null && islandData['islandId'] != null)
          islandData['islandId']: Island.fromMap(islandData)
    };

    // Asociar islas con tiles
    List<MapTile> tiles = tilesData.map((tileData) {
      MapTile tile = MapTile.fromMap(tileData);
      if (tile.islandId != null && islands.containsKey(tile.islandId)) {
        tile.island = islands[tile.islandId];
      }
      return tile;
    }).toList();

    return tiles;
  }

  void _emitIfReady() {
    if (_mapDataReceived && _cityDataReceived) {
      add(MapLoadedEvent(mapTiles: _mapTiles, playerCity: _playerCity));
    }
  }

  void _onMapLoadedEvent(MapLoadedEvent event, Emitter<MapState> emit) {
    emit(MapLoaded(mapTiles: event.mapTiles, playerCity: event.playerCity));
  }

  void _onMapErrorEvent(MapErrorEvent event, Emitter<MapState> emit) {
    emit(MapError(message: event.message));
  }
}
