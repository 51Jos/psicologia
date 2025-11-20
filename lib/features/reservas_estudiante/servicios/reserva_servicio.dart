import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../citas/modelos/cita_modelo.dart';
import '../../citas/servicios/cita_servicio.dart';
import '../../autenticacion/modelos/usuario.dart';

class ReservaServicio {
  final CitaServicio _citaServicio = CitaServicio();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener citas del estudiante
  Stream<List<CitaModelo>> obtenerMisCitas(String estudianteId) {
    return _citaServicio.obtenerCitasPorEstudiante(estudianteId);
  }

  // Obtener el primer psicólogo activo (se usa para todas las reservas)
  Future<UsuarioModelo?> obtenerPsicologoGenerico() async {
    try {
      debugPrint('🔍 Buscando psicólogo activo en Firestore...');

      // Buscar cualquier usuario con tipo 'psicologo' y activo
      final snapshot = await _firestore
          .collection('usuarios')
          .where('tipo', isEqualTo: 'psicologo')
          .where('activo', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('❌ No se encontró ningún psicólogo activo en el sistema');
        return null;
      }

      final psicologo = UsuarioModelo.fromFirestore(snapshot.docs.first);

      debugPrint('✅ Psicólogo encontrado: ${psicologo.nombreCompleto} (${psicologo.email})');
      return psicologo;
    } catch (e) {
      debugPrint('❌ Error al obtener psicólogo: $e');
      return null;
    }
  }

  // Obtener psicólogos disponibles (DEPRECATED - mantener para compatibilidad)
  @Deprecated('Ya no se seleccionan psicólogos individualmente. Usar obtenerPsicologoGenerico()')
  Future<List<UsuarioModelo>> obtenerPsicologos() async {
    try {
      debugPrint('🔍 Buscando psicólogos en Firestore...');

      // Primero intentar obtener solo por tipo
      final snapshot = await _firestore
          .collection('usuarios')
          .where('tipo', isEqualTo: 'psicologo')
          .get();

      debugPrint('📊 Total de psicólogos encontrados: ${snapshot.docs.length}');

      final psicologos = snapshot.docs
          .map((doc) {
            debugPrint('📄 Doc ID: ${doc.id}, Datos: ${doc.data()}');
            return UsuarioModelo.fromFirestore(doc);
          })
          .where((usuario) => usuario.activo) // Filtrar activos en memoria
          .toList();

      debugPrint('✅ Psicólogos activos: ${psicologos.length}');

      return psicologos;
    } catch (e) {
      debugPrint('❌ Error al obtener psicólogos: $e');

      // Intentar obtener todos los usuarios para debug
      try {
        final todosSnapshot = await _firestore.collection('usuarios').get();
        debugPrint('📊 Total usuarios en BD: ${todosSnapshot.docs.length}');

        for (var doc in todosSnapshot.docs) {
          debugPrint('Usuario: ${doc.id} - tipo: ${doc.data()['tipo']} - activo: ${doc.data()['activo']}');
        }
      } catch (e2) {
        debugPrint('❌ Error al obtener todos los usuarios: $e2');
      }

      return [];
    }
  }

  // Crear reserva (reutiliza la lógica de citas)
  Future<String?> crearReserva(CitaModelo cita) async {
    try {
      debugPrint('🔄 Iniciando creación de reserva...');
      debugPrint('📋 Datos de la cita: ${cita.toFirestore()}');

      // Verificar conflictos de horario
      debugPrint('🔍 Verificando conflictos de horario...');
      final conflictos = await _citaServicio.verificarConflictos(
        cita.psicologoId,
        cita.fechaHora,
        cita.duracionEnMinutos,
      );

      if (conflictos.isNotEmpty) {
        debugPrint('❌ Se encontraron conflictos de horario');
        throw Exception('Ya existe una cita en ese horario');
      }

      debugPrint('✅ No hay conflictos, procediendo a crear la cita...');
      // Crear la cita
      final citaId = await _citaServicio.crearCita(cita);

      if (citaId != null) {
        debugPrint('✅ Reserva creada exitosamente con ID: $citaId');
      } else {
        debugPrint('❌ Error: crearCita retornó null');
      }

      return citaId;
    } catch (e, stackTrace) {
      debugPrint('❌ Error al crear reserva: $e');
      debugPrint('📍 Stack trace: $stackTrace');

      // Detectar errores específicos de Firestore
      if (e.toString().contains('PERMISSION_DENIED') ||
          e.toString().contains('permission-denied')) {
        throw Exception('Error de permisos: No tienes autorización para crear citas. Por favor, verifica tu sesión.');
      }

      rethrow;
    }
  }

  // Cancelar reserva
  Future<bool> cancelarReserva(String citaId, String motivo) async {
    try {
      final cita = await _citaServicio.obtenerCitaPorId(citaId);

      if (cita == null) {
        throw Exception('Cita no encontrada');
      }

      if (!cita.puedeCancelar) {
        throw Exception('Esta cita no puede ser cancelada');
      }

      final citaActualizada = cita.copyWith(
        estado: EstadoCita.cancelada,
        motivoCancelacion: motivo,
        fechaCancelacion: DateTime.now(),
      );

      return await _citaServicio.actualizarCita(citaActualizada);
    } catch (e) {
      debugPrint('Error al cancelar reserva: $e');
      rethrow;
    }
  }

  // Obtener horarios disponibles de un psicólogo en una fecha
  Future<List<DateTime>> obtenerHorariosDisponibles(
    String psicologoId,
    DateTime fecha,
  ) async {
    try {
      final ocupados = await _citaServicio.obtenerHorariosOcupados(psicologoId, fecha);

      // Generar horarios disponibles de 8:00 AM a 6:00 PM
      final List<DateTime> horariosDisponibles = [];

      for (int hora = 8; hora < 18; hora++) {
        for (int minuto = 0; minuto < 60; minuto += 30) {
          final horario = DateTime(fecha.year, fecha.month, fecha.day, hora, minuto);

          // Verificar si el horario está ocupado
          bool estaOcupado = false;
          for (var ocupado in ocupados) {
            final inicio = ocupado['inicio'] as DateTime;
            final fin = ocupado['fin'] as DateTime;

            if (horario.isAfter(inicio.subtract(const Duration(minutes: 1))) &&
                horario.isBefore(fin)) {
              estaOcupado = true;
              break;
            }
          }

          if (!estaOcupado && horario.isAfter(DateTime.now())) {
            horariosDisponibles.add(horario);
          }
        }
      }

      return horariosDisponibles;
    } catch (e) {
      debugPrint('Error al obtener horarios disponibles: $e');
      return [];
    }
  }

  // Verificar si puede reservar
  Future<bool> puedeReservar(String estudianteId, DateTime fecha) async {
    try {
      final citas = await _citaServicio
          .obtenerCitasPorEstudiante(estudianteId)
          .first;

      // Verificar si ya tiene una cita programada o confirmada en esa fecha
      final citasEnFecha = citas.where((cita) {
        return cita.fechaHora.year == fecha.year &&
               cita.fechaHora.month == fecha.month &&
               cita.fechaHora.day == fecha.day &&
               (cita.estado == EstadoCita.programada ||
                cita.estado == EstadoCita.confirmada);
      }).toList();

      return citasEnFecha.isEmpty;
    } catch (e) {
      debugPrint('Error al verificar si puede reservar: $e');
      return false;
    }
  }
}
