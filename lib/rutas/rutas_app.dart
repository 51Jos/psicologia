import 'package:flutter/material.dart';
import 'package:psicologia/features/autenticacion/vistas/login_vista.dart';
import 'package:psicologia/features/citas/vistas/lista_cita.dart';
import 'package:psicologia/features/citas/vistas/formulario_cita_vista.dart';
class RutasApp {
  // Prevenir instanciación
  RutasApp._();

  // Nombres de rutas
  static const String login = '/';
  static const String dashboard = '/dashboard';
  
  // Rutas de Atenciones
  static const String listaAtenciones = '/atenciones';
  static const String registrarAtencion = '/atenciones/registrar';
  static const String editarAtencion = '/atenciones/editar';
  
  // Rutas de Citas
  static const String listaCitas = '/citas';
  static const String agendarCita = '/citas/agendar';
  static const String editarCita = '/citas/editar';
  
  // Rutas de Estudiantes
  static const String listaEstudiantes = '/estudiantes';
  static const String registrarEstudiante = '/estudiantes/registrar';
  static const String editarEstudiante = '/estudiantes/editar';
  static const String perfilEstudiante = '/estudiantes/perfil';
  
  // Rutas de Reportes
  static const String reportes = '/reportes';
  static const String reporteAtenciones = '/reportes/atenciones';
  static const String reporteCitas = '/reportes/citas';
  static const String estadisticas = '/estadisticas';
  
  // Rutas de Configuración
  static const String configuracion = '/configuracion';
  static const String perfil = '/perfil';
  static const String usuarios = '/usuarios';

  // Mapa de rutas estáticas
  static Map<String, WidgetBuilder> get rutas => {
    login: (_) => const LoginVista(),
    agendarCita: (_) => const FormularioCitaVista(),
    listaAtenciones: (_) => const ListaCita(),
    //registrarAtencion: (_) => const RegistrarAtencionVista(),
    //listaCitas: (_) => const ListaCitasVista(),
    //agendarCita: (_) => const AgendarCitaVista(),
    // Agregar más rutas según se vayan creando las vistas
  };


 
  // Navegación con animaciones personalizadas
  static Route<T> slideTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Route<T> fadeTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  // Helpers de navegación
  static Future<T?> navegar<T>(BuildContext context, String ruta, {Object? arguments}) {
    return Navigator.pushNamed<T>(context, ruta, arguments: arguments);
  }

  static Future<T?> reemplazar<T>(BuildContext context, String ruta, {Object? arguments}) {
    return Navigator.pushReplacementNamed<T, T>(context, ruta, arguments: arguments);
  }

  static Future<T?> navegarYLimpiar<T>(BuildContext context, String ruta, {Object? arguments}) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      ruta,
      (route) => false,
      arguments: arguments,
    );
  }

  static void volver<T>(BuildContext context, [T? resultado]) {
    Navigator.pop(context, resultado);
  }

  static bool puedeVolver(BuildContext context) {
    return Navigator.canPop(context);
  }
}

// Placeholder temporal para vistas que aún no existen
class PerfilEstudianteVista extends StatelessWidget {
  final String estudianteId;
  
  const PerfilEstudianteVista({
    super.key,
    required this.estudianteId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Estudiante'),
      ),
      body: Center(
        child: Text('Estudiante ID: $estudianteId'),
      ),
    );
  }
}