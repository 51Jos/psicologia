import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../citas/modelos/estudiante_modelo.dart';

class PerfilServicio {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener perfil del estudiante actual
  Future<EstudianteModelo?> obtenerPerfilActual() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('estudiantes')
          .doc(user.uid)
          .get();

      if (!doc.exists) return null;

      return EstudianteModelo.fromFirestore(doc);
    } catch (e) {
      print('Error al obtener perfil: $e');
      return null;
    }
  }

  // Stream del perfil para actualizaciones en tiempo real
  Stream<EstudianteModelo?> streamPerfil() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('estudiantes')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return EstudianteModelo.fromFirestore(doc);
    });
  }

  // Actualizar perfil (sin email)
  Future<bool> actualizarPerfil(EstudianteModelo estudiante) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Preparar datos para actualizar (sin email)
      final data = {
        'nombres': estudiante.nombres,
        'apellidos': estudiante.apellidos,
        'telefono': estudiante.telefono,
        'facultad': estudiante.facultad,
        'programa': estudiante.programa,
        'ciclo': estudiante.ciclo,
        'fechaNacimiento': estudiante.fechaNacimiento != null
            ? Timestamp.fromDate(estudiante.fechaNacimiento!)
            : null,
        'genero': estudiante.genero,
        'direccion': estudiante.direccion,
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('estudiantes')
          .doc(user.uid)
          .update(data);

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
