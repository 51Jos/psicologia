
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum EstadoCita { programada, confirmada, enCurso, completada, cancelada, noAsistio }
enum TipoCita { presencial, virtual, telefonica }
enum DuracionCita { minutos30, minutos45, minutos60, minutos90 }

class CitaModelo {
  final String id;
  final String estudianteId;
  final String estudianteNombre;
  final String estudianteApellidos;
  final String? estudianteCodigo;
  final String? estudianteEmail;
  final String? estudianteTelefono;
  final String facultad;
  final String programa;
  final DateTime fechaHora;
  final DuracionCita duracion;
  final String psicologoId;
  final String? psicologoNombre;
  final String motivoConsulta;
  final TipoCita tipoCita;
  final EstadoCita estado;
  final String? observaciones;
  final String? enlaceVirtual;
  final String? lugarPresencial;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final DateTime? fechaConfirmacion;
  final DateTime? fechaCancelacion;
  final String? motivoCancelacion;
  final bool recordatorioEnviado;
  final bool primeraVez;
  final Map<String, dynamic>? metadata;

  CitaModelo({
    required this.id,
    required this.estudianteId,
    required this.estudianteNombre,
    required this.estudianteApellidos,
    this.estudianteCodigo,
    this.estudianteEmail,
    this.estudianteTelefono,
    required this.facultad,
    required this.programa,
    required this.fechaHora,
    this.duracion = DuracionCita.minutos45,
    required this.psicologoId,
    this.psicologoNombre,
    required this.motivoConsulta,
    this.tipoCita = TipoCita.presencial,
    this.estado = EstadoCita.programada,
    this.observaciones,
    this.enlaceVirtual,
    this.lugarPresencial,
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.fechaConfirmacion,
    this.fechaCancelacion,
    this.motivoCancelacion,
    this.recordatorioEnviado = false,
    this.primeraVez = true,
    this.metadata,
  });

  // Constructor vacío
  factory CitaModelo.vacio() {
    return CitaModelo(
      id: '',
      estudianteId: '',
      estudianteNombre: '',
      estudianteApellidos: '',
      facultad: '',
      programa: '',
      fechaHora: DateTime.now().add(const Duration(days: 1)),
      psicologoId: '',
      motivoConsulta: '',
      fechaCreacion: DateTime.now(),
    );
  }

