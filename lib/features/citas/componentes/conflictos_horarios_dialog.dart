import 'package:flutter/material.dart';
import 'package:psicologia/compartidos/tema/colores_app.dart';
import 'package:psicologia/compartidos/utilidades/formateadores.dart';
import '../modelos/cita_modelo.dart';

class ConflictosHorarioDialog extends StatelessWidget {
  final List<CitaModelo> conflictos;
  final List<DateTime> horariosDisponibles;
  final Function(TimeOfDay) onHoraSeleccionada;

  const ConflictosHorarioDialog({
    Key? key,
    required this.conflictos,
    required this.horariosDisponibles,
    required this.onHoraSeleccionada,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: ColoresApp.advertencia),
          const SizedBox(width: 8),
          const Text('Conflicto de Horario'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'El horario seleccionado tiene conflicto con las siguientes citas:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...conflictos.map((cita) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColoresApp.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: ColoresApp.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${Formateadores.hora(cita.fechaHora)} - ${Formateadores.hora(cita.fechaHoraFin)}: ${cita.nombreCompleto}',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 12),
          if (horariosDisponibles.isNotEmpty) ...[
            const Text(
              'Horarios disponibles sugeridos:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: horariosDisponibles.take(6).map((horario) {
                return ActionChip(
                  label: Text(Formateadores.hora(horario)),
                  onPressed: () {
                    onHoraSeleccionada(TimeOfDay.fromDateTime(horario));
                    Navigator.pop(context);
                  },
                  backgroundColor: ColoresApp.exito.withOpacity(0.1),
                );
              }).toList(),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
      ],
    );
  }
}