import 'cita_modelo.dart';

class FiltrosCita {
  final String busqueda;
  final String? facultad;
  final EstadoCita? estado;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const FiltrosCita({
    this.busqueda = '',
    this.facultad,
    this.estado,
    this.fechaInicio,
    this.fechaFin,
  });

  FiltrosCita copyWith({
    String? busqueda,
    String? facultad,
    EstadoCita? estado,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool limpiarFecha = false,
  }) {
    return FiltrosCita(
      busqueda: busqueda ?? this.busqueda,
      facultad: facultad ?? this.facultad,
      estado: estado ?? this.estado,
      fechaInicio: limpiarFecha ? null : (fechaInicio ?? this.fechaInicio),
      fechaFin: limpiarFecha ? null : (fechaFin ?? this.fechaFin),
    );
  }

  bool get hayFiltros =>
    busqueda.isNotEmpty ||
    facultad != null ||
    estado != null ||
    fechaInicio != null ||
    fechaFin != null;

  void limpiar() {
    FiltrosCita(
      busqueda: '',
      facultad: null,
      estado: null,
      fechaInicio: null,
      fechaFin: null,
    );
  }
}

class EstadisticasCita {
  final int totalRegistros;
  final Map<String, int> porFacultad;
  final Map<EstadoCita, int> porEstado;
  final int primerasAtenciones;
  final int seguimientos;

  const EstadisticasCita({
    required this.totalRegistros,
    required this.porFacultad,
    required this.porEstado,
    required this.primerasAtenciones,
    required this.seguimientos,
  });

  factory EstadisticasCita.vacia() {
    return const EstadisticasCita(
      totalRegistros: 0,
      porFacultad: {},
      porEstado: {},
      primerasAtenciones: 0,
      seguimientos: 0,
    );
  }
}

enum TipoVista {
  tabla,
  tarjetas,
}