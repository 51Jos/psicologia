import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colores_app.dart';

class TemaApp {
  // Prevenir instanciación
  TemaApp._();

  // Radio de bordes
  static const double radioBase = 8.0;
  static const double radioGrande = 12.0;
  static const double radioPequeno = 4.0;
  static const double radioCompleto = 100.0;

  // Espaciados
  static const double espaciadoXS = 4.0;
  static const double espaciadoSM = 8.0;
  static const double espaciadoMD = 16.0;
  static const double espaciadoLG = 24.0;
  static const double espaciadoXL = 32.0;
  static const double espaciadoXXL = 48.0;

  // Espaciados responsivos (se calculan dinámicamente)
  static double espaciadoResponsivo(BuildContext context, double base) {
    final ancho = MediaQuery.of(context).size.width;
    if (ancho < 600) return base * 0.8;  // Mobile
    if (ancho < 1024) return base;        // Tablet
    return base * 1.2;                    // Desktop
  }

  // Tamaños de fuente base
  static const double fontSizeXS = 10.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeMD = 14.0;
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 20.0;
  static const double fontSizeXXL = 24.0;
  static const double fontSizeXXXL = 32.0;

  // Tema Claro
  static ThemeData get temaClaro => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Colores
    primaryColor: ColoresApp.primario,
    scaffoldBackgroundColor: ColoresApp.fondoSecundario,
    
    // ColorScheme
    colorScheme: const ColorScheme.light(
      primary: ColoresApp.primario,
      secondary: ColoresApp.secundario,
      surface: ColoresApp.fondoBlanco,
      background: ColoresApp.fondoSecundario,
      error: ColoresApp.error,
      onPrimary: ColoresApp.textoBlanco,
      onSecondary: ColoresApp.textoBlanco,
      onSurface: ColoresApp.textoNegro,
      onBackground: ColoresApp.textoNegro,
      onError: ColoresApp.textoBlanco,
    ),
    
    // AppBar
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: ColoresApp.fondoPrimario,
      foregroundColor: ColoresApp.textoBlanco,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: ColoresApp.textoBlanco,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(
        color: ColoresApp.textoBlanco,
      ),
    ),
    
    // Card
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: ColoresApp.sombra,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radioBase),
      ),
      color: ColoresApp.fondoCard,
      margin: const EdgeInsets.all(espaciadoMD),
    ),
    
    // Elevated Button - Elegante
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(ColoresApp.primario),
        foregroundColor: MaterialStateProperty.all(ColoresApp.textoBlanco),
        elevation: MaterialStateProperty.all(0), // Flat design elegante
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(
            horizontal: espaciadoLG,
            vertical: espaciadoMD,
          ),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radioGrande),
          ),
        ),
        textStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    ),
    
    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(ColoresApp.primario),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(
            horizontal: espaciadoLG,
            vertical: espaciadoMD,
          ),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radioBase),
            side: const BorderSide(color: ColoresApp.primario),
          ),
        ),
        textStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
    
    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(ColoresApp.primario),
        textStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
    
    // Input Decoration - Mejorado con nuevo esquema
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColoresApp.fondoInput,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: espaciadoMD,
        vertical: espaciadoMD,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radioGrande),
        borderSide: const BorderSide(color: ColoresApp.borde, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radioGrande),
        borderSide: const BorderSide(color: ColoresApp.borde, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radioGrande),
        borderSide: const BorderSide(
          color: ColoresApp.secundario, // Dorado elegante al hacer focus
          width: 2.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radioGrande),
        borderSide: const BorderSide(
          color: ColoresApp.error,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radioGrande),
        borderSide: const BorderSide(
          color: ColoresApp.error,
          width: 2.5,
        ),
      ),
      labelStyle: const TextStyle(
        color: ColoresApp.textoGris,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(
        color: ColoresApp.textoGrisClaro,
        fontSize: 14,
      ),
      errorStyle: const TextStyle(
        color: ColoresApp.error,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: ColoresApp.textoGris,
      suffixIconColor: ColoresApp.textoGris,
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: ColoresApp.fondoSecundario,
      deleteIconColor: ColoresApp.textoGris,
      disabledColor: ColoresApp.bordeClaro,
      selectedColor: ColoresApp.primario,
      secondarySelectedColor: ColoresApp.primarioClaro,
      padding: const EdgeInsets.symmetric(
        horizontal: espaciadoSM,
        vertical: espaciadoXS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radioCompleto),
      ),
      labelStyle: const TextStyle(
        color: ColoresApp.textoNegro,
        fontSize: 12,
      ),
      secondaryLabelStyle: const TextStyle(
        color: ColoresApp.textoBlanco,
        fontSize: 12,
      ),
      brightness: Brightness.light,
    ),
    
    // Divider
    dividerTheme: const DividerThemeData(
      color: ColoresApp.borde,
      thickness: 1,
      space: espaciadoMD,
    ),
  );

  // Tema Oscuro (opcional)
  static ThemeData get temaOscuro => temaClaro.copyWith(
    brightness: Brightness.dark,
    // Puedes personalizar el tema oscuro aquí si es necesario
  );
}