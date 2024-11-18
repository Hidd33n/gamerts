import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rts/blocs/city/city_event.dart';
import 'package:rts/blocs/city/city_states.dart';
import 'package:rts/data/serverconection.dart';
import 'package:rts/models/city.dart';

class CityBloc extends Bloc<CityEvent, CityState> {
  final ServerConnection serverConnection;

  CityBloc(this.serverConnection) : super(CityInitial()) {
    // Escuchar actualizaciones en tiempo real del servidor
    serverConnection.stream.listen((data) {
      print("Server stream received: $data"); // Log para cada mensaje recibido
      if (data['action'] == 'city_data' || data['action'] == 'city_update') {
        print("Triggering CityUpdated event with data: ${data['data']}");
        add(CityUpdated(data['data']));
      }
    });

    // Registro de manejadores de eventos
    on<CityLoadRequested>(_onCityLoadRequested);
    on<BuildingUpgradeRequested>(_onBuildingUpgradeRequested);
    on<ConstructionCancelRequested>(_onConstructionCancelRequested);
    on<CityUpdated>(_onCityUpdated);
  }

  /// Manejar solicitud de carga inicial de la ciudad
  Future<void> _onCityLoadRequested(
      CityLoadRequested event, Emitter<CityState> emit) async {
    print("Event: CityLoadRequested triggered");
    emit(CityLoading());
    try {
      print("Requesting city data from server...");
      final cityData = await serverConnection.getCity();
      if (cityData.isNotEmpty) {
        final city = City.fromMap(cityData);
        print("City data loaded successfully: $city");
        emit(CityLoaded(city));
      } else {
        print("City data is empty");
        emit(CityError('No se pudo cargar la ciudad: datos vacíos.'));
      }
    } catch (e) {
      print("Error while loading city: $e");
      emit(CityError('Error al cargar la ciudad: ${e.toString()}'));
    }
  }

  /// Manejar solicitud de mejora de edificio
  Future<void> _onBuildingUpgradeRequested(
      BuildingUpgradeRequested event, Emitter<CityState> emit) async {
    if (state is CityLoaded) {
      print(
          "Event: BuildingUpgradeRequested triggered for ${event.buildingName}");
      try {
        print("Requesting building upgrade from server...");
        await serverConnection.upgradeBuilding(event.buildingName);

        print("Building upgraded, fetching updated city data...");
        final cityData = await serverConnection.getCity();
        if (cityData.isNotEmpty) {
          final updatedCity = City.fromMap(cityData);
          print("Updated city data received: $updatedCity");
          emit(CityLoaded(updatedCity));
        }
      } catch (e) {
        print("Error while upgrading building: $e");
        emit(CityError('Error al mejorar el edificio: ${e.toString()}'));
      }
    } else {
      print("Cannot upgrade building: City not loaded");
    }
  }

  /// Manejar solicitud de cancelación de construcción
  Future<void> _onConstructionCancelRequested(
      ConstructionCancelRequested event, Emitter<CityState> emit) async {
    if (state is CityLoaded) {
      print(
          "Event: ConstructionCancelRequested triggered for index ${event.queueIndex}");
      try {
        print("Requesting construction cancellation from server...");
        await serverConnection.cancelConstruction(event.queueIndex);

        print("Construction canceled, fetching updated city data...");
        final cityData = await serverConnection.getCity();
        if (cityData.isNotEmpty) {
          final updatedCity = City.fromMap(cityData);
          print("Updated city data after cancellation: $updatedCity");
          emit(CityLoaded(updatedCity));
        }
      } catch (e) {
        print("Error while canceling construction: $e");
        emit(CityError('Error al cancelar la construcción: ${e.toString()}'));
      }
    } else {
      print("Cannot cancel construction: City not loaded");
    }
  }

  /// Manejar actualizaciones en tiempo real de la ciudad
  void _onCityUpdated(CityUpdated event, Emitter<CityState> emit) {
    print("Event: CityUpdated triggered with data: ${event.cityData}");
    if (state is CityLoaded) {
      final currentCity = (state as CityLoaded).city;
      final updatedCity = City.fromMap(event.cityData);

      // Comparar si la ciudad ha cambiado para evitar estados redundantes
      if (updatedCity != currentCity) {
        print("City data has changed, emitting new state");
        emit(CityLoaded(updatedCity));
      } else {
        print("City data is identical, skipping state update");
      }
    } else {
      // Si el estado no es CityLoaded, inicializar con los datos recibidos
      final newCity = City.fromMap(event.cityData);
      print("City not previously loaded, initializing with new data: $newCity");
      emit(CityLoaded(newCity));
    }
  }
}
