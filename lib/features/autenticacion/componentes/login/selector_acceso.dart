import 'package:flutter/material.dart';
import '../../../../compartidos/tema/colores_app.dart';
import '../../../../compartidos/utilidades/responsive_helper.dart';
import '../../modelos/credenciales_modelo.dart';

class SelectorAcceso extends StatelessWidget {
  final TipoAcceso tipoSeleccionado;
  final Function(TipoAcceso) onChanged;

  const SelectorAcceso({
    Key? key,
    required this.tipoSeleccionado,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acceso Rápido',
          style: TextStyle(
            fontSize: ResponsiveHelper.fontSize(context, base: 12),
            color: ColoresApp.textoGrisClaro,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: ColoresApp.fondoSecundario,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _buildTab(
                context,
                titulo: 'Administrador',
                icono: Icons.admin_panel_settings,
                tipo: TipoAcceso.administrador,
                seleccionado: tipoSeleccionado == TipoAcceso.administrador,
              ),
              const SizedBox(width: 4),
              _buildTab(
                context,
                titulo: 'Psicólogo',
                icono: Icons.psychology,
                tipo: TipoAcceso.psicologo,
                seleccionado: tipoSeleccionado == TipoAcceso.psicologo,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required String titulo,
    required IconData icono,
    required TipoAcceso tipo,
    required bool seleccionado,
  }) {
    final bool esMobile = ResponsiveHelper.esMobile(context);
    
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(tipo),
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.valor(context, mobile: 12, desktop: 16),
            vertical: ResponsiveHelper.valor(context, mobile: 10, desktop: 12),
          ),
          decoration: BoxDecoration(
            color: seleccionado ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: seleccionado
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icono,
                size: ResponsiveHelper.valor(context, mobile: 18, desktop: 20),
                color: seleccionado ? ColoresApp.primario : ColoresApp.textoGris,
              ),
              if (!esMobile) ...[
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(context, base: 14),
                    fontWeight: seleccionado ? FontWeight.w600 : FontWeight.w400,
                    color: seleccionado ? ColoresApp.textoNegro : ColoresApp.textoGris,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}