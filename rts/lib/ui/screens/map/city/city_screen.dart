import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rts/blocs/city/city_bloc.dart';
import 'package:rts/blocs/city/city_event.dart';
import 'package:rts/blocs/city/city_states.dart';
import 'package:rts/data/serverconection.dart';
import 'package:rts/models/city.dart';
import 'package:rts/ui/screens/map/city/city_layout.dart';
import 'package:rts/ui/screens/map/city/construction_queue.dart';
import 'package:rts/ui/screens/map/city/resources_bar.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({Key? key}) : super(key: key);

  @override
  _CityScreenState createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  StreamSubscription<Map<String, dynamic>>? _subscription;

  @override
  void initState() {
    super.initState();
    print("CityScreen: initState called");

    // Solicitar carga inicial de la ciudad
    context.read<CityBloc>().add(CityLoadRequested());
    print("CityLoadRequested event added to CityBloc");

    // Escuchar actualizaciones del servidor
    _subscription = ServerConnection().stream.listen((data) {
      print("CityScreen: Received data from server: $data");
      if (data['action'] == 'city_update') {
        print(
            "CityScreen: Triggering CityUpdated event with data: ${data['data']}");
        context.read<CityBloc>().add(CityUpdated(data['data']));
      }
    });
  }

  @override
  void dispose() {
    print("CityScreen: dispose called, canceling subscription");
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("CityScreen: build called");
    return BlocBuilder<CityBloc, CityState>(
      builder: (context, state) {
        print("CityScreen: Current state is $state");

        if (state is CityInitial || state is CityLoading) {
          print("CityScreen: Loading state");
          return const Center(child: CircularProgressIndicator());
        } else if (state is CityLoaded) {
          print("CityScreen: CityLoaded state with city: ${state.city}");
          final city = state.city;
          return Scaffold(
            backgroundColor: Colors.blueGrey[800],
            body: Column(
              children: [
                _buildTopBar(),
                ResourcesBar(),
                Expanded(
                  // Envuelve el cuerpo principal para asegurar límites
                  child: Column(
                    children: [
                      Expanded(
                        child: CityLayout(city: city),
                      ),
                      const ConstructionQueue(),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (state is CityError) {
          print("CityScreen: Error state with message: ${state.message}");
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else {
          print("CityScreen: Unhandled state: $state");
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildTopBar() {
    print("CityScreen: Building TopBar");
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.map, color: Colors.white),
            onPressed: () {
              print("CityScreen: Back to map");
              Navigator.pop(context); // Volver al mapa
            },
          ),
          const Spacer(),
          const Text(
            'Ciudad',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
