import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rts/blocs/city/city_bloc.dart';
import 'package:rts/blocs/city/city_event.dart';
import 'package:rts/blocs/city/city_states.dart';

class ConstructionQueue extends StatefulWidget {
  const ConstructionQueue({Key? key}) : super(key: key);

  @override
  _ConstructionQueueState createState() => _ConstructionQueueState();
}

class _ConstructionQueueState extends State<ConstructionQueue> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        // Redibujar cada segundo
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CityBloc, CityState>(
      builder: (context, state) {
        if (state is CityLoaded) {
          final city = state.city;

          return Container(
            color: Colors.grey[850],
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cola de Construcción',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (city.constructionQueue.isEmpty)
                  const Center(
                    child: Text(
                      'No hay construcciones en curso.',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: city.constructionQueue.length,
                    itemBuilder: (context, index) {
                      final queueItem = city.constructionQueue[index];
                      final buildingName = queueItem['buildingName'];
                      final finishTime =
                          DateTime.parse(queueItem['finishTime']);
                      final remainingTime =
                          finishTime.difference(DateTime.now());
                      final displayedTime = remainingTime.isNegative
                          ? Duration.zero
                          : remainingTime;

                      return Card(
                        color: Colors.blueGrey[700],
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            _getBuildingIcon(buildingName),
                            size: 36,
                            color: Colors.lightBlueAccent,
                          ),
                          title: Text(
                            '$buildingName',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          subtitle: Text(
                            'Nivel: ${queueItem['level']} - ${_formatDuration(displayedTime)} restantes',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 14),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.cancel,
                                color: Colors.redAccent),
                            onPressed: () {
                              context
                                  .read<CityBloc>()
                                  .add(ConstructionCancelRequested(index));
                            },
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  IconData _getBuildingIcon(String buildingName) {
    switch (buildingName) {
      case 'Aserradero':
        return Icons.local_florist;
      case 'Cantera':
        return Icons.terrain;
      case 'Mina de Plata':
        return Icons.attach_money;
      case 'Granja':
        return Icons.grass;
      case 'Senado':
        return Icons.account_balance;
      case 'Cuartel':
        return Icons.shield;
      case 'Muralla':
        return Icons.security;
      case 'Puerto':
        return Icons.directions_boat;
      case 'Almacén':
        return Icons.store;
      default:
        return Icons.location_city;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
  }
}
