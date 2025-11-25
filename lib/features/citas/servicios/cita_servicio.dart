import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../modelos/cita_modelo.dart';
import '../modelos/filtros_modelo.dart';

class CitaServicio {
  static const String _collection = 'citas';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _citasRef => _firestore.collection(_collection);

  // Obtener todas las citas con filtros opcionales
  Stream<List<CitaModelo>> obtenerCitas({
    FiltrosCita? filtros,
    int? limite,
  }) {
    Query query = _citasRef;

    // Aplicar filtro de fecha si está presente
    if (filtros?.fechaInicio != null) {
      query = query.where('fechaHora', isGreaterThanOrEqualTo: Timestamp.fromDate(filtros!.fechaInicio!));
    }
    if (filtros?.fechaFin != null) {
      query = query.where('fechaHora', isLessThanOrEqualTo: Timestamp.fromDate(filtros!.fechaFin!));
    }

    // Ordenar por fechaHora si hay filtro de fecha, sino por fechaCreacion
    if (filtros?.fechaInicio != null || filtros?.fechaFin != null) {
      query = query.orderBy('fechaHora', descending: false);
    } else {
      query = query.orderBy('fechaCreacion', descending: true);
    }

    // Aplicar otros filtros
    if (filtros != null) {
      if (filtros.facultad != null && filtros.facultad!.isNotEmpty) {
        query = query.where('facultad', isEqualTo: filtros.facultad);
      }

      if (filtros.estado != null) {
        query = query.where('estado', isEqualTo: _estadoToString(filtros.estado!));
      }
    }

    if (limite != null) {
      query = query.limit(limite);
    }

    return query.snapshots().map((snapshot) {
      var citas = snapshot.docs
          .map((doc) => CitaModelo.fromFirestore(doc))
          .toList();

      // Aplicar filtro de búsqueda en memoria (para nombres, etc.)
      if (filtros?.busqueda != null && filtros!.busqueda.isNotEmpty) {
        final busqueda = filtros.busqueda.toLowerCase();
        citas = citas.where((cita) {
          return cita.nombreCompleto.toLowerCase().contains(busqueda) ||
                 cita.facultad.toLowerCase().contains(busqueda) ||
                 cita.programa.toLowerCase().contains(busqueda) ||
                 cita.motivoConsulta.toLowerCase().contains(busqueda);
        }).toList();
      }

      return citas;
    });
  }

  // Obtener una cita por ID
  Future<CitaModelo?> obtenerCitaPorId(String id) async {
    try {
      final doc = await _citasRef.doc(id).get();
      if (doc.exists) {
        return CitaModelo.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error al obtener cita: $e');
      return null;
    }
  }

  // Crear nueva cita
  Future<String?> crearCita(CitaModelo cita) async {
    try {
      debugPrint('📝 Creando cita en Firestore...');
      final docRef = await _citasRef.add(cita.toFirestore());
      debugPrint('✅ Cita creada con ID: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      debugPrint('❌ Error al crear cita: $e');
      debugPrint('📍 Stack trace: $stackTrace');

      // Relanzar el error en lugar de retornar null para mejor manejo
      rethrow;
    }
  }

  // Actualizar cita existente
  Future<bool> actualizarCita(CitaModelo cita) async {
    try {
      await _citasRef.doc(cita.id).update(cita.toFirestore());
      return true;
    } catch (e) {
      debugPrint('Error al actualizar cita: $e');
      return false;
    }
  }

  // Eliminar cita
  Future<bool> eliminarCita(String id) async {
    try {
      await _citasRef.doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Error al eliminar cita: $e');
      return false;
    }
  }

  // Obtener citas por estudiante
  Stream<List<CitaModelo>> obtenerCitasPorEstudiante(String estudianteId) {
    return _citasRef
        .where('estudianteId', isEqualTo: estudianteId)
        .orderBy('fechaHora', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CitaModelo.fromFirestore(doc))
            .toList());
  }

  // Obtener citas por psicólogo
  Stream<List<CitaModelo>> obtenerCitasPorPsicologo(String psicologoId) {
    return _citasRef
        .where('psicologoId', isEqualTo: psicologoId)
        .orderBy('fechaHora', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CitaModelo.fromFirestore(doc))
            .toList());
  }

