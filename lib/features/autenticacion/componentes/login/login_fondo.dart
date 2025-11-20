import 'package:flutter/material.dart';
import '../../../../compartidos/tema/colores_app.dart';
import 'dart:math' as math;

class LoginFondo extends StatefulWidget {
  final Widget child;

  const LoginFondo({
    super.key,
    required this.child,
  });

  @override
  State<LoginFondo> createState() => _LoginFondoState();
}

class _LoginFondoState extends State<LoginFondo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: ColoresApp.gradienteLogin,
      ),
      child: Stack(
        children: [
          // Patrón de fondo animado
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _FondoAnimadoPainter(_controller.value),
              );
            },
          ),

          // Círculos decorativos mejorados con glassmorphism
          Positioned(
            top: -120,
            right: -120,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -180,
            left: -180,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ColoresApp.acento.withValues(alpha: 0.15),
                    ColoresApp.acento.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            right: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.01),
                  ],
                ),
              ),
            ),
          ),

          // Efecto de brillo en la esquina superior izquierda
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _FondoAnimadoPainter extends CustomPainter {
  final double animationValue;

  _FondoAnimadoPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.03);

    // Dibujar líneas decorativas animadas
    for (int i = 0; i < 5; i++) {
      final offset = (animationValue + i * 0.2) % 1.0;
      final y = size.height * offset;

      final path = Path();
      path.moveTo(0, y);

      for (double x = 0; x <= size.width; x += 50) {
        final wave = math.sin((x / size.width) * math.pi * 2 + animationValue * math.pi * 2) * 20;
        path.lineTo(x, y + wave);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_FondoAnimadoPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}