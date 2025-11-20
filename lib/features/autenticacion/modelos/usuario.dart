import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoUsuario { administrador, psicologo, estudiante }

class UsuarioModelo {
  final String id;
  final String email;
  final String nombres;
  final String apellidos;
  final TipoUsuario tipo;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime? ultimoAcceso;
  final String? foto;
  final String? telefono;
  final String? especialidad;
  final Map<String, dynamic>? metadata;

  UsuarioModelo({
    required this.id,
    required this.email,
    required this.nombres,
    required this.apellidos,
    required this.tipo,
    this.activo = true,
    required this.fechaCreacion,
    this.ultimoAcceso,
    this.foto,
    this.telefono,
    this.especialidad,
    this.metadata,
  });

  // Constructor vacío
  factory UsuarioModelo.vacio() {
    return UsuarioModelo(
      id: '',
      email: '',
      nombres: '',
      apellidos: '',
      tipo: TipoUsuario.psicologo,
      fechaCreacion: DateTime.now(),
    );
  }

  // Desde Firestore
  factory UsuarioModelo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UsuarioModelo(
      id: doc.id,
      email: data['email'] ?? '',
      nombres: data['nombres'] ?? '',
      apellidos: data['apellidos'] ?? '',
      tipo: _stringToTipoUsuario(data['tipo'] ?? 'psicologo'),
      activo: data['activo'] ?? true,
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ultimoAcceso: (data['ultimoAcceso'] as Timestamp?)?.toDate(),
      foto: data['foto'],
      telefono: data['telefono'],
      especialidad: data['especialidad'],
      metadata: data['metadata'],
    );
  }

  // Desde JSON
  factory UsuarioModelo.fromJson(Map<String, dynamic> json) {
    return UsuarioModelo(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      tipo: _stringToTipoUsuario(json['tipo'] ?? 'psicologo'),
      activo: json['activo'] ?? true,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] ?? DateTime.now().toIso8601String()),
      ultimoAcceso: json['ultimoAcceso'] != null
          ? DateTime.parse(json['ultimoAcceso'])
          : null,
      foto: json['foto'],
      telefono: json['telefono'],
      especialidad: json['especialidad'],
      metadata: json['metadata'],
    );
  }

  // A Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nombres': nombres,
      'apellidos': apellidos,
      'tipo': _tipoUsuarioToString(tipo),
      'activo': activo,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'ultimoAcceso': ultimoAcceso != null ? Timestamp.fromDate(ultimoAcceso!) : null,
      'foto': foto,
      'telefono': telefono,
      'especialidad': especialidad,
      'metadata': metadata,
    };
  }

  // A JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombres': nombres,
      'apellidos': apellidos,
      'tipo': _tipoUsuarioToString(tipo),
      'activo': activo,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'ultimoAcceso': ultimoAcceso?.toIso8601String(),
      'foto': foto,
      'telefono': telefono,
      'especialidad': especialidad,
      'metadata': metadata,
    };
  }

  // Getters útiles
  String get nombreCompleto => '$nombres $apellidos'.trim();
  
  String get iniciales {
    String inicialesNombre = nombres.isNotEmpty ? nombres[0].toUpperCase() : '';
    String inicialesApellido = apellidos.isNotEmpty ? apellidos[0].toUpperCase() : '';
    return '$inicialesNombre$inicialesApellido';
  }

  bool get esAdministrador => tipo == TipoUsuario.administrador;
  bool get esPsicologo => tipo == TipoUsuario.psicologo;
  bool get esEstudiante => tipo == TipoUsuario.estudiante;

  // CopyWith
  UsuarioModelo copyWith({
    String? id,
    String? email,
    String? nombres,
    String? apellidos,
    TipoUsuario? tipo,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? ultimoAcceso,
    String? foto,
    String? telefono,
    Map<String, dynamic>? metadata,
  }) {
    return UsuarioModelo(
      id: id ?? this.id,
      email: email ?? this.email,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      tipo: tipo ?? this.tipo,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      ultimoAcceso: ultimoAcceso ?? this.ultimoAcceso,
      foto: foto ?? this.foto,
      telefono: telefono ?? this.telefono,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helpers privados
  static TipoUsuario _stringToTipoUsuario(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'administrador':
        return TipoUsuario.administrador;
      case 'estudiante':
        return TipoUsuario.estudiante;
      case 'psicologo':
      default:
        return TipoUsuario.psicologo;
    }
  }

  static String _tipoUsuarioToString(TipoUsuario tipo) {
    switch (tipo) {
      case TipoUsuario.administrador:
        return 'administrador';
      case TipoUsuario.psicologo:
        return 'psicologo';
      case TipoUsuario.estudiante:
        return 'estudiante';
    }
  }

  @override
  String toString() {
    return 'UsuarioModelo(id: $id, email: $email, tipo: ${_tipoUsuarioToString(tipo)})';
  }
}