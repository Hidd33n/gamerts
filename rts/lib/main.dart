import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rts/blocs/city/city_bloc.dart';
import 'package:rts/data/serverconection.dart';
import 'package:rts/ui/screens/auth/login/login_screen.dart';
import 'package:rts/ui/screens/auth/register/register_screen.dart';
import 'package:rts/ui/screens/map/city/city_screen.dart';
import 'package:rts/ui/screens/map/map_screen.dart';
import 'blocs/map/map_bloc.dart';

void main() {
  final serverConnection = ServerConnection();
  serverConnection.connect(); // Iniciar la conexión global

  runApp(RTS(serverConnection: serverConnection));
}

class RTS extends StatelessWidget {
  final ServerConnection serverConnection;

  const RTS({Key? key, required this.serverConnection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(serverConnection: serverConnection),
      routes: {
        '/login': (context) => LoginScreen(serverConnection: serverConnection),
        '/register': (context) =>
            RegisterScreen(serverConnection: serverConnection),
        '/map': (context) => MultiBlocProvider(
              providers: [
                BlocProvider<MapBloc>(
                  create: (context) =>
                      MapBloc(serverConnection: serverConnection),
                ),
              ],
              child: MapScreen(serverConnection: serverConnection),
            ),
        '/city': (context) => BlocProvider(
              create: (context) => CityBloc(serverConnection),
              child: CityScreen(),
            ),
      },
    );
  }
}
