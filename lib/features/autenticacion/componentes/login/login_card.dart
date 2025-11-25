import 'package:flutter/material.dart';
import '../../../../compartidos/utilidades/responsive_helper.dart';
import 'login_lateral.dart';
import 'login_formulario.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    final bool esMobile = ResponsiveHelper.esMobile(context);
    final bool esTablet = ResponsiveHelper.esTablet(context);
    final double anchoPantalla = ResponsiveHelper.anchoPantalla(context);
    final double altoPantalla = ResponsiveHelper.altoPantalla(context);

    // Calcular dimensiones de la tarjeta
    double anchoCard = ResponsiveHelper.valor(
      context,
      mobile: anchoPantalla * 0.9,
      tablet: 650,
      desktop: 1000,
    );

    double? altoCard = ResponsiveHelper.valor(
      context,
      mobile: altoPantalla,
      tablet: 650,
      desktop: 700,
    );

    // Contenido para móvil (solo formulario)
    if (esMobile) {
      return Center(
        child: SingleChildScrollView(
          child: Container(
            width: anchoCard,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: const LoginFormulario(),
            ),
          ),
        ),
      );
    }

    // Contenido para tablet/desktop (con panel lateral)
    return Center(
      child: Container(
        width: anchoCard,
        height: altoCard,
        constraints: const BoxConstraints(
          maxWidth: 1000,
          maxHeight: 600,
        ),
        margin: EdgeInsets.all(
          ResponsiveHelper.valor(context, mobile: 16, desktop: 32),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Panel lateral izquierdo
              if (!esTablet || anchoPantalla > 700)
                Expanded(
                  flex: 4,
                  child: const LoginLateral(),
                ),
              
              // Formulario derecho
              Expanded(
                flex: esTablet && anchoPantalla <= 700 ? 1 : 5,
                child: Container(
                  padding: EdgeInsets.all(
                    ResponsiveHelper.valor(
                      context,
                      mobile: 24,
                      tablet: 28,
                      desktop: 36,
                    ),
                  ),
                  child: const LoginFormulario(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}