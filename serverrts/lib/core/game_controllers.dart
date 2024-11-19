import 'dart:async';
import 'dart:convert';
import 'package:serverrts/controllers/auth.dart';
import 'package:serverrts/core/city_controller.dart';
import 'package:serverrts/core/map_controller.dart';
import 'package:serverrts/models/city.dart';
import 'package:serverrts/services/city/city_services.dart';
import 'package:serverrts/services/city/user_conection_manager.dart';
import 'package:serverrts/services/core/db_services.dart';
import 'package:serverrts/services/core/unit_services.dart';
import 'package:serverrts/utils/jwt.dart';
import 'package:serverrts/utils/timeutils.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class GameController {
  final WebSocketChannel webSocket;
  final AuthController authController = AuthController();
  final CityController cityController;
  final MapController mapController;
  String? userId;
  String? username;

  GameController(this.webSocket)
      : cityController = CityController(webSocket),
        mapController = MapController(webSocket) {
    webSocket.stream.listen(
      (message) async {
        await _handleMessage(message);
      },
      onDone: _handleDisconnect,
    );
  }

  Future<void> _handleMessage(dynamic message) async {
    final data = jsonDecode(message as String) as Map<String, dynamic>;
    final String action = data['action'] as String;

    void send(Map<String, dynamic> response) {
      webSocket.sink.add(jsonEncode(response));
    }

    try {
      if (action == 'register' || action == 'login') {
        await authController.handleMessage(data, send);
        return;
      }

      if (!await _authenticate(data, send)) return;

      switch (action) {
        case 'get_map':
          await mapController.handleGetMap(send);
          break;
        case 'get_city':
          await cityController.handleGetCity(userId!, send);
          break;
        case 'upgrade_building':
          await cityController.handleUpgradeBuilding(userId!, data, send);
          break;
        case 'cancel_construction':
          await cityController.handleCancelConstruction(userId!, data, send);
          break;
        case 'train_unit':
          await cityController.handleTrainUnit(userId!, data, send);
          break;
        default:
          send({'action': 'error', 'message': 'Acción no reconocida.'});
      }
    } catch (e, stackTrace) {
      print('Error en el GameController: $e');
      print(stackTrace);
      send({'action': 'error', 'message': 'Error interno del servidor.'});
    }
  }

  Future<bool> _authenticate(
      Map<String, dynamic> data, Function(Map<String, dynamic>) send) async {
    final String? token = data['token'] as String?;
    if (token == null) {
      send({'action': 'error', 'message': 'Token no proporcionado.'});
      return false;
    }

    final tokenData = JwtUtils.verifyToken(token);
    if (tokenData == null) {
      send({'action': 'error', 'message': 'Token inválido o expirado.'});
      return false;
    }

    userId = tokenData['userId'] as String?;
    username = tokenData['username'] as String?;
    return true;
  }

  void _handleDisconnect() {
    print('Cliente desconectado: $userId');
    if (userId != null) {
      UserConnectionManager.stopUpdates(userId!);
      cityController.handleUserDisconnect(userId!);
    }
  }

  /// Iniciar generación de recursos y procesamiento de colas
  static void startGameLoops() {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      print("GameController: Batch updates started.");

      final cities = await DbService.citiesCollection.find().toList();

      for (var cityMap in cities) {
        final city = City.fromMap(cityMap);

        // Generar recursos
        final lastUpdated = DateTime.parse(
            city.lastUpdated ?? DateTime.now().toIso8601String());
        final now = DateTime.now();
        final elapsedMinutes = TimeUtils.minutesBetween(lastUpdated, now);

        if (elapsedMinutes > 0) {
          _generateResources(city, elapsedMinutes);
          city.lastUpdated = now.toIso8601String();
        }

        // Procesar colas de entrenamiento
        UnitService.processTrainingQueue(city);

        // Guardar cambios en la base de datos
        await DbService.citiesCollection.updateOne(
          {'cityId': city.cityId},
          {'\$set': city.toMap()},
        );

        // Enviar actualizaciones al cliente si está conectado
        if (UserConnectionManager.isUserActive(city.ownerId)) {
          CityService.sendCityUpdate(city.ownerId, city);
        }
      }

      print("GameController: Batch updates completed.");
    });
  }

  static void startResourceGeneration() {
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      print("GameController: Batch resource generation started.");

      final cities = await DbService.citiesCollection.find().toList();

      for (var cityMap in cities) {
        final city = City.fromMap(cityMap);

        final lastUpdated = DateTime.parse(
            city.lastUpdated ?? DateTime.now().toIso8601String());
        final now = DateTime.now();
        final elapsedMinutes = TimeUtils.minutesBetween(lastUpdated, now);

        if (elapsedMinutes > 0) {
          _generateResources(city, elapsedMinutes);
          city.lastUpdated = now.toIso8601String();

          await DbService.citiesCollection.updateOne(
            {'cityId': city.cityId},
            {'\$set': city.toMap()},
          );

          if (UserConnectionManager.isUserActive(city.ownerId)) {
            CityService.sendCityUpdate(city.ownerId, city);
          }
        }
      }

      print("GameController: Batch resource generation completed.");
    });
  }

  /// Generar recursos para una ciudad
  static void _generateResources(City city, int elapsedMinutes) {
    final woodRate =
        (city.buildings['Aserradero']?.resourceProductionRate ?? 0);
    final stoneRate = (city.buildings['Cantera']?.resourceProductionRate ?? 0);
    final silverRate =
        (city.buildings['Mina de Plata']?.resourceProductionRate ?? 0);
    final warehouseCapacity =
        (city.buildings['Almacén']?.storageCapacity ?? 1500);

    city.resources['wood'] =
        (city.resources['wood']! + woodRate * elapsedMinutes)
            .clamp(0, warehouseCapacity);
    city.resources['stone'] =
        (city.resources['stone']! + stoneRate * elapsedMinutes)
            .clamp(0, warehouseCapacity);
    city.resources['silver'] =
        (city.resources['silver']! + silverRate * elapsedMinutes)
            .clamp(0, warehouseCapacity);
  }

  static void startTrainingProcessing() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      print("GameController: Procesando colas de entrenamiento.");

      final cities = await DbService.citiesCollection.find().toList();

      for (var cityMap in cities) {
        final city = City.fromMap(cityMap);

        // Procesar cola de entrenamiento
        UnitService.processTrainingQueue(city);

        // Notificar al cliente si está conectado
        if (UserConnectionManager.isUserActive(city.ownerId)) {
          CityService.sendCityUpdate(city.ownerId, city);
        }
      }
    });
  }
}
