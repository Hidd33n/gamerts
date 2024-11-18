import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rts/blocs/city/city_bloc.dart';
import 'package:rts/blocs/city/city_states.dart';

class ResourcesBar extends StatelessWidget {
  const ResourcesBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("ResourcesBar: build called");
    return BlocBuilder<CityBloc, CityState>(
      builder: (context, state) {
        if (state is CityLoaded) {
          final resources = state.city.resources;
          return Container(
            color: Colors.blueGrey[900],
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              'Madera: ${resources['wood']} | Piedra: ${resources['stone']} | Plata: ${resources['silver']}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
