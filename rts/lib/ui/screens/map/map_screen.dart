import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rts/blocs/map/map_bloc.dart';
import 'package:rts/blocs/map/map_event.dart';
import 'package:rts/blocs/map/map_states.dart';
import 'package:rts/data/serverconection.dart';
import 'package:rts/models/city.dart';
import 'package:rts/models/island.dart';
import 'package:rts/models/maptiles.dart';

class MapScreen extends StatefulWidget {
  final ServerConnection serverConnection;

  const MapScreen({Key? key, required this.serverConnection}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    BlocProvider.of<MapBloc>(context).add(LoadMapEvent());
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa del Mundo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              BlocProvider.of<MapBloc>(context).add(LoadMapEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MapLoaded) {
            return _buildMapView(state.mapTiles, state.playerCity);
          } else if (state is MapError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Estado desconocido'));
          }
        },
      ),
    );
  }

  Widget _buildMapView(List<MapTile> mapTiles, City? playerCity) {
    double tileSize = 40.0; // Tamaño de cada tile
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.5,
      maxScale: 4.0,
      boundaryMargin: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: mapTiles.map((tile) {
              return Positioned(
                left: tile.x * tileSize,
                top: tile.y * tileSize,
                width: tileSize,
                height: tileSize,
                child: MapTileWidget(
                  tile: tile,
                  playerCity: playerCity,
                  onTap: () {
                    if (tile.isIsland) {
                      _showIslandInfoDialog(context, tile.island!, playerCity);
                    }
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showIslandInfoDialog(
      BuildContext context, Island island, City? playerCity) {
    bool isPlayerIsland =
        playerCity != null && island.islandId == playerCity.islandId;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Información de la Isla'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Isla en posición (${island.x}, ${island.y})'),
              Text(
                'Ciudades en la isla: ${island.slots.where((slot) => slot != null).length}/5',
              ),
              if (isPlayerIsland)
                const Text(
                  'Esta es tu isla.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  if (isPlayerIsland) {
                    Navigator.pushNamed(context, '/city');
                  }
                },
                child: Text(isPlayerIsland ? 'Ir a tu ciudad' : 'Cerrar'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MapTileWidget extends StatelessWidget {
  final MapTile tile;
  final City? playerCity;
  final VoidCallback onTap;

  const MapTileWidget({
    Key? key,
    required this.tile,
    required this.playerCity,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color tileColor = _getTileColor();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54, width: 0.5),
          color: tileColor,
        ),
        child: Center(
          child: _getTileIcon(),
        ),
      ),
    );
  }

  Color _getTileColor() {
    if (tile.isIsland) {
      if (playerCity != null && tile.island!.islandId == playerCity?.islandId) {
        return Colors.yellow[200]!;
      } else if (tile.island!.slots.any((slot) => slot != null)) {
        return Colors.green[300]!;
      } else {
        return Colors.green[100]!;
      }
    } else {
      return Colors.blue[300]!;
    }
  }

  Widget? _getTileIcon() {
    if (tile.isIsland) {
      if (playerCity != null && tile.island!.islandId == playerCity?.islandId) {
        return const Icon(Icons.home, color: Colors.black);
      } else if (tile.island!.slots.any((slot) => slot != null)) {
        return const Icon(Icons.location_city, color: Colors.black);
      } else {
        return const Icon(Icons.landscape, color: Colors.black);
      }
    }
    return null;
  }
}
