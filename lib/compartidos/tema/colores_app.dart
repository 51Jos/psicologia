import 'package:flutter/material.dart';

class ColoresApp {
  // Prevenir instanciación
  ColoresApp._();

  // Colores principales - Esquema elegante y sofisticado
  static const Color primario = Color(0xFF2D3748); // Gris carbón elegante
  static const Color primarioClaro = Color(0xFF4A5568); // Gris medio
  static const Color primarioOscuro = Color(0xFF1A202C); // Negro suave
  static const Color primarioMuyClaro = Color(0xFFEDF2F7); // Gris perla

  // Colores secundarios - Dorado elegante como acento
  static const Color secundario = Color(0xFFD4AF37); // Dorado sofisticado
  static const Color secundarioClaro = Color(0xFFE8C468);
  static const Color secundarioOscuro = Color(0xFFB8941E);

  // Acento adicional - Teal refinado
  static const Color acento = Color(0xFF319795); // Teal elegante
  static const Color acentoClaro = Color(0xFF4FD1C5);

  // Colores de fondo - Minimalista
  static const Color fondoPrimario = Color(0xFF1A202C); // Negro suave
  static const Color fondoSecundario = Color(0xFFFAFAFA); // Blanco humo
  static const Color fondoBlanco = Color(0xFFFFFFFF);
  static const Color fondoCard = Color(0xFFFFFFFF);
  static const Color fondoInput = Color(0xFFF5F5F5); // Gris perla muy suave

  // Colores de texto - Elegante y legible
  static const Color textoNegro = Color(0xFF1A1A1A);
  static const Color textoGris = Color(0xFF666666);
  static const Color textoGrisClaro = Color(0xFF999999);
  static const Color textoBlanco = Color(0xFFFFFFFF);
  static const Color textoMuted = Color(0xFF737373);

  // Colores de estado - Sofisticados
  static const Color exito = Color(0xFF10B981); // Verde esmeralda
  static const Color advertencia = Color(0xFFF59E0B); // Ámbar
  static const Color error = Color(0xFFDC2626); // Rojo elegante
  static const Color info = Color(0xFF0891B2); // Cyan oscuro

  // Colores de acción
  static const Color botonPrimario = primario;
  static const Color botonSecundario = Color(0xFF666666);
  static const Color botonExito = exito;
  static const Color botonPeligro = error;

  // Colores de condición (para las etiquetas de estado)
  static const Color condicionIniciativa = Color(0xFF0891B2); // Cyan oscuro
  static const Color condicionDerivado = Color(0xFFD97706); // Ámbar oscuro
  static const Color condicionEntrevista = Color(0xFF7C3AED); // Violeta sofisticado

  // Colores de facultades
  static const Color facultadFCS = Color(0xFF06B6D4); // Cyan refinado
  static const Color facultadFCC = Color(0xFFD4AF37); // Dorado
  static const Color facultadFC = Color(0xFF10B981); // Verde esmeralda

  // Colores de bordes - Sutiles y elegantes
  static const Color borde = Color(0xFFE5E5E5);
  static const Color bordeClaro = Color(0xFFF5F5F5);
  static const Color bordeOscuro = Color(0xFFD4D4D4);
  static const Color bordeFocus = secundario; // Dorado al hacer focus

  // Sombras - Sutiles y elegantes
  static const Color sombra = Color(0x0A000000); // Muy sutil
  static const Color sombraClara = Color(0x05000000); // Casi imperceptible
  static const Color sombraOscura = Color(0x15000000); // Suave

  // Gradientes elegantes y sofisticados
  static const LinearGradient gradientePrimario = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2D3748), Color(0xFF1A202C)], // Gris oscuro elegante
  );

  static const LinearGradient gradienteSecundario = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4AF37), Color(0xFFB8941E)], // Dorado elegante
  );

  static const LinearGradient gradienteFondo = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2D3748), Color(0xFF1A202C)],
  );

  static const LinearGradient gradienteLogin = LinearGradient(
    begin: Alignment(-1.5, -1.5),
    end: Alignment(1.5, 1.5),
    colors: [
      Color(0xFF1A202C), // Negro suave
      Color(0xFF2D3748), // Gris oscuro
      Color(0xFF4A5568), // Gris medio
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient gradienteSutil = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFAFAFA), Color(0xFFF5F5F5)],
  );

  // Gradiente con toque dorado para elementos premium
  static const LinearGradient gradienteDorado = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4AF37), Color(0xFFE8C468)],
  );

  // Overlay con opacidad
  static Color overlay(double opacity) => Color(0xFF1A202C).withValues(alpha: opacity);
}
