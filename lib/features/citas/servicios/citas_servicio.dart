// lib/features/citas/servicios/citas_servicio.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:psicologia/features/citas/modelos/estudiante_modelo.dart';
import '../../../nucleo/configuracion_firebase.dart';
import '../modelos/cita_modelo.dart';

class CitasServicio {

  // Verificar disponibilidad de horario
  Future<bool> verificarDisponibilidad({
    required DateTime fechaHora,
    required DuracionCita duracion,
    required String psicologoId,
    String? citaIdExcluir,
  }) async {
    try {
      final fechaInicio = fechaHora;
      final fechaFin = fechaHora.add(Duration(minutes: duracion.minutos));
      
      // Buscar citas del psicólogo en ese día
      final inicioDia = DateTime(fechaHora.year, fechaHora.month, fechaHora.day);
      final finDia = inicioDia.add(const Duration(days: 1));
      
      Query<Map<String, dynamic>> query = ConfiguracionFirebase.citas
          .where('psicologoId', isEqualTo: psicologoId)
          .where('fechaHora', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia))
          .where('fechaHora', isLessThan: Timestamp.fromDate(finDia))
          .where('estado', whereIn: ['programada', 'confirmada']);
      
      final snapshot = await query.get();
      
      for (var doc in snapshot.docs) {
        if (citaIdExcluir != null && doc.id == citaIdExcluir) {
          continue; // Excluir la cita actual si estamos editando
        }
        
        final cita = CitaModelo.fromFirestore(doc);
        
        // Verificar solapamiento
        if (!(fechaFin.isBefore(cita.fechaHora) || 
              fechaInicio.isAfter(cita.fechaHoraFin))) {
          return false; // Hay solapamiento
        }
      }
      
      return true; // No hay solapamiento
    } catch (e) {
      print('Error verificando disponibilidad: $e');
      return false;
    }
  }

  // Obtener citas conflictivas
  Future<List<CitaModelo>> obtenerCitasConflictivas({
    required DateTime fechaHora,
    required DuracionCita duracion,
    required String psicologoId,
    String? citaIdExcluir,
  }) async {
    try {
      final fechaInicio = fechaHora;
      final fechaFin = fechaHora.add(Duration(minutes: duracion.minutos));
      final citasConflictivas = <CitaModelo>[];
      
      // Buscar citas del psicólogo en ese día
      final inicioDia = DateTime(fechaHora.year, fechaHora.month, fechaHora.day);
      final finDia = inicioDia.add(const Duration(days: 1));
      
      final snapshot = await ConfiguracionFirebase.citas
          .where('psicologoId', isEqualTo: psicologoId)
          .where('fechaHora', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia))
          .where('fechaHora', isLessThan: Timestamp.fromDate(finDia))
          .where('estado', whereIn: ['programada', 'confirmada'])
          .get();
      
      for (var doc in snapshot.docs) {
        if (citaIdExcluir != null && doc.id == citaIdExcluir) {
          continue;
        }
        
        final cita = CitaModelo.fromFirestore(doc);
        
        // Verificar solapamiento
        if (!(fechaFin.isBefore(cita.fechaHora) || 
              fechaInicio.isAfter(cita.fechaHoraFin))) {
          citasConflictivas.add(cita);
        }
      }
      
      return citasConflictivas;
    } catch (e) {
      print('Error obteniendo citas conflictivas: $e');
      return [];
    }
  }

  // Buscar estudiantes (para autocompletado)
  Future<List<EstudianteModelo>> buscarEstudiantes(String busqueda) async {
    try {
      if (busqueda.isEmpty) return [];
      
      final busquedaLower = busqueda.toLowerCase();
      
      // Buscar por código primero (más específico)
      if (RegExp(r'^\d+').hasMatch(busqueda)) {
        final snapshot = await ConfiguracionFirebase.estudiantes
            .where('codigo', isGreaterThanOrEqualTo: busqueda)
            .where('codigo', isLessThanOrEqualTo: busqueda + '\uf8ff')
            .limit(10)
            .get();
        
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) => EstudianteModelo.fromFirestore(doc)).toList();
        }
      }
      
      // Buscar por nombre o apellido
      final snapshot = await ConfiguracionFirebase.estudiantes
          .orderBy('apellidos')
          .limit(100) // Traer más para filtrar localmente
          .get();
      
      final estudiantes = snapshot.docs
          .map((doc) => EstudianteModelo.fromFirestore(doc))
          .where((estudiante) => 
              estudiante.textoBusqueda.contains(busquedaLower))
          .take(10)
          .toList();
      
      return estudiantes;
    } catch (e) {
      print('Error buscando estudiantes: $e');
      return [];
    }
  }

  // Crear o actualizar estudiante si no existe
  Future<EstudianteModelo> crearOActualizarEstudiante(EstudianteModelo estudiante) async {
    try {
      // Buscar si existe por código
      final existente = await ConfiguracionFirebase.estudiantes
          .where('codigo', isEqualTo: estudiante.codigo)
          .limit(1)
          .get();
      
      if (existente.docs.isNotEmpty) {
        // Actualizar estudiante existente
        final doc = existente.docs.first;
        await doc.reference.update(estudiante.toFirestore());
        return estudiante.copyWith(id: doc.id);
      } else {
        // Crear nuevo estudiante
        final docRef = await ConfiguracionFirebase.estudiantes.add(
          estudiante.toFirestore(),
        );
        return estudiante.copyWith(id: docRef.id);
      }
    } catch (e) {
      print('Error creando/actualizando estudiante: $e');
      throw Exception('Error al guardar estudiante');
    }
  }

  // Crear nueva cita
  Future<String> crearCita(CitaModelo cita) async {
    try {
      // Verificar disponibilidad
      final disponible = await verificarDisponibilidad(
        fechaHora: cita.fechaHora,
        duracion: cita.duracion,
        psicologoId: cita.psicologoId,
      );
      
      if (!disponible) {
        throw Exception('El horario seleccionado no está disponible');
      }
      
      // Crear o actualizar estudiante
      final estudiante = EstudianteModelo(
        id: cita.estudianteId,
        codigo: cita.estudianteCodigo ?? '',
        nombres: cita.estudianteNombre,
        apellidos: cita.estudianteApellidos,
        email: cita.estudianteEmail ?? '',
        telefono: cita.estudianteTelefono,
        facultad: cita.facultad,
        programa: cita.programa,
        fechaRegistro: DateTime.now(),
      );
      
      final estudianteActualizado = await crearOActualizarEstudiante(estudiante);
      
      // Crear la cita con el ID del estudiante actualizado
      final citaActualizada = cita.copyWith(
        estudianteId: estudianteActualizado.id,
      );
      
      final docRef = await ConfiguracionFirebase.citas.add(
        citaActualizada.toFirestore(),
      );
      
      // Incrementar contador de citas del estudiante
      await ConfiguracionFirebase.estudiantes
          .doc(estudianteActualizado.id)
          .update({
        'totalCitas': FieldValue.increment(1),
      });
      
      return docRef.id;
    } catch (e) {
      print('Error creando cita: $e');
      throw Exception(e.toString());
    }
  }

  // Actualizar cita
  Future<void> actualizarCita(String id, CitaModelo cita) async {
    try {
      // Verificar disponibilidad (excluyendo la cita actual)
      final disponible = await verificarDisponibilidad(
        fechaHora: cita.fechaHora,
        duracion: cita.duracion,
        psicologoId: cita.psicologoId,
        citaIdExcluir: id,
      );
      
      if (!disponible) {
        throw Exception('El horario seleccionado no está disponible');
      }
      
      // Actualizar estudiante si es necesario
      if (cita.estudianteId.isNotEmpty) {
        final estudiante = EstudianteModelo(
          id: cita.estudianteId,
          codigo: cita.estudianteCodigo ?? '',
          nombres: cita.estudianteNombre,
          apellidos: cita.estudianteApellidos,
          email: cita.estudianteEmail ?? '',
          telefono: cita.estudianteTelefono,
          facultad: cita.facultad,
          programa: cita.programa,
          fechaRegistro: DateTime.now(),
        );
        
        await crearOActualizarEstudiante(estudiante);
      }
      
      await ConfiguracionFirebase.citas.doc(id).update(
        cita.toFirestore(),
      );
    } catch (e) {
      print('Error actualizando cita: $e');
      throw Exception(e.toString());
    }
  }

  // Obtener cita por ID
  Future<CitaModelo?> obtenerCitaPorId(String id) async {
    try {
      final doc = await ConfiguracionFirebase.citas.doc(id).get();
      
      if (doc.exists) {
        return CitaModelo.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error obteniendo cita: $e');
      return null;
    }
  }

  // Obtener horarios disponibles para un día
  Future<List<DateTime>> obtenerHorariosDisponibles({
    required DateTime fecha,
    required String psicologoId,
    required DuracionCita duracion,
    String? citaIdExcluir,
  }) async {
    try {
      final horariosDisponibles = <DateTime>[];
      
      // Configuración de horario de trabajo (8:00 AM - 6:00 PM)
      final horaInicio = 8;
      final horaFin = 18;
      final intervalo = 15; // Intervalos de 15 minutos
      
      // Obtener todas las citas del día
      final inicioDia = DateTime(fecha.year, fecha.month, fecha.day);
      final finDia = inicioDia.add(const Duration(days: 1));
      
      final snapshot = await ConfiguracionFirebase.citas
          .where('psicologoId', isEqualTo: psicologoId)
          .where('fechaHora', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia))
          .where('fechaHora', isLessThan: Timestamp.fromDate(finDia))
          .where('estado', whereIn: ['programada', 'confirmada'])
          .get();
      
      final citasDelDia = snapshot.docs
          .where((doc) => citaIdExcluir == null || doc.id != citaIdExcluir)
          .map((doc) => CitaModelo.fromFirestore(doc))
          .toList();
      
      // Generar todos los horarios posibles
      for (int hora = horaInicio; hora < horaFin; hora++) {
        for (int minuto = 0; minuto < 60; minuto += intervalo) {
          final horarioPosible = DateTime(
            fecha.year,
            fecha.month,
            fecha.day,
            hora,
            minuto,
          );
          
          // Verificar que el horario + duración no exceda el horario de trabajo
          final horarioFin = horarioPosible.add(Duration(minutes: duracion.minutos));
          if (horarioFin.hour > horaFin || 
              (horarioFin.hour == horaFin && horarioFin.minute > 0)) {
            continue;
          }
          
          // Verificar que no haya conflicto con otras citas
          bool disponible = true;
          for (var cita in citasDelDia) {
            if (!(horarioFin.isBefore(cita.fechaHora) || 
                  horarioPosible.isAfter(cita.fechaHoraFin))) {
              disponible = false;
              break;
            }
          }
          
          if (disponible) {
            horariosDisponibles.add(horarioPosible);
          }
        }
      }
      
      return horariosDisponibles;
    } catch (e) {
      print('Error obteniendo horarios disponibles: $e');
      return [];
    }
  }

  // Cambiar estado de cita
  Future<void> cambiarEstadoCita(String id, EstadoCita nuevoEstado) async {
    try {
      final updates = <String, dynamic>{
        'estado': nuevoEstado.name,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      };
      
      if (nuevoEstado == EstadoCita.confirmada) {
        updates['fechaConfirmacion'] = FieldValue.serverTimestamp();
      } else if (nuevoEstado == EstadoCita.cancelada) {
        updates['fechaCancelacion'] = FieldValue.serverTimestamp();
      }
      
      await ConfiguracionFirebase.citas.doc(id).update(updates);
    } catch (e) {
      print('Error cambiando estado de cita: $e');
      throw Exception('Error al cambiar estado de la cita');
    }
  }

  Future<void> eliminarCita(String citaId) async {
  try {
    await ConfiguracionFirebase.citas.doc(citaId).delete();
  } catch (e) {
    print('Error eliminando cita: $e');
    throw Exception('Error al eliminar la cita: $e');
  }
}

  // Cancelar cita
  Future<void> cancelarCita(String id, String motivo) async {
    try {
      await ConfiguracionFirebase.citas.doc(id).update({
        'estado': 'cancelada',
        'motivoCancelacion': motivo,
        'fechaCancelacion': FieldValue.serverTimestamp(),
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error cancelando cita: $e');
      throw Exception('Error al cancelar la cita');
    }
  }
}