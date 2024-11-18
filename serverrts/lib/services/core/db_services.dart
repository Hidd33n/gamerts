// lib/services/db_service.dart

import 'package:mongo_dart/mongo_dart.dart';
import 'package:serverrts/services/map/map_services.dart';

class DbService {
  static late Db db;
  static late DbCollection usersCollection;
  static late DbCollection mapsCollection;
  static late DbCollection islandsCollection;
  static late DbCollection citiesCollection;
  static late DbCollection buildingsCollection;
  static late DbCollection unitsCollection;
  static late DbCollection battlesCollection;

  static Future<void> init() async {
    db = Db('mongodb://localhost:27017/game_db');
    await db.open();
    print('Conectado a MongoDB');

    usersCollection = db.collection('users');
    mapsCollection = db.collection('maps');
    islandsCollection = db.collection('islands');
    citiesCollection = db.collection('cities');
    buildingsCollection = db.collection('buildings');
    unitsCollection = db.collection('units');
    battlesCollection = db.collection('battles');

    // Verificar si el mapa ya existe; si no, crearlo
    await _initializeMap();
  }

  static Future<void> _initializeMap() async {
    var existingMap = await mapsCollection.findOne();
    if (existingMap == null) {
      print('No se encontró un mapa existente. Generando uno nuevo...');
      // Generar y guardar el mapa
      await MapService.generateMap(10, 20); // Tamaño 10x10 y 20 islas
      print('Mapa generado y guardado en la base de datos.');
    } else {
      print('Mapa existente encontrado en la base de datos.');
    }
  }
}
