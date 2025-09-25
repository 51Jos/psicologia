import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:psicologia/firebase_options.dart';
import 'nucleo/configuracion_firebase.dart';
import 'compartidos/tema/tema_app.dart';
import 'rutas/rutas_app.dart';
import 'features/autenticacion/controladores/auth_controlador.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthControlador()),
      ],
      child: MaterialApp(
        title: 'Sistema de Psicología Estudiantil',
        debugShowCheckedModeBanner: false,
        theme: TemaApp.temaClaro,
        darkTheme: TemaApp.temaOscuro,
        themeMode: ThemeMode.light,
        initialRoute: RutasApp.login,
        routes: RutasApp.rutas,
        builder: (context, child) {
          return MediaQuery(
            // Limitar el factor de escala del texto para evitar problemas con textos muy grandes
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}