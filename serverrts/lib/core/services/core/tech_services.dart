import 'package:serverrts/core/services/core/db_services.dart';

class TechnologyService {
  static Future<void> initializeTechnologies() async {
    final technologies = [
      {
        'name': 'Agricultura Mejorada',
        'description': 'Incrementa la producción de alimentos.',
        'requiredAcademyLevel': 2,
        'cost': {'wood': 200, 'stone': 100, 'silver': 50},
        'researchTime': Duration(minutes: 10).inSeconds, // Tiempo en segundos
      },
      {
        'name': 'Defensas Fortificadas',
        'description': 'Incrementa la defensa de las murallas.',
        'requiredAcademyLevel': 3,
        'cost': {'wood': 300, 'stone': 200, 'silver': 100},
        'researchTime': Duration(minutes: 20).inSeconds,
      },
      {
        'name': 'Comercio Avanzado',
        'description': 'Reduce el costo de intercambio en el mercado.',
        'requiredAcademyLevel': 4,
        'cost': {'wood': 400, 'stone': 300, 'silver': 150},
        'researchTime': Duration(minutes: 30).inSeconds,
      },
    ];

    for (var tech in technologies) {
      await DbService.technologiesCollection.updateOne(
        {'name': tech['name']},
        {'\$set': tech},
        upsert: true,
      );
    }

    print('TechnologyService: Tecnologías inicializadas.');
  }
}
