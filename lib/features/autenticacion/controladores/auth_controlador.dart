import 'package:flutter/material.dart';
import '../servicios/auth_servicio.dart';
import '../modelos/usuario.dart';
import '../modelos/credenciales_modelo.dart';
import '../estados/auth_estado.dart';
import '../../../rutas/rutas_app.dart';

class AuthControlador extends ChangeNotifier {
  final AuthServicio _authServicio = AuthServicio();
  
  // Estado actual
  AuthEstado _estado = const AuthInicial();
  AuthEstado get estado => _estado;

  // Usuario actual
  UsuarioModelo? _usuarioActual;
  UsuarioModelo? get usuarioActual => _usuarioActual;

  // Tipo de acceso seleccionado
  TipoAcceso _tipoAcceso = TipoAcceso.psicologo;
  TipoAcceso get tipoAcceso => _tipoAcceso;

  // Constructor
  AuthControlador() {
    _verificarSesionActual();
  }

  // Cambiar tipo de acceso
  void cambiarTipoAcceso(TipoAcceso tipo) {
    _tipoAcceso = tipo;
    notifyListeners();
  }

  // Verificar si hay una sesión activa
  Future<void> _verificarSesionActual() async {
    final user = _authServicio.usuarioActual;
    
    if (user != null) {
      _estado = const AuthCargando();
      notifyListeners();
      
      final usuario = await _authServicio.obtenerDatosUsuario(user.uid);
      
      if (usuario != null) {
        _usuarioActual = usuario;
        _estado = AuthExito(usuario);
      } else {
        _estado = const AuthNoAutenticado();
      }
    } else {
      _estado = const AuthNoAutenticado();
    }
    
    notifyListeners();
  }

  // Iniciar sesión
  Future<void> iniciarSesion({
    required String usuario,
    required String password,
    required bool recordarme,
    required BuildContext context,
  }) async {
    try {
      _estado = const AuthCargando();
      notifyListeners();

      final credenciales = CredencialesModelo(
        usuario: usuario,
        password: password,
        recordarme: recordarme,
        tipoAcceso: _tipoAcceso,
      );

      final usuarioAutenticado = await _authServicio.iniciarSesion(credenciales);
      
      _usuarioActual = usuarioAutenticado;
      _estado = AuthExito(usuarioAutenticado);
      notifyListeners();

      // Navegar según el tipo de usuario
      if (context.mounted) {
        if (usuarioAutenticado.esAdministrador) {
          RutasApp.navegarYLimpiar(context, RutasApp.dashboard);
        } else if (usuarioAutenticado.esEstudiante) {
          RutasApp.navegarYLimpiar(context, RutasApp.reservasEstudiante);
        } else if (usuarioAutenticado.esPsicologo) {
          // Verificar si el psicólogo tiene datos completos
          if (usuarioAutenticado.nombres.isEmpty || usuarioAutenticado.apellidos.isEmpty) {
            RutasApp.navegarYLimpiar(context, RutasApp.perfil);
          } else {
            RutasApp.navegarYLimpiar(context, RutasApp.listaAtenciones);
          }
        } else {
          RutasApp.navegarYLimpiar(context, RutasApp.listaAtenciones);
        }
      }
    } catch (e) {
      _estado = AuthError(e.toString());
      notifyListeners();
      
      // Mostrar error
      if (context.mounted) {
        _mostrarError(context, e.toString());
      }
    }
  }

  // Cerrar sesión
  Future<void> cerrarSesion(BuildContext context) async {
    try {
      _estado = const AuthCerrandoSesion();
      notifyListeners();

      await _authServicio.cerrarSesion();
      
      _usuarioActual = null;
      _estado = const AuthNoAutenticado();
      notifyListeners();

      // Navegar al login
      if (context.mounted) {
        RutasApp.navegarYLimpiar(context, RutasApp.login);
      }
    } catch (e) {
      _estado = AuthError(e.toString());
      notifyListeners();
      
      if (context.mounted) {
        _mostrarError(context, e.toString());
      }
    }
  }

  // Recuperar contraseña
  Future<void> recuperarPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await _authServicio.recuperarPassword(email);

      if (context.mounted) {
        _mostrarExito(
          context,
          'Se ha enviado un email de recuperación a $email',
        );
      }
    } catch (e) {
      if (context.mounted) {
        _mostrarError(context, e.toString());
      }
    }
  }

  // Registrar estudiante
  Future<void> registrarEstudiante({
    required BuildContext context,
    required String codigo,
    required String password,
    required String nombres,
    required String apellidos,
    String? telefono,
  }) async {
    try {
      _estado = const AuthCargando();
      notifyListeners();

      final email = '$codigo@ucss.pe';

      final usuarioCreado = await _authServicio.registrarEstudiante(
        email: email,
        password: password,
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
      );

      _usuarioActual = usuarioCreado;
      _estado = AuthExito(usuarioCreado);
      notifyListeners();

      // Navegar a la pantalla de reservas
      if (context.mounted) {
        _mostrarExito(context, '¡Cuenta creada exitosamente!');
        RutasApp.navegarYLimpiar(context, RutasApp.reservasEstudiante);
      }
    } catch (e) {
      _estado = AuthError(e.toString());
      notifyListeners();

      if (context.mounted) {
        _mostrarError(context, e.toString());
      }
    }
  }

  // Limpiar error
  void limpiarError() {
    if (_estado is AuthError) {
      _estado = const AuthNoAutenticado();
      notifyListeners();
    }
  }

  // Helpers para mostrar mensajes
  void _mostrarError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _mostrarExito(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Getters útiles
  bool get estaCargando => _estado is AuthCargando;
  bool get estaAutenticado => _estado is AuthExito;
  bool get tieneError => _estado is AuthError;
  String? get mensajeError => _estado is AuthError ? (_estado as AuthError).mensaje : null;

}