import 'package:serverrts/core/controllers/game_controllers.dart';
import 'package:serverrts/core/services/core/db_services.dart';
import 'package:serverrts/core/services/core/tech_services.dart';
import 'package:serverrts/core/services/core/unit_services.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

Future<void> main() async {
  // Inicializar conexión a la base de datos
  await DbService.init();
  GameController.startResourceGeneration();
  GameController.startTrainingProcessing();
  UnitService.initializeUnits();
  TechnologyService.initializeTechnologies();
  // Crear manejador de WebSocket para cada cliente
  final handler = webSocketHandler((webSocket) {
    GameController(webSocket); // Crear instancia del controlador por cliente
  });

  // Iniciar el servidor
  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('Servidor iniciado en ws://${server.address.host}:${server.port}');
}
