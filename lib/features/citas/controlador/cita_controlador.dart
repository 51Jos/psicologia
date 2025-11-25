import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as web;
import '../modelos/cita_modelo.dart';
import '../modelos/filtros_modelo.dart';
import '../servicios/cita_servicio.dart';

class CitaControlador extends ChangeNotifier {
  final CitaServicio _citaServicio = CitaServicio();

  // Estado del controlador
  List<CitaModelo> _citas = [];
  EstadisticasCita _estadisticas = EstadisticasCita.vacia();
  FiltrosCita _filtros = FiltrosCita(
    fechaInicio: DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0),
    fechaFin: DateTime.now().copyWith(hour: 23, minute: 59, second: 59, millisecond: 999),
  ); // Filtrar por defecto para mostrar solo citas del día actual
  TipoVista _tipoVista = TipoVista.tabla;
  bool _cargando = false;
  String? _error;
  bool _inicializado = false;

  // Getters
  List<CitaModelo> get citas => _citas;
  EstadisticasCita get estadisticas => _estadisticas;
  FiltrosCita get filtros => _filtros;
  TipoVista get tipoVista => _tipoVista;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get hayError => _error != null;
  bool get inicializado => _inicializado;

  // Stream de citas
  Stream<List<CitaModelo>>? _citasStream;

  void inicializar() {
    if (_inicializado) return; // Evitar inicializar múltiples veces
    _inicializado = true;

    // Usar Future.microtask para evitar llamar a notifyListeners durante build
    Future.microtask(() {
      _escucharCitas();
      _cargarEstadisticas();
    });
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

  void filtrarPorFecha(DateTime? fechaInicio, DateTime? fechaFin) {
    _filtros = _filtros.copyWith(
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      limpiarFecha: fechaInicio == null && fechaFin == null,
    );
    _escucharCitas();
  }

  void filtrarPorHoy() {
    final hoy = DateTime.now();
    _filtros = _filtros.copyWith(
      fechaInicio: hoy.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0),
      fechaFin: hoy.copyWith(hour: 23, minute: 59, second: 59, millisecond: 999),
    );
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

  // Exportar datos a Excel
  Future<bool> exportarDatos() async {
    try {
      debugPrint('📊 Iniciando exportación de datos...');

      // Crear nuevo archivo Excel
      final excel = Excel.createExcel();
      final sheet = excel['Registro de Citas'];

      // Eliminar la hoja por defecto
      excel.delete('Sheet1');

      // Definir estilos
      final headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.blue,
        fontColorHex: ExcelColor.white,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      final dataCellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
      );

      // Agregar encabezados
      final headers = [
        'Código',
        'Estudiante',
        'Apellidos',
        'Facultad',
        'Programa',
        'Fecha',
        'Hora',
        'Duración',
        'Tipo',
        'Estado',
        'Motivo',
        'Primera Vez',
      ];

      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      // Agregar datos de las citas filtradas
      int rowIndex = 1;
      final dateFormat = DateFormat('dd/MM/yyyy');
      final timeFormat = DateFormat('HH:mm');

      for (final cita in _citas) {
        final row = [
          cita.estudianteCodigo ?? 'N/A',
          cita.estudianteNombre,
          cita.estudianteApellidos,
          _obtenerNombreFacultad(cita.facultad),
          cita.programa,
          dateFormat.format(cita.fechaHora),
          timeFormat.format(cita.fechaHora),
          '${cita.duracionEnMinutos} min',
          _obtenerNombreTipo(cita.tipoCita),
          _obtenerNombreEstado(cita.estado),
          cita.motivoConsulta,
          cita.primeraVez ? 'Sí' : 'No',
        ];

        for (int i = 0; i < row.length; i++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
          cell.value = TextCellValue(row[i]);
          cell.cellStyle = dataCellStyle;
        }

        rowIndex++;
      }

      // Ajustar ancho de columnas
      sheet.setColumnWidth(0, 15); // Código
      sheet.setColumnWidth(1, 20); // Estudiante
      sheet.setColumnWidth(2, 25); // Apellidos
      sheet.setColumnWidth(3, 30); // Facultad
      sheet.setColumnWidth(4, 35); // Programa
      sheet.setColumnWidth(5, 12); // Fecha
      sheet.setColumnWidth(6, 10); // Hora
      sheet.setColumnWidth(7, 12); // Duración
      sheet.setColumnWidth(8, 15); // Tipo
      sheet.setColumnWidth(9, 15); // Estado
      sheet.setColumnWidth(10, 50); // Motivo
      sheet.setColumnWidth(11, 12); // Primera Vez

      // Guardar archivo
      final bytes = excel.encode();
      if (bytes == null) {
        debugPrint('❌ Error al generar el archivo Excel');
        return false;
      }

      // Generar nombre de archivo con fecha
      final now = DateTime.now();
      final fileName = 'Registro_Citas_${DateFormat('yyyyMMdd_HHmmss').format(now)}.xlsx';

      if (kIsWeb) {
        // Para web: descargar directamente
        final blob = web.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = web.Url.createObjectUrlFromBlob(blob);
        final anchor = web.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        web.Url.revokeObjectUrl(url);

        debugPrint('✅ Archivo Excel generado para web: $fileName');
      } else {
        // Para móvil/desktop: guardar en descargas
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        debugPrint('✅ Archivo Excel guardado en: $filePath');
      }

      debugPrint('📊 Exportación completada: ${_citas.length} registros exportados');
      return true;
    } catch (e) {
      debugPrint('❌ Error al exportar datos: $e');
      return false;
    }
  }

  // Helper para obtener nombre de facultad
  String _obtenerNombreFacultad(String codigo) {
    switch (codigo) {
      case 'FC':
        return 'Facultad de Ciencias';
      case 'FI':
        return 'Facultad de Ingeniería';
      case 'FCS':
        return 'Facultad de Ciencias de la Salud';
      case 'FCE':
        return 'Facultad de Ciencias Económicas';
      case 'FD':
        return 'Facultad de Derecho';
      default:
        return codigo;
    }
  }

  // Helper para obtener nombre de tipo de cita
  String _obtenerNombreTipo(TipoCita tipo) {
    switch (tipo) {
      case TipoCita.presencial:
        return 'Presencial';
      case TipoCita.virtual:
        return 'Virtual';
      case TipoCita.telefonica:
        return 'Telefónica';
    }
  }

  // Helper para obtener nombre de estado
  String _obtenerNombreEstado(EstadoCita estado) {
    switch (estado) {
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