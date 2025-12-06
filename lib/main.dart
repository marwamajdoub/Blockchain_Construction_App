// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/defauts/camera_screen.dart';
import 'screens/defauts/liste_defauts_screen.dart';
import 'screens/home/home_screen.dart';
import 'providers/defauts_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialisation de Firebase sans options
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DefautsProvider()),
      ],
      child: MaterialApp(
        title: 'Détection de Défauts',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
          '/camera': (context) => CameraScreen(),
          '/liste_defauts': (context) => ListeDefautsScreen(),
        },
      ),
    );
  }
}
