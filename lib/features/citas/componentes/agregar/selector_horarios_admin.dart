import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../compartidos/tema/colores_app.dart';

/// Selector de horarios disponibles para el módulo de admin/psicólogo
/// Muestra los horarios en formato de tarjetas con rango de tiempo
class SelectorHorariosAdmin extends StatelessWidget {
  final List<DateTime> horariosDisponibles;
  final DateTime? horaSeleccionada;
  final Function(DateTime) onHoraChanged;
  final bool cargandoHorarios;
  final int duracionMinutos;

  const SelectorHorariosAdmin({
    super.key,
    required this.horariosDisponibles,
    required this.horaSeleccionada,
    required this.onHoraChanged,
    this.cargandoHorarios = false,
    this.duracionMinutos = 45,
  });

  @override
  Widget build(BuildContext context) {
    if (cargandoHorarios) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (horariosDisponibles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'No hay horarios disponibles para esta fecha',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1200
            ? 6
            : MediaQuery.of(context).size.width > 600
                ? 5
                : 3,
        childAspectRatio: 2.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: horariosDisponibles.length,
      itemBuilder: (context, index) {
        final horario = horariosDisponibles[index];
        final horarioFin = horario.add(Duration(minutes: duracionMinutos));
        final estaSeleccionado = horaSeleccionada != null &&
            horario.year == horaSeleccionada!.year &&
            horario.month == horaSeleccionada!.month &&
            horario.day == horaSeleccionada!.day &&
            horario.hour == horaSeleccionada!.hour &&
            horario.minute == horaSeleccionada!.minute;

        return InkWell(
          onTap: () => onHoraChanged(horario),
          child: Container(
            decoration: BoxDecoration(
              color: estaSeleccionado
                  ? ColoresApp.primario
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: estaSeleccionado
                    ? ColoresApp.primario
                    : Colors.grey[300]!,
                width: estaSeleccionado ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                '${DateFormat('h:mm a').format(horario)} - ${DateFormat('h:mm a').format(horarioFin)}',
                style: TextStyle(
                  color: estaSeleccionado
                      ? Colors.white
                      : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
