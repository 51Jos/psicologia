import 'package:flutter/material.dart';
import 'package:psicologia/compartidos/componentes/campo_fecha.dart';
import 'package:psicologia/compartidos/componentes/campo_hora.dart';
import 'package:psicologia/compartidos/componentes/campo_selector.dart';
import 'package:psicologia/compartidos/componentes/campo_textarea.dart';
import 'package:psicologia/compartidos/componentes/campo_texto.dart';
import 'package:psicologia/compartidos/tema/colores_app.dart';
import 'package:psicologia/compartidos/utilidades/responsive_helper.dart';
import 'package:psicologia/compartidos/utilidades/validadores.dart';
import '../modelos/cita_modelo.dart';

class InfoCitaCard extends StatelessWidget {
  final DateTime fechaSeleccionada;
  final TimeOfDay horaSeleccionada;
  final DuracionCita duracionSeleccionada;
  final TipoCita tipoCitaSeleccionada;
  final List<CitaModelo> citasConflictivas;
  final TextEditingController motivoConsultaController;
  final TextEditingController observacionesController;
  final TextEditingController lugarController;
  final TextEditingController enlaceVirtualController;
  final Function(DateTime?) onFechaChanged;
  final Function(TimeOfDay?) onHoraChanged;
  final Function(DuracionCita?) onDuracionChanged;
  final Function(TipoCita?) onTipoCitaChanged;
  final VoidCallback onVerConflictos;

