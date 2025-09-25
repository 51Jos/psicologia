import 'package:flutter/material.dart';

class ColoresApp {
  // Prevenir instanciación
  ColoresApp._();

  // Colores principales (basados en las imágenes proporcionadas)
  static const Color primario = Color(0xFF6366F1); // Morado/Índigo
  static const Color primarioClaro = Color(0xFF818CF8);
  static const Color primarioOscuro = Color(0xFF4F46E5);
  
  // Colores secundarios
  static const Color secundario = Color(0xFF10B981); // Verde
  static const Color secundarioClaro = Color(0xFF34D399);
  static const Color secundarioOscuro = Color(0xFF059669);
  
  // Colores de fondo
  static const Color fondoPrimario = Color(0xFF1F2937); // Gris oscuro del sidebar
  static const Color fondoSecundario = Color(0xFFF3F4F6); // Gris claro
  static const Color fondoBlanco = Color(0xFFFFFFFF);
  static const Color fondoCard = Color(0xFFFFFFFF);
  
  // Colores de texto
  static const Color textoNegro = Color(0xFF111827);
  static const Color textoGris = Color(0xFF6B7280);
  static const Color textoGrisClaro = Color(0xFF9CA3AF);
  static const Color textoBlanco = Color(0xFFFFFFFF);
  
  // Colores de estado
  static const Color exito = Color(0xFF10B981);
  static const Color advertencia = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Colores de acción
  static const Color botonPrimario = primario;
  static const Color botonSecundario = Color(0xFF6B7280);
  static const Color botonExito = exito;
  static const Color botonPeligro = error;
  
  // Colores de condición (para las etiquetas de estado)
  static const Color condicionIniciativa = Color(0xFF3B82F6); // Azul
  static const Color condicionDerivado = Color(0xFFF59E0B); // Amarillo
  static const Color condicionEntrevista = Color(0xFF8B5CF6); // Morado
  
  // Colores de facultades (basados en las siglas mostradas)
  static const Color facultadFCS = Color(0xFF22D3EE); // Cyan
  static const Color facultadFCC = Color(0xFFFBBF24); // Amarillo
  static const Color facultadFC = Color(0xFF10B981); // Verde
  
  // Colores de bordes
  static const Color borde = Color(0xFFE5E7EB);
  static const Color bordeClaro = Color(0xFFF3F4F6);
  static const Color bordeOscuro = Color(0xFF9CA3AF);
  
  // Sombras
  static const Color sombra = Color(0x1A000000);
  static const Color sombraClara = Color(0x0D000000);
  static const Color sombraOscura = Color(0x33000000);
  
  // Gradientes
  static const LinearGradient gradientePrimario = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primario, primarioOscuro],
  );
  
  static const LinearGradient gradienteFondo = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primarioClaro, primario],
  );
}