  // Obtener citas de hoy
  Stream<List<CitaModelo>> obtenerCitasDeHoy() {
    final ahora = DateTime.now();
    final inicioDelDia = DateTime(ahora.year, ahora.month, ahora.day);
    final finDelDia = inicioDelDia.add(const Duration(days: 1));

    return _citasRef
        .where('fechaHora', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDelDia))
        .where('fechaHora', isLessThan: Timestamp.fromDate(finDelDia))
        .orderBy('fechaHora')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CitaModelo.fromFirestore(doc))
            .toList());
  }

  // Obtener próximas citas
  Stream<List<CitaModelo>> obtenerProximasCitas({int limite = 10}) {
    return _citasRef
        .where('fechaHora', isGreaterThan: Timestamp.now())
        .where('estado', whereIn: ['programada', 'confirmada'])
        .orderBy('fechaHora')
        .limit(limite)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CitaModelo.fromFirestore(doc))
            .toList());
  }

  // Obtener horarios ocupados de un día específico para un psicólogo
  Future<List<Map<String, dynamic>>> obtenerHorariosOcupados(
    String psicologoId,
    DateTime fecha,
  ) async {
    final inicioDelDia = DateTime(fecha.year, fecha.month, fecha.day, 0, 0);
    final finDelDia = DateTime(fecha.year, fecha.month, fecha.day, 23, 59);

    try {
      final query = await _citasRef
          .where('psicologoId', isEqualTo: psicologoId)
          .where('fechaHora', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDelDia))
          .where('fechaHora', isLessThanOrEqualTo: Timestamp.fromDate(finDelDia))
          .get();

      final horariosOcupados = <Map<String, dynamic>>[];

      for (var doc in query.docs) {
        final cita = CitaModelo.fromFirestore(doc);

        // Solo considerar citas activas
        if (cita.estado != EstadoCita.cancelada && cita.estado != EstadoCita.completada) {
          horariosOcupados.add({
            'citaId': cita.id,
            'inicio': cita.fechaHora,
            'fin': cita.fechaHoraFin,
            'estudiante': cita.nombreCompleto,
            'duracion': cita.duracion.texto,
          });
        }
      }

      return horariosOcupados;
    } catch (e) {
      debugPrint('Error al obtener horarios ocupados: $e');
      return [];
    }
  }

  // Verificar conflictos de horario
  Future<List<CitaModelo>> verificarConflictos(
    String psicologoId,
    DateTime fechaHora,
    int duracionMinutos, {
    String? citaIdExcluir,
  }) async {
    final inicio = fechaHora;
    final fin = fechaHora.add(Duration(minutes: duracionMinutos));

    try {
      // Buscar todas las citas del psicólogo en un rango amplio
      final query = await _citasRef
          .where('psicologoId', isEqualTo: psicologoId)
          .where('fechaHora', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio.subtract(const Duration(hours: 3))))
          .where('fechaHora', isLessThanOrEqualTo: Timestamp.fromDate(fin.add(const Duration(hours: 3))))
          .get();

      final citas = query.docs
          .map((doc) => CitaModelo.fromFirestore(doc))
          .where((cita) {
            // Excluir la cita actual si se está editando
            if (citaIdExcluir != null && cita.id == citaIdExcluir) {
              return false;
            }

            // Solo considerar citas activas
            if (cita.estado == EstadoCita.cancelada || cita.estado == EstadoCita.completada) {
              return false;
            }

            // Verificar solapamiento real
            final citaFin = cita.fechaHoraFin;

            // Hay conflicto si:
            // - La nueva cita empieza antes que termine la existente Y termina después que empiece la existente
            final hayConflicto = inicio.isBefore(citaFin) && fin.isAfter(cita.fechaHora);

            return hayConflicto;
          })
          .toList();

      return citas;
    } catch (e) {
      debugPrint('Error al verificar conflictos: $e');
      return [];
    }
  }

  // Obtener estudiantes únicos (para autocompletado)
  Future<List<Map<String, String>>> obtenerEstudiantesUnicos() async {
    try {
      final snapshot = await _citasRef.get();
      final estudiantesSet = <String, Map<String, String>>{};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final nombre = data['estudianteNombre'] as String?;
        final apellidos = data['estudianteApellidos'] as String?;
        final email = data['estudianteEmail'] as String?;
        final codigo = data['estudianteCodigo'] as String?;
        final telefono = data['estudianteTelefono'] as String?;
        final facultad = data['facultad'] as String?;
        final programa = data['programa'] as String?;

        if (nombre != null && apellidos != null) {
          final key = '${nombre}_${apellidos}';
          if (!estudiantesSet.containsKey(key)) {
            estudiantesSet[key] = {
              'nombre': nombre,
              'apellidos': apellidos,
              'nombreCompleto': '$nombre $apellidos',
              'email': email ?? '',
              'codigo': codigo ?? '',
              'telefono': telefono ?? '',
              'facultad': facultad ?? '',
              'programa': programa ?? '',
            };
          }
        }
      }

      return estudiantesSet.values.toList();
    } catch (e) {
      debugPrint('Error al obtener estudiantes únicos: $e');
      return [];
    }
  }

  // Cambiar estado de una cita
  Future<bool> cambiarEstado(String citaId, EstadoCita nuevoEstado) async {
    try {
      final updates = <String, dynamic>{
        'estado': _estadoToString(nuevoEstado),
        'fechaActualizacion': FieldValue.serverTimestamp(),
      };

      // Agregar campos específicos según el estado
      switch (nuevoEstado) {
        case EstadoCita.confirmada:
          updates['fechaConfirmacion'] = FieldValue.serverTimestamp();
          break;
        case EstadoCita.cancelada:
          updates['fechaCancelacion'] = FieldValue.serverTimestamp();
          break;
        default:
          break;
      }

      await _citasRef.doc(citaId).update(updates);
      return true;
    } catch (e) {
      debugPrint('Error al cambiar estado: $e');
      return false;
    }
  }

  // Obtener estadísticas
  Future<EstadisticasCita> obtenerEstadisticas() async {
    try {
      final snapshot = await _citasRef.get();
      final citas = snapshot.docs
          .map((doc) => CitaModelo.fromFirestore(doc))
          .toList();

      final porFacultad = <String, int>{};
      final porEstado = <EstadoCita, int>{};
      int primerasAtenciones = 0;
      int seguimientos = 0;

      for (final cita in citas) {
        // Contar por facultad
        porFacultad[cita.facultad] = (porFacultad[cita.facultad] ?? 0) + 1;

        // Contar por estado
        porEstado[cita.estado] = (porEstado[cita.estado] ?? 0) + 1;

        // Contar primeras atenciones vs seguimientos
        if (cita.primeraVez) {
          primerasAtenciones++;
        } else {
          seguimientos++;
        }
      }

      return EstadisticasCita(
        totalRegistros: citas.length,
        porFacultad: porFacultad,
        porEstado: porEstado,
        primerasAtenciones: primerasAtenciones,
        seguimientos: seguimientos,
      );
    } catch (e) {
      debugPrint('Error al obtener estadísticas: $e');
      return EstadisticasCita.vacia();
    }
  }

  // Marcar recordatorio como enviado
  Future<bool> marcarRecordatorioEnviado(String citaId) async {
    try {
      await _citasRef.doc(citaId).update({
        'recordatorioEnviado': true,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error al marcar recordatorio: $e');
      return false;
    }
  }

  // Obtener citas que necesitan recordatorio
  Stream<List<CitaModelo>> obtenerCitasParaRecordatorio() {
    final manana = DateTime.now().add(const Duration(days: 1));
    final inicioManana = DateTime(manana.year, manana.month, manana.day);
    final finManana = inicioManana.add(const Duration(days: 1));

    return _citasRef
        .where('fechaHora', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioManana))
        .where('fechaHora', isLessThan: Timestamp.fromDate(finManana))
        .where('recordatorioEnviado', isEqualTo: false)
        .where('estado', whereIn: ['programada', 'confirmada'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CitaModelo.fromFirestore(doc))
            .toList());
  }

  // Obtener horarios disponibles de un psicólogo en una fecha
  Future<List<DateTime>> obtenerHorariosDisponibles(
    String psicologoId,
    DateTime fecha,
    int duracionMinutos,
  ) async {
    try {
      final ocupados = await obtenerHorariosOcupados(psicologoId, fecha);

      // Generar horarios disponibles de 8:00 AM a 9:30 PM
      // Recesos: 1:00 PM - 2:00 PM y 6:00 PM - 7:00 PM
      final List<DateTime> horariosDisponibles = [];

      for (int hora = 8; hora < 22; hora++) {
        // Excluir horas de receso
        // Receso 1: 1:00 PM - 2:00 PM (hora 13)
        // Receso 2: 6:00 PM - 7:00 PM (hora 18)
        if (hora == 13 || hora == 18) {
          continue;
        }

        for (int minuto = 0; minuto < 60; minuto += 30) {
          final horario = DateTime(fecha.year, fecha.month, fecha.day, hora, minuto);
          final horarioFin = horario.add(Duration(minutes: duracionMinutos));

          // No permitir horarios después de 9:30 PM (21:30)
          if (hora >= 21 && minuto >= 30) {
            break;
          }

          // Verificar si el horario está ocupado o se solapa con alguna cita
          bool estaOcupado = false;
          for (var ocupado in ocupados) {
            final inicio = ocupado['inicio'] as DateTime;
            final fin = ocupado['fin'] as DateTime;

            // Verificar solapamiento
            bool seSolapa = !(horarioFin.isBefore(inicio) ||
                             horario.isAfter(fin.subtract(const Duration(minutes: 1))));

            if (seSolapa) {
              estaOcupado = true;
              break;
            }
          }

          // Solo agregar si no está ocupado y es futuro
          if (!estaOcupado && horario.isAfter(DateTime.now())) {
            horariosDisponibles.add(horario);
          }
        }
      }

      debugPrint('📅 Horarios disponibles para ${fecha.day}/${fecha.month}: ${horariosDisponibles.length} bloques de $duracionMinutos minutos');
      return horariosDisponibles;
    } catch (e) {
      debugPrint('Error al obtener horarios disponibles: $e');
      return [];
    }
  }

  // Helper privado para convertir estado a string
  String _estadoToString(EstadoCita estado) {
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
}