  const InfoCitaCard({
    Key? key,
    required this.fechaSeleccionada,
    required this.horaSeleccionada,
    required this.duracionSeleccionada,
    required this.tipoCitaSeleccionada,
    required this.citasConflictivas,
    required this.motivoConsultaController,
    required this.observacionesController,
    required this.lugarController,
    required this.enlaceVirtualController,
    required this.onFechaChanged,
    required this.onHoraChanged,
    required this.onDuracionChanged,
    required this.onTipoCitaChanged,
    required this.onVerConflictos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool esMobile = ResponsiveHelper.esMobile(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          ResponsiveHelper.valor(context, mobile: 16, tablet: 20, desktop: 24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: ColoresApp.primario, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Información de la Cita',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(context, base: 18),
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.primario,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (esMobile)
              ..._buildCamposCitaMobile(context)
            else
              ..._buildCamposCitaDesktop(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCamposCitaMobile(BuildContext context) {
    return [
      Row(
        children: [
          Expanded(
            child: CampoFecha(
              etiqueta: 'Fecha',
              valorInicial: fechaSeleccionada,
              fechaMinima: DateTime.now(),
              fechaMaxima: DateTime.now().add(const Duration(days: 90)),
              onChanged: onFechaChanged,
              requerido: true,
              validador: Validadores.fechaFutura,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CampoHora(
              etiqueta: 'Hora',
              valorInicial: horaSeleccionada,
              onChanged: onHoraChanged,
              requerido: true,
              validador: (hora) => hora == null ? 'La hora es requerida' : null,
            ),
          ),
        ],
      ),
      if (citasConflictivas.isNotEmpty)
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ColoresApp.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ColoresApp.error.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: ColoresApp.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Conflicto de horario detectado',
                  style: TextStyle(
                    color: ColoresApp.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: CampoSelector<DuracionCita>(
              etiqueta: 'Duración',
              valorInicial: duracionSeleccionada,
              opciones: _obtenerOpcionesDuracion(),
              onChanged: onDuracionChanged,
              requerido: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CampoSelector<TipoCita>(
              etiqueta: 'Tipo de Cita',
              valorInicial: tipoCitaSeleccionada,
              opciones: _obtenerOpcionesTipoCita(),
              onChanged: onTipoCitaChanged,
              requerido: true,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      if (tipoCitaSeleccionada == TipoCita.presencial)
        CampoTexto(
          etiqueta: 'Lugar',
          placeholder: 'Consultorio, aula, etc.',
          controlador: lugarController,
          iconoPrefijo: Icons.location_on,
          validador: (valor) => Validadores.requerido(valor, campo: 'El lugar'),
        )
      else if (tipoCitaSeleccionada == TipoCita.virtual)
        CampoTexto(
          etiqueta: 'Enlace de reunión',
          placeholder: 'https://meet.google.com/...',
          controlador: enlaceVirtualController,
          iconoPrefijo: Icons.link,
          tipoTeclado: TextInputType.url,
        ),
      const SizedBox(height: 16),
      CampoTextarea(
        etiqueta: 'Motivo de Consulta',
        placeholder: 'Describa brevemente el motivo de la consulta...',
        controlador: motivoConsultaController,
        lineasMin: 3,
        lineasMax: 5,
        longitudMax: 500,
        requerido: true,
        validador: Validadores.motivoConsulta,
      ),
      const SizedBox(height: 16),
      CampoTextarea(
        etiqueta: 'Observaciones',
        placeholder: 'Observaciones adicionales (opcional)',
        controlador: observacionesController,
        lineasMin: 2,
        lineasMax: 4,
        longitudMax: 300,
      ),
    ];
  }

  List<Widget> _buildCamposCitaDesktop(BuildContext context) {
    return [
      Row(
        children: [
          Expanded(
            child: CampoFecha(
              etiqueta: 'Fecha',
              valorInicial: fechaSeleccionada,
              fechaMinima: DateTime.now(),
              fechaMaxima: DateTime.now().add(const Duration(days: 90)),
              onChanged: onFechaChanged,
              requerido: true,
              validador: Validadores.fechaFutura,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CampoHora(
              etiqueta: 'Hora',
              valorInicial: horaSeleccionada,
              onChanged: onHoraChanged,
              requerido: true,
              validador: (hora) => hora == null ? 'La hora es requerida' : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CampoSelector<DuracionCita>(
              etiqueta: 'Duración',
              valorInicial: duracionSeleccionada,
              opciones: _obtenerOpcionesDuracion(),
              onChanged: onDuracionChanged,
              requerido: true,
            ),
          ),
        ],
      ),
      if (citasConflictivas.isNotEmpty)
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ColoresApp.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ColoresApp.error.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: ColoresApp.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Conflicto de horario detectado. ${citasConflictivas.length} cita(s) programada(s) en este horario.',
                  style: TextStyle(
                    color: ColoresApp.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: onVerConflictos,
                child: const Text('Ver detalles'),
              ),
            ],
          ),
        ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: CampoSelector<TipoCita>(
              etiqueta: 'Tipo de Cita',
              valorInicial: tipoCitaSeleccionada,
              opciones: _obtenerOpcionesTipoCita(),
              onChanged: onTipoCitaChanged,
              requerido: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: tipoCitaSeleccionada == TipoCita.presencial
                ? CampoTexto(
                    etiqueta: 'Lugar',
                    placeholder: 'Consultorio, aula, etc.',
                    controlador: lugarController,
                    iconoPrefijo: Icons.location_on,
                    validador: (valor) => Validadores.requerido(valor, campo: 'El lugar'),
                  )
                : tipoCitaSeleccionada == TipoCita.virtual
                    ? CampoTexto(
                        etiqueta: 'Enlace de reunión',
                        placeholder: 'https://meet.google.com/...',
                        controlador: enlaceVirtualController,
                        iconoPrefijo: Icons.link,
                        tipoTeclado: TextInputType.url,
                      )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
      const SizedBox(height: 16),
      CampoTextarea(
        etiqueta: 'Motivo de Consulta',
        placeholder: 'Describa brevemente el motivo de la consulta...',
        controlador: motivoConsultaController,
        lineasMin: 3,
        lineasMax: 5,
        longitudMax: 500,
        requerido: true,
        validador: Validadores.motivoConsulta,
      ),
      const SizedBox(height: 16),
      CampoTextarea(
        etiqueta: 'Observaciones',
        placeholder: 'Observaciones adicionales (opcional)',
        controlador: observacionesController,
        lineasMin: 2,
        lineasMax: 4,
        longitudMax: 300,
      ),
    ];
  }

  List<OpcionSelector<DuracionCita>> _obtenerOpcionesDuracion() {
    return DuracionCita.values.map((duracion) {
      return OpcionSelector(
        valor: duracion,
        etiqueta: duracion.texto,
        icono: Icons.timer,
      );
    }).toList();
  }

  List<OpcionSelector<TipoCita>> _obtenerOpcionesTipoCita() {
    return TipoCita.values.map((tipo) {
      return OpcionSelector(
        valor: tipo,
        etiqueta: tipo.texto,
        icono: tipo.icono,
      );
    }).toList();
  }
}