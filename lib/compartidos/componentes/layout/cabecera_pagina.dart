import 'package:flutter/material.dart';
import '../../tema/colores_app.dart';
import '../../utilidades/responsive_helper.dart';
import '../botones/boton_primario.dart';
import '../botones/boton_secundario.dart';

class CabeceraPagina extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final String? descripcion;
  final Widget? iconoIzquierda;
  final List<Widget>? acciones;
  final Color? colorFondo;
  final Color? colorTexto;
  final bool mostrarDivider;
  final EdgeInsets? padding;
  final VoidCallback? onBack;
  final bool centrarTitulo;

  const CabeceraPagina({
    Key? key,
    required this.titulo,
    this.subtitulo,
    this.descripcion,
    this.iconoIzquierda,
    this.acciones,
    this.colorFondo,
    this.colorTexto,
    this.mostrarDivider = true,
    this.padding,
    this.onBack,
    this.centrarTitulo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool esMobile = ResponsiveHelper.esMobile(context);
    final bool esTablet = ResponsiveHelper.esTablet(context);
    final bool esDesktop = ResponsiveHelper.esDesktop(context);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorFondo ?? ColoresApp.fondoPrimario,
        boxShadow: mostrarDivider
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: padding ?? EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.valor(
                context,
                mobile: 16,
                tablet: 24,
                desktop: 32,
              ),
              vertical: ResponsiveHelper.valor(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila principal con título y acciones
                if (esMobile)
                  // Layout móvil - vertical
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (onBack != null) ...[
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              color: colorTexto ?? ColoresApp.textoBlanco,
                              onPressed: onBack,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (iconoIzquierda != null) ...[
                            iconoIzquierda!,
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Text(
                              titulo,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.fontSize(
                                  context,
                                  base: 24,
                                ),
                                fontWeight: FontWeight.bold,
                                color: colorTexto ?? ColoresApp.textoBlanco,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (subtitulo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitulo!,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(context, base: 14),
                            color: (colorTexto ?? ColoresApp.textoBlanco).withOpacity(0.8),
                          ),
                        ),
                      ],
                      if (acciones != null && acciones!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: acciones!,
                        ),
                      ],
                    ],
                  )
                else
                  // Layout tablet/desktop - horizontal
                  Row(
                    children: [
                      if (onBack != null) ...[
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: colorTexto ?? ColoresApp.textoBlanco,
                          onPressed: onBack,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (iconoIzquierda != null) ...[
                        iconoIzquierda!,
                        const SizedBox(width: 16),
                      ],
                      if (!centrarTitulo)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                titulo,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.fontSize(
                                    context,
                                    base: esDesktop ? 28 : 26,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: colorTexto ?? ColoresApp.textoBlanco,
                                ),
                              ),
                              if (subtitulo != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  subtitulo!,
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.fontSize(
                                      context,
                                      base: 14,
                                    ),
                                    color: (colorTexto ?? ColoresApp.textoBlanco)
                                        .withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      if (centrarTitulo) ...[
                        const Spacer(),
                        Column(
                          children: [
                            Text(
                              titulo,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.fontSize(
                                  context,
                                  base: esDesktop ? 28 : 26,
                                ),
                                fontWeight: FontWeight.bold,
                                color: colorTexto ?? ColoresApp.textoBlanco,
                              ),
                            ),
                            if (subtitulo != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                subtitulo!,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.fontSize(
                                    context,
                                    base: 14,
                                  ),
                                  color: (colorTexto ?? ColoresApp.textoBlanco)
                                      .withOpacity(0.8),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const Spacer(),
                      ],
                      if (acciones != null && acciones!.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        ...acciones!.map((accion) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: accion,
                        )),
                      ],
                    ],
                  ),
                
                // Descripción adicional
                if (descripcion != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    descripcion!,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(context, base: 14),
                      color: (colorTexto ?? ColoresApp.textoBlanco).withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          if (mostrarDivider)
            Container(
              height: 1,
              color: ColoresApp.borde.withOpacity(0.2),
            ),
        ],
      ),
    );
  }
}

// Widget helper para acciones comunes en la cabecera
class AccionCabecera extends StatelessWidget {
  final String? texto;
  final IconData? icono;
  final VoidCallback? onPressed;
  final bool esPrimario;
  final bool cargando;

  const AccionCabecera({
    Key? key,
    this.texto,
    this.icono,
    this.onPressed,
    this.esPrimario = false,
    this.cargando = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (texto != null) {
      if (esPrimario) {
        return BotonPrimario(
          texto: texto!,
          icono: icono,
          onPressed: onPressed,
          cargando: cargando,
          color: ColoresApp.secundario,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.valor(context, mobile: 16, desktop: 20),
            vertical: ResponsiveHelper.valor(context, mobile: 8, desktop: 10),
          ),
        );
      } else {
        return BotonSecundario(
          texto: texto!,
          icono: icono,
          onPressed: onPressed,
          cargando: cargando,
          colorBorde: ColoresApp.textoBlanco,
          colorTexto: ColoresApp.textoBlanco,
        );
      }
    }
    
    if (icono != null) {
      return IconButton(
        icon: Icon(icono),
        onPressed: onPressed,
        color: ColoresApp.textoBlanco,
        tooltip: texto,
      );
    }
    
    return const SizedBox.shrink();
  }
}