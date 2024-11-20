import 'package:mongo_dart/mongo_dart.dart';
import 'package:serverrts/core/services/map/map_services.dart';

class DbService {
  static late Db db;

  static DbCollection get usersCollection => db.collection('users');
  static DbCollection get mapsCollection => db.collection('maps');
  static DbCollection get islandsCollection => db.collection('islands');
  static DbCollection get citiesCollection => db.collection('cities');
  static DbCollection get buildingsCollection => db.collection('buildings');
  static DbCollection get unitsCollection => db.collection('units');
  static DbCollection get battlesCollection => db.collection('battles');
  static DbCollection get technologiesCollection =>
      db.collection('technologies');
  static DbCollection get alliancesCollection => db.collection('alliances');

  /// Inicializar conexión a MongoDB
  static Future<void> init() async {
    final mongoUri = const String.fromEnvironment('MONGO_URI',
        defaultValue: 'mongodb://localhost:27017/game_db');

    try {
      db = Db(mongoUri);
      await db.open();
      print('Conectado a MongoDB en $mongoUri');

      // Verificar si el mapa existe o debe generarse
      await _initializeMap();
    } catch (e) {
      print('Error al conectar con MongoDB: $e');
      rethrow;
    }
  }

  /// Verificar y generar el mapa si no existe
  static Future<void> _initializeMap() async {
    try {
      var existingMap = await mapsCollection.findOne();
      if (existingMap == null) {
        print('No se encontró un mapa existente. Generando uno nuevo...');
        await MapService.generateMap(10, 20); // Tamaño 10x10 y 20 islas
        print('Mapa generado y guardado en la base de datos.');
      } else {
        print('Mapa existente encontrado en la base de datos.');
      }
    } catch (e) {
      print('Error al verificar o generar el mapa: $e');
      rethrow;
    }
  }
}