  // Desde Firestore
  factory CitaModelo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return CitaModelo(
      id: doc.id,
      estudianteId: data['estudianteId'] ?? '',
      estudianteNombre: data['estudianteNombre'] ?? '',
      estudianteApellidos: data['estudianteApellidos'] ?? '',
      estudianteCodigo: data['estudianteCodigo'],
      estudianteEmail: data['estudianteEmail'],
      estudianteTelefono: data['estudianteTelefono'],
      facultad: data['facultad'] ?? '',
      programa: data['programa'] ?? '',
      fechaHora: (data['fechaHora'] as Timestamp?)?.toDate() ?? DateTime.now(),
      duracion: _stringToDuracion(data['duracion'] ?? 'minutos45'),
      psicologoId: data['psicologoId'] ?? '',
      psicologoNombre: data['psicologoNombre'],
      motivoConsulta: data['motivoConsulta'] ?? '',
      tipoCita: _stringToTipoCita(data['tipoCita'] ?? 'presencial'),
      estado: _stringToEstado(data['estado'] ?? 'programada'),
      observaciones: data['observaciones'],
      enlaceVirtual: data['enlaceVirtual'],
      lugarPresencial: data['lugarPresencial'],
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaActualizacion: (data['fechaActualizacion'] as Timestamp?)?.toDate(),
      fechaConfirmacion: (data['fechaConfirmacion'] as Timestamp?)?.toDate(),
      fechaCancelacion: (data['fechaCancelacion'] as Timestamp?)?.toDate(),
      motivoCancelacion: data['motivoCancelacion'],
      recordatorioEnviado: data['recordatorioEnviado'] ?? false,
      primeraVez: data['primeraVez'] ?? true,
      metadata: data['metadata'],
    );
  }

  // A Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'estudianteId': estudianteId,
      'estudianteNombre': estudianteNombre,
      'estudianteApellidos': estudianteApellidos,
      'estudianteCodigo': estudianteCodigo,
      'estudianteEmail': estudianteEmail,
      'estudianteTelefono': estudianteTelefono,
      'facultad': facultad,
      'programa': programa,
      'fechaHora': Timestamp.fromDate(fechaHora),
      'duracion': _duracionToString(duracion),
      'psicologoId': psicologoId,
      'psicologoNombre': psicologoNombre,
      'motivoConsulta': motivoConsulta,
      'tipoCita': _tipoCitaToString(tipoCita),
      'estado': _estadoToString(estado),
      'observaciones': observaciones,
      'enlaceVirtual': enlaceVirtual,
      'lugarPresencial': lugarPresencial,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaActualizacion': fechaActualizacion != null 
          ? Timestamp.fromDate(fechaActualizacion!) 
          : FieldValue.serverTimestamp(),
      'fechaConfirmacion': fechaConfirmacion != null 
          ? Timestamp.fromDate(fechaConfirmacion!) 
          : null,
      'fechaCancelacion': fechaCancelacion != null 
          ? Timestamp.fromDate(fechaCancelacion!) 
          : null,
      'motivoCancelacion': motivoCancelacion,
      'recordatorioEnviado': recordatorioEnviado,
      'primeraVez': primeraVez,
      'metadata': metadata,
    };
  }

  // Getters útiles
  String get nombreCompleto => '$estudianteNombre $estudianteApellidos'.trim();
  
  DateTime get fechaHoraFin {
    switch (duracion) {
      case DuracionCita.minutos30:
        return fechaHora.add(const Duration(minutes: 30));
      case DuracionCita.minutos45:
        return fechaHora.add(const Duration(minutes: 45));
      case DuracionCita.minutos60:
        return fechaHora.add(const Duration(minutes: 60));
      case DuracionCita.minutos90:
        return fechaHora.add(const Duration(minutes: 90));
    }
  }
  
  int get duracionEnMinutos {
    switch (duracion) {
      case DuracionCita.minutos30:
        return 30;
      case DuracionCita.minutos45:
        return 45;
      case DuracionCita.minutos60:
        return 60;
      case DuracionCita.minutos90:
        return 90;
    }
  }
  
  bool get esFutura => fechaHora.isAfter(DateTime.now());
  bool get esPasada => fechaHora.isBefore(DateTime.now());
  bool get esHoy {
    final ahora = DateTime.now();
    return fechaHora.year == ahora.year && 
           fechaHora.month == ahora.month && 
           fechaHora.day == ahora.day;
  }
  
  bool get puedeEditar => estado == EstadoCita.programada || estado == EstadoCita.confirmada;
  bool get puedeCancelar => esFutura && (estado == EstadoCita.programada || estado == EstadoCita.confirmada);
  bool get puedeConfirmar => estado == EstadoCita.programada && esFutura;

  // Verificar solapamiento con otra cita
  bool seSolapaCon(CitaModelo otraCita) {
    if (id == otraCita.id) return false; // No se solapa consigo misma
    
    // Verificar si las citas son del mismo psicólogo
    if (psicologoId != otraCita.psicologoId) return false;
    
    // Verificar solapamiento de horarios
    return !(fechaHoraFin.isBefore(otraCita.fechaHora) || 
             fechaHora.isAfter(otraCita.fechaHoraFin));
  }

  // CopyWith
  CitaModelo copyWith({
    String? id,
    String? estudianteId,
    String? estudianteNombre,
    String? estudianteApellidos,
    String? estudianteCodigo,
    String? estudianteEmail,
    String? estudianteTelefono,
    String? facultad,
    String? programa,
    DateTime? fechaHora,
    DuracionCita? duracion,
    String? psicologoId,
    String? psicologoNombre,
    String? motivoConsulta,
    TipoCita? tipoCita,
    EstadoCita? estado,
    String? observaciones,
    String? enlaceVirtual,
    String? lugarPresencial,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    DateTime? fechaConfirmacion,
    DateTime? fechaCancelacion,
    String? motivoCancelacion,
    bool? recordatorioEnviado,
    bool? primeraVez,
    Map<String, dynamic>? metadata,
  }) {
    return CitaModelo(
      id: id ?? this.id,
      estudianteId: estudianteId ?? this.estudianteId,
      estudianteNombre: estudianteNombre ?? this.estudianteNombre,
      estudianteApellidos: estudianteApellidos ?? this.estudianteApellidos,
      estudianteCodigo: estudianteCodigo ?? this.estudianteCodigo,
      estudianteEmail: estudianteEmail ?? this.estudianteEmail,
      estudianteTelefono: estudianteTelefono ?? this.estudianteTelefono,
      facultad: facultad ?? this.facultad,
      programa: programa ?? this.programa,
      fechaHora: fechaHora ?? this.fechaHora,
      duracion: duracion ?? this.duracion,
      psicologoId: psicologoId ?? this.psicologoId,
      psicologoNombre: psicologoNombre ?? this.psicologoNombre,
      motivoConsulta: motivoConsulta ?? this.motivoConsulta,
      tipoCita: tipoCita ?? this.tipoCita,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      enlaceVirtual: enlaceVirtual ?? this.enlaceVirtual,
      lugarPresencial: lugarPresencial ?? this.lugarPresencial,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      fechaConfirmacion: fechaConfirmacion ?? this.fechaConfirmacion,
      fechaCancelacion: fechaCancelacion ?? this.fechaCancelacion,
      motivoCancelacion: motivoCancelacion ?? this.motivoCancelacion,
      recordatorioEnviado: recordatorioEnviado ?? this.recordatorioEnviado,
      primeraVez: primeraVez ?? this.primeraVez,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helpers privados
  static EstadoCita _stringToEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'programada':
        return EstadoCita.programada;
      case 'confirmada':
        return EstadoCita.confirmada;
      case 'encurso':
      case 'en_curso':
        return EstadoCita.enCurso;
      case 'completada':
        return EstadoCita.completada;
      case 'cancelada':
        return EstadoCita.cancelada;
      case 'noasistio':
      case 'no_asistio':
        return EstadoCita.noAsistio;
      default:
        return EstadoCita.programada;
    }
  }

  static String _estadoToString(EstadoCita estado) {
    switch (estado) {
      case EstadoCita.programada:
        return 'programada';
      case EstadoCita.confirmada:
        return 'confirmada';
      case EstadoCita.enCurso:
        return 'en_curso';
      case EstadoCita.completada:
        return 'completada';
      case EstadoCita.cancelada:
        return 'cancelada';
      case EstadoCita.noAsistio:
        return 'no_asistio';
    }
  }

  static TipoCita _stringToTipoCita(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'presencial':
        return TipoCita.presencial;
      case 'virtual':
        return TipoCita.virtual;
      case 'telefonica':
        return TipoCita.telefonica;
      default:
        return TipoCita.presencial;
    }
  }

  static String _tipoCitaToString(TipoCita tipo) {
    switch (tipo) {
      case TipoCita.presencial:
        return 'presencial';
      case TipoCita.virtual:
        return 'virtual';
      case TipoCita.telefonica:
        return 'telefonica';
    }
  }

  static DuracionCita _stringToDuracion(String duracion) {
    switch (duracion) {
      case 'minutos30':
        return DuracionCita.minutos30;
      case 'minutos45':
        return DuracionCita.minutos45;
      case 'minutos60':
        return DuracionCita.minutos60;
      case 'minutos90':
        return DuracionCita.minutos90;
      default:
        return DuracionCita.minutos45;
    }
  }

  static String _duracionToString(DuracionCita duracion) {
    switch (duracion) {
      case DuracionCita.minutos30:
        return 'minutos30';
      case DuracionCita.minutos45:
        return 'minutos45';
      case DuracionCita.minutos60:
        return 'minutos60';
      case DuracionCita.minutos90:
        return 'minutos90';
    }
  }
}

