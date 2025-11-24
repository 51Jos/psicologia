import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../nucleo/configuracion_firebase.dart';
import '../../autenticacion/modelos/usuario.dart';

class PerfilServicio {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener perfil del estudiante actual
  Future<UsuarioModelo?> obtenerPerfilActual() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await ConfiguracionFirebase.usuarios.doc(user.uid).get();

      if (!doc.exists) return null;

      return UsuarioModelo.fromFirestore(doc);
    } catch (e) {
      print('Error al obtener perfil: $e');
      return null;
    }
  }

  // Stream del perfil para actualizaciones en tiempo real
  Stream<UsuarioModelo?> streamPerfil() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return ConfiguracionFirebase.usuarios
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UsuarioModelo.fromFirestore(doc);
    });
  }

  // Actualizar perfil (sin email)
  Future<bool> actualizarPerfil(UsuarioModelo usuario) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Preparar datos para actualizar (sin email)
      final data = {
        'nombres': usuario.nombres,
        'apellidos': usuario.apellidos,
        'telefono': usuario.telefono,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      };

      await ConfiguracionFirebase.usuarios.doc(user.uid).update(data);

      return true;
    } catch (e) {
      print('Error al actualizar perfil: $e');
      return false;
    }
  }

  // Cambiar contraseña
  Future<Map<String, dynamic>> cambiarContrasena({
    required String contrasenaActual,
    required String nuevaContrasena,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'exito': false, 'mensaje': 'No hay usuario autenticado'};
      }

      // Reautenticar usuario
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: contrasenaActual,
      );

      await user.reauthenticateWithCredential(credential);

      // Cambiar contraseña
      await user.updatePassword(nuevaContrasena);

      return {'exito': true, 'mensaje': 'Contraseña actualizada correctamente'};
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al cambiar contraseña';

      switch (e.code) {
        case 'wrong-password':
          mensaje = 'La contraseña actual es incorrecta';
          break;
        case 'weak-password':
          mensaje = 'La nueva contraseña es muy débil';
          break;
        case 'requires-recent-login':
          mensaje = 'Por seguridad, vuelve a iniciar sesión';
          break;
        default:
          mensaje = 'Error: ${e.message}';
      }

      return {'exito': false, 'mensaje': mensaje};
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error inesperado: $e'};
    }
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}
