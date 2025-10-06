// lib/features/estudiantes/modelos/estudiante_modelo.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class EstudianteModelo {
  final String id;
  final String codigo;
  final String nombres;
  final String apellidos;
  final String email;
  final String? telefono;
  final String facultad;
  final String programa;
  final String? ciclo;
  final DateTime? fechaNacimiento;
  final String? genero;
  final String? direccion;
  final bool activo;
  final DateTime fechaRegistro;
  final DateTime? ultimaActualizacion;
  final int totalCitas;
  final int totalAtenciones;
  final Map<String, dynamic>? metadata;

  EstudianteModelo({
    required this.id,
    required this.codigo,
    required this.nombres,
    required this.apellidos,
    required this.email,
    this.telefono,
    required this.facultad,
    required this.programa,
    this.ciclo,
    this.fechaNacimiento,
    this.genero,
    this.direccion,
    this.activo = true,
    required this.fechaRegistro,
    this.ultimaActualizacion,
    this.totalCitas = 0,
    this.totalAtenciones = 0,
    this.metadata,
  });

  // Constructor vacío
  factory EstudianteModelo.vacio() {
    return EstudianteModelo(
      id: '',
      codigo: '',
      nombres: '',
      apellidos: '',
      email: '',
      facultad: '',
      programa: '',
      fechaRegistro: DateTime.now(),
    );
  }

  // Desde Firestore
  factory EstudianteModelo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return EstudianteModelo(
      id: doc.id,
      codigo: data['codigo'] ?? '',
      nombres: data['nombres'] ?? '',
      apellidos: data['apellidos'] ?? '',
      email: data['email'] ?? '',
      telefono: data['telefono'],
      facultad: data['facultad'] ?? '',
      programa: data['programa'] ?? '',
      ciclo: data['ciclo'],
      fechaNacimiento: (data['fechaNacimiento'] as Timestamp?)?.toDate(),
      genero: data['genero'],
      direccion: data['direccion'],
      activo: data['activo'] ?? true,
      fechaRegistro: (data['fechaRegistro'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ultimaActualizacion: (data['ultimaActualizacion'] as Timestamp?)?.toDate(),
      totalCitas: data['totalCitas'] ?? 0,
      totalAtenciones: data['totalAtenciones'] ?? 0,
      metadata: data['metadata'],
    );
  }

  // A Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'codigo': codigo,
      'nombres': nombres,
      'apellidos': apellidos,
      'email': email,
      'telefono': telefono,
      'facultad': facultad,
      'programa': programa,
      'ciclo': ciclo,
      'fechaNacimiento': fechaNacimiento != null 
          ? Timestamp.fromDate(fechaNacimiento!) 
          : null,
      'genero': genero,
      'direccion': direccion,
      'activo': activo,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      'ultimaActualizacion': FieldValue.serverTimestamp(),
      'totalCitas': totalCitas,
      'totalAtenciones': totalAtenciones,
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

  // Para búsqueda
  String get textoBusqueda => 
      '$codigo $nombres $apellidos $email'.toLowerCase();

  // CopyWith
  EstudianteModelo copyWith({
    String? id,
    String? codigo,
    String? nombres,
    String? apellidos,
    String? email,
    String? telefono,
    String? facultad,
    String? programa,
    String? ciclo,
    DateTime? fechaNacimiento,
    String? genero,
    String? direccion,
    bool? activo,
    DateTime? fechaRegistro,
    DateTime? ultimaActualizacion,
    int? totalCitas,
    int? totalAtenciones,
    Map<String, dynamic>? metadata,
  }) {
    return EstudianteModelo(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      facultad: facultad ?? this.facultad,
      programa: programa ?? this.programa,
      ciclo: ciclo ?? this.ciclo,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      genero: genero ?? this.genero,
      direccion: direccion ?? this.direccion,
      activo: activo ?? this.activo,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
      totalCitas: totalCitas ?? this.totalCitas,
      totalAtenciones: totalAtenciones ?? this.totalAtenciones,
      metadata: metadata ?? this.metadata,
    );
  }
}