// Extensiones para los enums
extension EstadoCitaExtension on EstadoCita {
  String get texto {
    switch (this) {
      case EstadoCita.programada:
        return 'Programada';
      case EstadoCita.confirmada:
        return 'Confirmada';
      case EstadoCita.enCurso:
        return 'En Curso';
      case EstadoCita.completada:
        return 'Completada';
      case EstadoCita.cancelada:
        return 'Cancelada';
      case EstadoCita.noAsistio:
        return 'No Asistió';
    }
  }

  Color get color {
    switch (this) {
      case EstadoCita.programada:
        return const Color(0xFF4299E1); // Azul
      case EstadoCita.confirmada:
        return const Color(0xFF48BB78); // Verde
      case EstadoCita.enCurso:
        return const Color(0xFFF59E0B); // Amarillo
      case EstadoCita.completada:
        return const Color(0xFF10B981); // Verde oscuro
      case EstadoCita.cancelada:
        return const Color(0xFFEF4444); // Rojo
      case EstadoCita.noAsistio:
        return const Color(0xFF6B7280); // Gris
    }
  }

  IconData get icono {
    switch (this) {
      case EstadoCita.programada:
        return Icons.schedule;
      case EstadoCita.confirmada:
        return Icons.check_circle;
      case EstadoCita.enCurso:
        return Icons.play_circle;
      case EstadoCita.completada:
        return Icons.done_all;
      case EstadoCita.cancelada:
        return Icons.cancel;
      case EstadoCita.noAsistio:
        return Icons.person_off;
    }
  }
}

extension TipoCitaExtension on TipoCita {
  String get texto {
    switch (this) {
      case TipoCita.presencial:
        return 'Presencial';
      case TipoCita.virtual:
        return 'Virtual';
      case TipoCita.telefonica:
        return 'Telefónica';
    }
  }

  IconData get icono {
    switch (this) {
      case TipoCita.presencial:
        return Icons.person;
      case TipoCita.virtual:
        return Icons.video_call;
      case TipoCita.telefonica:
        return Icons.phone;
    }
  }
}

extension DuracionCitaExtension on DuracionCita {
  String get texto {
    switch (this) {
      case DuracionCita.minutos30:
        return '30 minutos';
      case DuracionCita.minutos45:
        return '45 minutos';
      case DuracionCita.minutos60:
        return '1 hora';
      case DuracionCita.minutos90:
        return '1 hora 30 min';
    }
  }

  int get minutos {
    switch (this) {
      case DuracionCita.minutos30:
        return 30;
      case DuracionCita.minutos45:
        return 45;
      case DuracionCita.minutos60:
        return 60;
      case DuracionCita.minutos90:
        return 90;
    }
  }
}