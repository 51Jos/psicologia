import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Breakpoints estándar
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  static const double largeDesktopBreakpoint = 1920;

  // Obtener el ancho de pantalla
  static double anchoPantalla(BuildContext context) => MediaQuery.of(context).size.width;
  
  // Obtener el alto de pantalla
  static double altoPantalla(BuildContext context) => MediaQuery.of(context).size.height;

  // Detectar tipo de dispositivo
  static bool esMobile(BuildContext context) => anchoPantalla(context) < mobileBreakpoint;
  
  static bool esTablet(BuildContext context) => 
      anchoPantalla(context) >= mobileBreakpoint && 
      anchoPantalla(context) < tabletBreakpoint;
  
  static bool esDesktop(BuildContext context) => anchoPantalla(context) >= tabletBreakpoint;
  
  static bool esLargeDesktop(BuildContext context) => anchoPantalla(context) >= largeDesktopBreakpoint;

  // Obtener el tipo de dispositivo
  static DispositivoTipo obtenerTipoDispositivo(BuildContext context) {
    final ancho = anchoPantalla(context);
    
    if (ancho < mobileBreakpoint) return DispositivoTipo.mobile;
    if (ancho < tabletBreakpoint) return DispositivoTipo.tablet;
    if (ancho < largeDesktopBreakpoint) return DispositivoTipo.desktop;
    return DispositivoTipo.largeDesktop;
  }

  // Valores responsivos
  static double valor(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    final tipo = obtenerTipoDispositivo(context);
    
    switch (tipo) {
      case DispositivoTipo.mobile:
        return mobile;
      case DispositivoTipo.tablet:
        return tablet ?? mobile;
      case DispositivoTipo.desktop:
        return desktop ?? tablet ?? mobile;
      case DispositivoTipo.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  // Padding responsivo
  static EdgeInsets paddingResponsivo(BuildContext context) {
    return EdgeInsets.all(
      valor(
        context,
        mobile: 16,
        tablet: 24,
        desktop: 32,
        largeDesktop: 40,
      ),
    );
  }

  // Margen responsivo
  static EdgeInsets margenResponsivo(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: valor(
        context,
        mobile: 16,
        tablet: 32,
        desktop: 64,
        largeDesktop: 120,
      ),
    );
  }

  // Tamaño de fuente responsivo
  static double fontSize(
    BuildContext context, {
    required double base,
  }) {
    final tipo = obtenerTipoDispositivo(context);
    
    switch (tipo) {
      case DispositivoTipo.mobile:
        return base * 0.9;
      case DispositivoTipo.tablet:
        return base;
      case DispositivoTipo.desktop:
        return base * 1.1;
      case DispositivoTipo.largeDesktop:
        return base * 1.2;
    }
  }

  // Número de columnas en grid
  static int columnas(
    BuildContext context, {
    int mobile = 1,
    int? tablet,
    int? desktop,
    int? largeDesktop,
  }) {
    final tipo = obtenerTipoDispositivo(context);
    
    switch (tipo) {
      case DispositivoTipo.mobile:
        return mobile;
      case DispositivoTipo.tablet:
        return tablet ?? 2;
      case DispositivoTipo.desktop:
        return desktop ?? 3;
      case DispositivoTipo.largeDesktop:
        return largeDesktop ?? 4;
    }
  }

  // Ancho máximo del contenido
  static double? anchoMaximo(BuildContext context) {
    final tipo = obtenerTipoDispositivo(context);
    
    switch (tipo) {
      case DispositivoTipo.mobile:
        return null;
      case DispositivoTipo.tablet:
        return 768;
      case DispositivoTipo.desktop:
        return 1200;
      case DispositivoTipo.largeDesktop:
        return 1400;
    }
  }

  // Orientación
  static bool esHorizontal(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;
  
  static bool esVertical(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;
}

// Enum para tipos de dispositivo
enum DispositivoTipo {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

// Widget Responsive Builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, DispositivoTipo) builder;
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  factory ResponsiveBuilder.simple({
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
    Widget? largeDesktop,
  }) {
    return ResponsiveBuilder(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
      builder: (context, tipo) {
        switch (tipo) {
          case DispositivoTipo.mobile:
            return mobile;
          case DispositivoTipo.tablet:
            return tablet ?? mobile;
          case DispositivoTipo.desktop:
            return desktop ?? tablet ?? mobile;
          case DispositivoTipo.largeDesktop:
            return largeDesktop ?? desktop ?? tablet ?? mobile;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tipo = ResponsiveHelper.obtenerTipoDispositivo(context);
    
    // Si se proporcionan widgets específicos, usarlos
    if (mobile != null || tablet != null || desktop != null || largeDesktop != null) {
      switch (tipo) {
        case DispositivoTipo.mobile:
          return mobile ?? builder(context, tipo);
        case DispositivoTipo.tablet:
          return tablet ?? mobile ?? builder(context, tipo);
        case DispositivoTipo.desktop:
          return desktop ?? tablet ?? mobile ?? builder(context, tipo);
        case DispositivoTipo.largeDesktop:
          return largeDesktop ?? desktop ?? tablet ?? mobile ?? builder(context, tipo);
      }
    }
    
    return builder(context, tipo);
  }
}

// Widget para contenedor con ancho máximo
class ContenedorResponsivo extends StatelessWidget {
  final Widget child;
  final double? anchoMaximo;
  final EdgeInsets? padding;

  const ContenedorResponsivo({
    super.key,
    required this.child,
    this.anchoMaximo,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: anchoMaximo ?? ResponsiveHelper.anchoMaximo(context) ?? double.infinity,
        ),
        padding: padding ?? ResponsiveHelper.paddingResponsivo(context),
        child: child,
      ),
    );
  }
}