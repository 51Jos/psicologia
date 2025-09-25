import 'package:flutter/material.dart';
import '../../../../compartidos/tema/colores_app.dart';
import '../../../../compartidos/utilidades/responsive_helper.dart';

class LoginLateral extends StatelessWidget {
  const LoginLateral({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool esMobile = ResponsiveHelper.esMobile(context);
    final bool esTablet = ResponsiveHelper.esTablet(context);

    return Container(
      padding: EdgeInsets.all(
        ResponsiveHelper.valor(
          context,
          mobile: 24,
          tablet: 32,
          desktop: 48,
        ),
      ),
      decoration: BoxDecoration(
        color: ColoresApp.fondoPrimario.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icono principal
          Container(
            padding: EdgeInsets.all(
              ResponsiveHelper.valor(context, mobile: 20, desktop: 28),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school,
              size: ResponsiveHelper.valor(
                context,
                mobile: 60,
                tablet: 70,
                desktop: 80,
              ),
              color: Colors.white,
            ),
          ),
          
          SizedBox(
            height: ResponsiveHelper.valor(
              context,
              mobile: 24,
              tablet: 32,
              desktop: 40,
            ),
          ),
          
          // Título
          Text(
            'Bienvenido',
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(
                context,
                base: esMobile ? 28 : esTablet ? 32 : 36,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(
            height: ResponsiveHelper.valor(context, mobile: 16, desktop: 24),
          ),
          
          // Subtítulo
          Text(
            'Sistema de Registro de\nAtenciones Estudiantiles',
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(
                context,
                base: esMobile ? 14 : 16,
              ),
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(
            height: ResponsiveHelper.valor(context, mobile: 8, desktop: 16),
          ),
          
          // Descripción
          Text(
            'Accede de forma segura para gestionar las\nconsultas psicológicas y seguimiento académico',
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(
                context,
                base: esMobile ? 12 : 14,
              ),
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (!esMobile) ...[
            SizedBox(
              height: ResponsiveHelper.valor(context, mobile: 32, desktop: 48),
            ),
            
            // Elementos decorativos
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}