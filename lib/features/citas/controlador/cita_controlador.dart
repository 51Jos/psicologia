import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../modelos/cita_modelo.dart';
import '../modelos/filtros_modelo.dart';
import '../servicios/cita_servicio.dart';

class CitaControlador extends ChangeNotifier {
  final CitaServicio _citaServicio = CitaServicio();

  // Estado del controlador
  List<CitaModelo> _citas = [];
  EstadisticasCita _estadisticas = EstadisticasCita.vacia();
  FiltrosCita _filtros = const FiltrosCita();
  TipoVista _tipoVista = TipoVista.tabla;
  bool _cargando = false;
  String? _error;

  // Getters
  List<CitaModelo> get citas => _citas;
  EstadisticasCita get estadisticas => _estadisticas;
  FiltrosCita get filtros => _filtros;
  TipoVista get tipoVista => _tipoVista;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get hayError => _error != null;

  // Stream de citas
  Stream<List<CitaModelo>>? _citasStream;

  void inicializar() {
    _escucharCitas();
    _cargarEstadisticas();
  }

  void _escucharCitas() {
    _cargando = true;
    notifyListeners();

    _citasStream = _citaServicio.obtenerCitas(filtros: _filtros);
    _citasStream!.listen(
      (citas) {
        _citas = citas;
        _cargando = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Error al cargar citas: $error';
        _cargando = false;
        notifyListeners();
      },
    );
  }

  Future<void> _cargarEstadisticas() async {
    try {
      _estadisticas = await _citaServicio.obtenerEstadisticas();
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar estadísticas: $e');
    }
  }

  // Filtros y búsqueda
  void aplicarBusqueda(String termino) {
    _filtros = _filtros.copyWith(busqueda: termino);
    _escucharCitas();
  }

  void filtrarPorFacultad(String? facultad) {
    _filtros = _filtros.copyWith(facultad: facultad);
    _escucharCitas();
  }

  void filtrarPorEstado(EstadoCita? estado) {
    _filtros = _filtros.copyWith(estado: estado);
    _escucharCitas();
  }

  void limpiarFiltros() {
    _filtros = const FiltrosCita();
    _escucharCitas();
  }

  // Cambiar tipo de vista
  void cambiarTipoVista(TipoVista nuevoTipo) {
    _tipoVista = nuevoTipo;
    notifyListeners();
  }

  // CRUD Operations
  Future<bool> crearCita(CitaModelo cita) async {
    try {
      _cargando = true;
      _error = null;
      notifyListeners();

      // Verificar conflictos de horario
      final conflictos = await _citaServicio.verificarConflictos(
        cita.psicologoId,
        cita.fechaHora,
        cita.duracionEnMinutos,
      );

      if (conflictos.isNotEmpty) {
        _error = 'Conflicto de horario detectado. Ya existe una cita programada en ese horario.';
        _cargando = false;
        notifyListeners();
        return false;
      }

      final id = await _citaServicio.crearCita(cita);

      if (id != null) {
        await _cargarEstadisticas();
        _cargando = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Error al crear la cita';
        _cargando = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarCita(CitaModelo cita) async {
    try {
      _cargando = true;
      _error = null;
      notifyListeners();

      // Verificar conflictos de horario (excluyendo la cita actual)
      final conflictos = await _citaServicio.verificarConflictos(
        cita.psicologoId,
        cita.fechaHora,
        cita.duracionEnMinutos,
        citaIdExcluir: cita.id,
      );

      if (conflictos.isNotEmpty) {
        _error = 'Conflicto de horario detectado. Ya existe una cita programada en ese horario.';
        _cargando = false;
        notifyListeners();
        return false;
      }

      final exito = await _citaServicio.actualizarCita(
        cita.copyWith(fechaActualizacion: DateTime.now()),
      );

      if (exito) {
        await _cargarEstadisticas();
        _cargando = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Error al actualizar la cita';
        _cargando = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarCita(String id) async {
    try {
      _cargando = true;
      _error = null;
      notifyListeners();

      final exito = await _citaServicio.eliminarCita(id);

      if (exito) {
        await _cargarEstadisticas();
        _cargando = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Error al eliminar la cita';
        _cargando = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  // Cambiar estado de cita
  Future<bool> cambiarEstadoCita(String citaId, EstadoCita nuevoEstado) async {
    try {
      final exito = await _citaServicio.cambiarEstado(citaId, nuevoEstado);

      if (exito) {
        await _cargarEstadisticas();
        return true;
      } else {
        _error = 'Error al cambiar el estado de la cita';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    }
  }

  // Programar cita
  Future<bool> programarCita(String citaId) async {
    return cambiarEstadoCita(citaId, EstadoCita.programada);
  }

  // Confirmar cita
  Future<bool> confirmarCita(String citaId) async {
    return cambiarEstadoCita(citaId, EstadoCita.confirmada);
  }

  // Marcar como en curso
  Future<bool> iniciarCita(String citaId) async {
    return cambiarEstadoCita(citaId, EstadoCita.enCurso);
  }

  // Marcar como completada
  Future<bool> completarCita(String citaId) async {
    return cambiarEstadoCita(citaId, EstadoCita.completada);
  }

  // Cancelar cita
  Future<bool> cancelarCita(String citaId) async {
    return cambiarEstadoCita(citaId, EstadoCita.cancelada);
  }

  // Marcar como no asistió
  Future<bool> marcarNoAsistio(String citaId) async {
    return cambiarEstadoCita(citaId, EstadoCita.noAsistio);
  }

  // Obtener cita por ID
  Future<CitaModelo?> obtenerCitaPorId(String id) async {
    try {
      return await _citaServicio.obtenerCitaPorId(id);
    } catch (e) {
      _error = 'Error al obtener la cita: $e';
      notifyListeners();
      return null;
    }
  }

  // Exportar datos (placeholder)
  Future<void> exportarDatos() async {
    // TODO: Implementar exportación de datos
    // Podría ser a CSV, Excel, PDF, etc.
    debugPrint('Exportando datos...');
  }

  // Limpiar error
  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  // Utilidades para la UI
  List<CitaModelo> get citasDeHoy {
    final ahora = DateTime.now();
    return _citas.where((cita) =>
        cita.fechaHora.year == ahora.year &&
        cita.fechaHora.month == ahora.month &&
        cita.fechaHora.day == ahora.day
    ).toList();
  }

  List<CitaModelo> get proximasCitas {
    final ahora = DateTime.now();
    return _citas.where((cita) =>
        cita.fechaHora.isAfter(ahora) &&
        (cita.estado == EstadoCita.programada || cita.estado == EstadoCita.confirmada)
    ).take(5).toList();
  }

  Map<String, List<CitaModelo>> get citasAgrupadasPorFecha {
    final agrupadas = <String, List<CitaModelo>>{};

    for (final cita in _citas) {
      final fecha = '${cita.fechaHora.day}/${cita.fechaHora.month}/${cita.fechaHora.year}';
      if (!agrupadas.containsKey(fecha)) {
        agrupadas[fecha] = [];
      }
      agrupadas[fecha]!.add(cita);
    }

    return agrupadas;
  }

  @override
  void dispose() {
    // Cleanup si es necesario
    super.dispose();
  }
}