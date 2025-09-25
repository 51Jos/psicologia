import 'package:flutter/material.dart';
import '../../../../compartidos/tema/colores_app.dart';
import '../../../../compartidos/utilidades/responsive_helper.dart';

class LoginCabecera extends StatelessWidget {
  const LoginCabecera({super.key});

  @override
  Widget build(BuildContext context) {
    final bool esMobile = ResponsiveHelper.esMobile(context);

    return Column(
      children: [
        Text(
          'Iniciar Sesión',
          style: TextStyle(
            fontSize: ResponsiveHelper.fontSize(
              context,
              base: esMobile ? 20 : 24,
            ),
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoNegro,
          ),
        ),
        
        if (esMobile) ...[
          const SizedBox(height: 8),
          Text(
            'Sistema de Psicología',
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(context, base: 12),
              color: ColoresApp.textoGris,
            ),
          ),
        ],
      ],
    );
  }
}