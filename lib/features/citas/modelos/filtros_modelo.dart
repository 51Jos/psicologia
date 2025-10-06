import 'cita_modelo.dart';

class FiltrosCita {
  final String busqueda;
  final String? facultad;
  final EstadoCita? estado;

  const FiltrosCita({
    this.busqueda = '',
    this.facultad,
    this.estado,
  });

  FiltrosCita copyWith({
    String? busqueda,
    String? facultad,
    EstadoCita? estado,
  }) {
    return FiltrosCita(
      busqueda: busqueda ?? this.busqueda,
      facultad: facultad ?? this.facultad,
      estado: estado ?? this.estado,
    );
  }

  bool get hayFiltros => busqueda.isNotEmpty || facultad != null || estado != null;

  void limpiar() {
    FiltrosCita(busqueda: '', facultad: null, estado: null);
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