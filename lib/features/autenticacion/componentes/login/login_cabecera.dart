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
        // Icono solo en móvil
        if (esMobile) ...[
          Container(
            width: 70,
            height: 70,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: ColoresApp.gradienteDorado,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ColoresApp.secundario.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology_rounded,
              size: 35,
              color: Colors.white,
            ),
          ),
        ],

        Text(
          'Iniciar Sesión',
          style: TextStyle(
            fontSize: ResponsiveHelper.fontSize(
              context,
              base: esMobile ? 24 : 28,
            ),
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoNegro,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          esMobile
            ? 'Bienvenido al sistema de atención psicológica'
            : 'Ingresa tus credenciales para continuar',
          style: TextStyle(
            fontSize: ResponsiveHelper.fontSize(
              context,
              base: esMobile ? 13 : 14,
            ),
            color: ColoresApp.textoGris,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}