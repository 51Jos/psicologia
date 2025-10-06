import 'package:flutter/material.dart';
import 'package:psicologia/compartidos/componentes/botones/boton_primario.dart';
import 'package:psicologia/compartidos/componentes/botones/boton_secundario.dart';

class BotonesAccionCita extends StatelessWidget {
  final bool esEdicion;
  final bool guardando;
  final bool verificandoDisponibilidad;
  final VoidCallback onCancelar;
  final VoidCallback onGuardar;

  const BotonesAccionCita({
    super.key,
    required this.esEdicion,
    required this.guardando,
    required this.verificandoDisponibilidad,
    required this.onCancelar,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        BotonSecundario(
          texto: 'Cancelar',
          onPressed: onCancelar,
          habilitado: !guardando,
        ),
        const SizedBox(width: 12),
        BotonPrimario(
          texto: esEdicion ? 'Actualizar Cita' : 'Crear Cita',
          icono: Icons.save,
          onPressed: onGuardar,
          cargando: guardando,
          habilitado: !verificandoDisponibilidad,
        ),
      ],
    );
  }
}