import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ConfiguracionFirebase {
  // Prevenir instanciación
  ConfiguracionFirebase._();

  // Instancias de Firebase
  static FirebaseFirestore? _firestore;
  static FirebaseAuth? _auth;
  static FirebaseStorage? _storage;

  // Getters para acceder a las instancias
  static FirebaseFirestore get firestore {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }

  static FirebaseAuth get auth {
    _auth ??= FirebaseAuth.instance;
    return _auth!;
  }

  static FirebaseStorage get storage {
    _storage ??= FirebaseStorage.instance;
    return _storage!;
  }

  // Inicializar Firebase
  static Future<void> inicializar({required options}) async {
    try {
      await Firebase.initializeApp();
      
      // Configurar Firestore
      configurarFirestore();
      
      print('✅ Firebase inicializado correctamente');
    } catch (e) {
      print('❌ Error al inicializar Firebase: $e');
      rethrow;
    }
  }

  // Configuración de Firestore
  static void configurarFirestore() {
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Nombres de colecciones
  static const String coleccionUsuarios = 'usuarios';
  static const String coleccionEstudiantes = 'estudiantes';
  static const String coleccionAtenciones = 'atenciones';
  static const String coleccionCitas = 'citas';
  static const String coleccionFacultades = 'facultades';
  static const String coleccionProgramas = 'programas';
  static const String coleccionPsicologos = 'psicologos';
  static const String coleccionConfiguracion = 'configuracion';

  // Referencias a colecciones
  static CollectionReference<Map<String, dynamic>> get usuarios =>
      firestore.collection(coleccionUsuarios);

  static CollectionReference<Map<String, dynamic>> get estudiantes =>
      firestore.collection(coleccionEstudiantes);

  static CollectionReference<Map<String, dynamic>> get atenciones =>
      firestore.collection(coleccionAtenciones);

  static CollectionReference<Map<String, dynamic>> get citas =>
      firestore.collection(coleccionCitas);

  static CollectionReference<Map<String, dynamic>> get facultades =>
      firestore.collection(coleccionFacultades);

  static CollectionReference<Map<String, dynamic>> get programas =>
      firestore.collection(coleccionProgramas);

  static CollectionReference<Map<String, dynamic>> get psicologos =>
      firestore.collection(coleccionPsicologos);

  static CollectionReference<Map<String, dynamic>> get configuracion =>
      firestore.collection(coleccionConfiguracion);

  // Obtener timestamp del servidor
  static FieldValue get timestamp => FieldValue.serverTimestamp();

  // Obtener un nuevo ID de documento
  static String nuevoId(String coleccion) {
    return firestore.collection(coleccion).doc().id;
  }

  // Verificar si el usuario está autenticado
  static bool get estaAutenticado => auth.currentUser != null;

  // Obtener usuario actual
  static User? get usuarioActual => auth.currentUser;

  // Cerrar sesión
  static Future<void> cerrarSesion() async {
    await auth.signOut();
  }
}