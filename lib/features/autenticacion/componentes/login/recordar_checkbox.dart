import 'package:flutter/material.dart';
import '../../../../compartidos/tema/colores_app.dart';
import '../../../../compartidos/utilidades/responsive_helper.dart';

class RecordarCheckbox extends StatelessWidget {
  final bool valor;
  final Function(bool?) onChanged;
  final VoidCallback? onOlvidaste;

  const RecordarCheckbox({
    Key? key,
    required this.valor,
    required this.onChanged,
    this.onOlvidaste,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool esMobile = ResponsiveHelper.esMobile(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Checkbox Recordarme
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: valor,
                  onChanged: onChanged,
                  activeColor: ColoresApp.primario,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Recórdarme',
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(context, base: 14),
                  color: ColoresApp.textoGris,
                ),
              ),
            ],
          ),
        ),
        
        // Link Olvidaste tu contraseña
        TextButton(
          onPressed: onOlvidaste,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: esMobile ? 4 : 8,
            ),
          ),
          child: Text(
            '¿Olvidaste tu contraseña?',
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(context, base: 14),
              color: ColoresApp.primario,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}