import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../nucleo/configuracion_firebase.dart';
import '../modelos/usuario.dart';
import '../modelos/credenciales_modelo.dart';

class AuthServicio {
  final FirebaseAuth _auth = ConfiguracionFirebase.auth;
  final FirebaseFirestore _firestore = ConfiguracionFirebase.firestore;

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get usuarioActual => _auth.currentUser;

  // Obtener datos del usuario desde Firestore
  Future<UsuarioModelo?> obtenerDatosUsuario(String uid) async {
    try {
      final doc = await ConfiguracionFirebase.usuarios.doc(uid).get();
      
      if (doc.exists) {
        return UsuarioModelo.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error obteniendo datos del usuario: $e');
      return null;
    }
  }

  // Iniciar sesión
  Future<UsuarioModelo> iniciarSesion(CredencialesModelo credenciales) async {
    try {
      // Agregar dominio según el tipo de acceso
      String email = credenciales.usuario;
      if (!email.contains('@')) {
        email = '$email@ucss.pe';
      }

      // Autenticar con Firebase
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: credenciales.password,
      );

      if (userCredential.user == null) {
        throw Exception('Error al iniciar sesión');
      }

      // Obtener datos del usuario desde Firestore
      final usuario = await obtenerDatosUsuario(userCredential.user!.uid);

      if (usuario == null) {
        throw Exception('Usuario no encontrado en la base de datos');
      }

      // Verificar tipo de usuario
      // Los estudiantes pueden iniciar sesión siempre
      if (usuario.esEstudiante) {
        await actualizarUltimoAcceso(usuario.id);
        return usuario;
      }

      // Para administradores y psicólogos, verificar permisos
      if (credenciales.tipoAcceso == TipoAcceso.administrador && !usuario.esAdministrador) {
        await _auth.signOut();
        throw Exception('No tienes permisos de administrador');
      }

      if (credenciales.tipoAcceso == TipoAcceso.psicologo && !usuario.esPsicologo) {
        await _auth.signOut();
        throw Exception('No tienes permisos de psicólogo');
      }

      // Actualizar último acceso
      await actualizarUltimoAcceso(usuario.id);

      return usuario;
    } on FirebaseAuthException catch (e) {
      throw _manejarErrorFirebase(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Detectar tipo de usuario por email
  TipoUsuario detectarTipoPorEmail(String email) {
    if (email.endsWith('@ucss.edu.pe')) {
      // Psicólogo: primera letra nombre + apellido@ucss.edu.pe
      return TipoUsuario.psicologo;
    } else if (email.endsWith('@ucss.pe')) {
      // Estudiante: codigo@ucss.pe
      return TipoUsuario.estudiante;
    }
    return TipoUsuario.psicologo; // Default
  }

  // Registrar estudiante
  Future<UsuarioModelo> registrarEstudiante({
    required String email,
    required String password,
    required String nombres,
    required String apellidos,
    String? telefono,
  }) async {
    try {
      // Validar que sea email de estudiante
      if (!email.endsWith('@ucss.pe')) {
        throw Exception('El correo debe ser un código de estudiante válido (@ucss.pe)');
      }

      // Crear usuario en Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Error al crear usuario');
      }

      // Crear documento en Firestore
      final usuario = UsuarioModelo(
        id: userCredential.user!.uid,
        email: email,
        nombres: nombres,
        apellidos: apellidos,
        tipo: TipoUsuario.estudiante,
        activo: true,
        fechaCreacion: DateTime.now(),
        telefono: telefono,
      );

      await ConfiguracionFirebase.usuarios.doc(usuario.id).set(usuario.toFirestore());

      return usuario;
    } on FirebaseAuthException catch (e) {
      throw _manejarErrorFirebase(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Registrar psicólogo (para uso administrativo o inicial)
  Future<UsuarioModelo> registrarPsicologo({
    required String email,
    required String password,
  }) async {
    try {
      // Validar que sea email de psicólogo
      if (!email.endsWith('@ucss.edu.pe')) {
        throw Exception('El correo debe ser un email institucional válido (@ucss.edu.pe)');
      }

      // Crear usuario en Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Error al crear usuario');
      }

      // Crear documento en Firestore con datos mínimos
      final usuario = UsuarioModelo(
        id: userCredential.user!.uid,
        email: email,
        nombres: '', // Se llenará en el perfil
        apellidos: '', // Se llenará en el perfil
        tipo: TipoUsuario.psicologo,
        activo: true,
        fechaCreacion: DateTime.now(),
      );

      await ConfiguracionFirebase.usuarios.doc(usuario.id).set(usuario.toFirestore());

      return usuario;
    } on FirebaseAuthException catch (e) {
      throw _manejarErrorFirebase(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Actualizar perfil de psicólogo
  Future<bool> actualizarPerfilPsicologo({
    required String userId,
    required String nombres,
    required String apellidos,
    String? telefono,
    String? especialidad,
  }) async {
    try {
      final Map<String, dynamic> datos = {
        'nombres': nombres,
        'apellidos': apellidos,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      };

      if (telefono != null && telefono.isNotEmpty) {
        datos['telefono'] = telefono;
      }

      if (especialidad != null && especialidad.isNotEmpty) {
        datos['especialidad'] = especialidad;
      }

      await ConfiguracionFirebase.usuarios.doc(userId).update(datos);
      return true;
    } catch (e) {
      debugPrint('Error al actualizar perfil: $e');
      return false;
    }
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: ${e.toString()}');
    }
  }

  // Recuperar contraseña
  Future<void> recuperarPassword(String email) async {
    try {
      if (!email.contains('@')) {
        email = '$email@sistema.edu.pe';
      }
      
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _manejarErrorFirebase(e);
    } catch (e) {
      throw Exception('Error al enviar email de recuperación: ${e.toString()}');
    }
  }

  // Cambiar contraseña
  Future<void> cambiarPassword(String passwordActual, String passwordNuevo) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Re-autenticar al usuario
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordActual,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Cambiar contraseña
      await user.updatePassword(passwordNuevo);
    } on FirebaseAuthException catch (e) {
      throw _manejarErrorFirebase(e);
    } catch (e) {
      throw Exception('Error al cambiar contraseña: ${e.toString()}');
    }
  }

  // Actualizar último acceso
  Future<void> actualizarUltimoAcceso(String uid) async {
    try {
      await ConfiguracionFirebase.usuarios.doc(uid).update({
        'ultimoAcceso': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error actualizando último acceso: $e');
    }
  }

  // Verificar si el usuario está autenticado
  bool get estaAutenticado => _auth.currentUser != null;

  // Obtener token del usuario
  Future<String?> obtenerToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } catch (e) {
      print('Error obteniendo token: $e');
      return null;
    }
  }

  // Manejar errores de Firebase
  String _manejarErrorFirebase(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Usuario deshabilitado';
      case 'too-many-requests':
        return 'Demasiados intentos. Intente más tarde';
      case 'network-request-failed':
        return 'Error de conexión. Verifique su internet';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      case 'email-already-in-use':
        return 'El email ya está en uso';
      case 'weak-password':
        return 'La contraseña es muy débil';
      default:
        return 'Error: ${e.message ?? 'Error desconocido'}';
    }
  }
}