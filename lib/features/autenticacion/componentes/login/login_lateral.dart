import 'package:flutter/material.dart';
import '../../../../compartidos/tema/colores_app.dart';
import '../../../../compartidos/utilidades/responsive_helper.dart';
import 'dart:ui';

class LoginLateral extends StatelessWidget {
  const LoginLateral({super.key});

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
        gradient: ColoresApp.gradientePrimario,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: ColoresApp.primario.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icono principal con efecto glassmorphism
          Container(
            padding: EdgeInsets.all(
              ResponsiveHelper.valor(context, mobile: 20, desktop: 28),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Icon(
                  Icons.psychology_rounded,
                  size: ResponsiveHelper.valor(
                    context,
                    mobile: 60,
                    tablet: 70,
                    desktop: 80,
                  ),
                  color: Colors.white,
                ),
              ),
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

          // Título con sombra
          Text(
            'Bienvenido',
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(
                context,
                base: esMobile ? 28 : esTablet ? 32 : 36,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(
            height: ResponsiveHelper.valor(context, mobile: 16, desktop: 24),
          ),

          // Subtítulo
          Text(
            'Sistema de Atención\nPsicológica Estudiantil',
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(
                context,
                base: esMobile ? 14 : 16,
              ),
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(
            height: ResponsiveHelper.valor(context, mobile: 12, desktop: 20),
          ),

          // Descripción
          Text(
            'Gestiona consultas y realiza\nseguimiento académico de forma segura',
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(
                context,
                base: esMobile ? 12 : 14,
              ),
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          if (!esMobile) ...[
            SizedBox(
              height: ResponsiveHelper.valor(context, mobile: 32, desktop: 48),
            ),

            // Características en badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _FeatureBadge(icon: Icons.security_rounded, label: 'Seguro'),
                _FeatureBadge(icon: Icons.speed_rounded, label: 'Rápido'),
                _FeatureBadge(icon: Icons.cloud_done_rounded, label: 'En la nube'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}