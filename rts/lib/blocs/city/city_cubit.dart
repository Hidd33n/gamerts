import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rts/data/serverconection.dart';
import 'package:rts/models/city.dart';

class CityCubit extends Cubit<City> {
  final ServerConnection serverConnection;

  CityCubit(this.serverConnection)
      : super(City(
          cityId: '',
          ownerId: '',
          islandId: '',
          slotIndex: 0,
          buildings: {},
          resources: {},
          constructionQueue: [],
        )) {
    // Escuchar mensajes del servidor y manejar las respuestas en tiempo real
    serverConnection.stream.listen((data) {
      print("Mensaje recibido en CityCubit: $data");
      handleServerMessage(data);
    });
  }

  /// Solicitar la ciudad al servidor
  void loadCity() {
    serverConnection.getCity();
  }

  /// Manejar los mensajes del servidor
  void handleServerMessage(Map<String, dynamic> data) {
    print("Mensaje recibido del servidor en CityCubit: $data");
    if (data['action'] == 'city_data' || data['action'] == 'city_update') {
      // Actualizar el estado con la nueva información de la ciudad
      final newCity = City.fromMap(data['data']);
      if (state != newCity) {
        print("Actualizando estado en CityCubit");
        emit(newCity);
      } else {
        print("No hubo cambios en el estado de la ciudad.");
      }
    } else if (data['action'] == 'building_upgraded') {
      print("Edificio mejorado: ${data['buildingName']}");
      loadCity(); // Recargar la ciudad para reflejar los cambios
    } else if (data['action'] == 'construction_cancelled') {
      print("Construcción cancelada: ${data['queueIndex']}");
      loadCity(); // Recargar la ciudad para reflejar los cambios
    } else if (data['action'] == 'error') {
      print("Error del servidor: ${data['message']}");
      // Manejar errores según sea necesario (notificaciones, alertas, etc.)
    }
  }

  /// Solicitar la mejora de un edificio
  void upgradeBuilding(String buildingName) {
    print("Solicitando mejora del edificio: $buildingName");
    serverConnection.upgradeBuilding(buildingName);
  }

  /// Cancelar una construcción en progreso
  void cancelConstruction(int index) {
    print("Solicitando cancelación de construcción en índice: $index");
    serverConnection.cancelConstruction(index);
  }
}
