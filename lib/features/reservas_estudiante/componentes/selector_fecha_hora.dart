import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../../citas/modelos/cita_modelo.dart';

class SelectorFechaHora extends StatelessWidget {
  final DateTime? fechaSeleccionada;
  final DateTime? horaSeleccionada;
  final DuracionCita duracionSeleccionada;
  final List<DateTime> horariosDisponibles;
  final Function(DateTime?) onFechaChanged;
  final Function(DateTime?) onHoraChanged;
  final Function(DuracionCita?)? onDuracionChanged; // Ahora es opcional
  final bool cargandoHorarios;

  const SelectorFechaHora({
    super.key,
    required this.fechaSeleccionada,
    required this.horaSeleccionada,
    required this.duracionSeleccionada,
    required this.horariosDisponibles,
    required this.onFechaChanged,
    required this.onHoraChanged,
    this.onDuracionChanged, // Ya no es required
    this.cargandoHorarios = false,
  });

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('es', 'ES'),
      selectableDayPredicate: (DateTime date) {
        // Deshabilitar domingos
        return date.weekday != DateTime.sunday;
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColoresApp.primario,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onFechaChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: ColoresApp.primario),
                const SizedBox(width: 8),
                Text(
                  'Seleccionar Fecha y Hora',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Selector de Fecha
            InkWell(
              onTap: () => _seleccionarFecha(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fechaSeleccionada != null
                          ? DateFormat('EEEE, d MMMM yyyy', 'es_ES')
                              .format(fechaSeleccionada!)
                          : 'Seleccionar fecha',
                      style: TextStyle(
                        color: fechaSeleccionada != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Duración - Editable solo si onDuracionChanged no es null
            if (onDuracionChanged != null)
              DropdownButtonFormField<DuracionCita>(
                value: duracionSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Duración',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                items: DuracionCita.values.map((duracion) {
                  return DropdownMenuItem<DuracionCita>(
                    value: duracion,
                    child: Text(duracion.texto),
                  );
                }).toList(),
                onChanged: onDuracionChanged,
              )
            else
              // Mostrar duración fija (no editable)
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Duración',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      duracionSeleccionada.texto,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ColoresApp.primario.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Tiempo estándar',
                        style: TextStyle(
                          fontSize: 12,
                          color: ColoresApp.primario,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Selector de Hora
            if (fechaSeleccionada != null) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Horarios Disponibles',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              if (cargandoHorarios)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (horariosDisponibles.isEmpty)
                Center(
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
                )
              else
                GridView.builder(
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
                    final horarioFin = horario.add(const Duration(minutes: 30));
                    final estaSeleccionado = horaSeleccionada != null &&
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
                ),
            ],
          ],
        ),
      ),
    );
  }
}
