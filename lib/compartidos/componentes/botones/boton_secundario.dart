import 'package:flutter/material.dart';
import 'package:psicologia/compartidos/componentes/botones/boton_primario.dart';
import '../../tema/colores_app.dart';
import '../../utilidades/responsive_helper.dart';

class BotonSecundario extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final IconData? icono;
  final bool cargando;
  final bool habilitado;
  final double? ancho;
  final Color? colorBorde;
  final Color? colorTexto;
  final bool expandir;

  const BotonSecundario({
    Key? key,
    required this.texto,
    this.onPressed,
    this.icono,
    this.cargando = false,
    this.habilitado = true,
    this.ancho,
    this.colorBorde,
    this.colorTexto,
    this.expandir = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color color = colorBorde ?? ColoresApp.primario;
    final Color textoColor = colorTexto ?? color;
    
    Widget boton = OutlinedButton(
      onPressed: (habilitado && !cargando) ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: textoColor,
        side: BorderSide(
          color: habilitado ? color : ColoresApp.textoGrisClaro,
          width: ResponsiveHelper.esMobile(context) ? 1.5 : 2,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.valor(context, mobile: 20, tablet: 24, desktop: 28),
          vertical: ResponsiveHelper.valor(context, mobile: 12, tablet: 14, desktop: 16),
        ),
        minimumSize: Size(
          ancho ?? 0,
          ResponsiveHelper.valor(context, mobile: 48, tablet: 52, desktop: 56),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: cargando
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textoColor),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icono != null) ...[
                  Icon(
                    icono,
                    size: ResponsiveHelper.valor(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.esMobile(context) ? 6 : 8),
                ],
                Flexible(
                  child: Text(
                    texto,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(context, base: 16),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );

    if (expandir) {
      return SizedBox(
        width: double.infinity,
        child: boton,
      );
    }

    return boton;
  }
}

// Botón de texto (sin bordes)
class BotonTexto extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final IconData? icono;
  final Color? color;
  final double? tamanoTexto;
  final bool habilitado;

  const BotonTexto({
    super.key,
    required this.texto,
    this.onPressed,
    this.icono,
    this.color,
    this.tamanoTexto,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color colorBoton = color ?? ColoresApp.primario;
    
    return TextButton(
      onPressed: habilitado ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: colorBoton,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.valor(context, mobile: 12, tablet: 16, desktop: 20),
          vertical: ResponsiveHelper.valor(context, mobile: 8, tablet: 10, desktop: 12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(
              icono,
              size: ResponsiveHelper.valor(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            texto,
            style: TextStyle(
              fontSize: tamanoTexto ?? ResponsiveHelper.fontSize(context, base: 14),
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}

// Botón de icono circular
class BotonIcono extends StatelessWidget {
  final IconData icono;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? colorFondo;
  final double? tamano;
  final String? tooltip;
  final bool habilitado;

  const BotonIcono({
    super.key,
    required this.icono,
    this.onPressed,
    this.color,
    this.colorFondo,
    this.tamano,
    this.tooltip,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) {
    final double tamanoBoton = tamano ?? ResponsiveHelper.valor(
      context,
      mobile: 40,
      tablet: 44,
      desktop: 48,
    );
    
    Widget boton = Material(
      color: colorFondo ?? Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: habilitado ? onPressed : null,
        customBorder: const CircleBorder(),
        child: Container(
          width: tamanoBoton,
          height: tamanoBoton,
          alignment: Alignment.center,
          child: Icon(
            icono,
            color: habilitado 
                ? (color ?? ColoresApp.primario)
                : ColoresApp.textoGrisClaro,
            size: tamanoBoton * 0.6,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: boton,
      );
    }

    return boton;
  }
}

// Grupo de botones de acción (usado en formularios)
class GrupoBotonesAccion extends StatelessWidget {
  final String? textoPrimario;
  final String? textoSecundario;
  final VoidCallback? onPrimario;
  final VoidCallback? onSecundario;
  final IconData? iconoPrimario;
  final IconData? iconoSecundario;
  final bool cargando;
  final bool habilitado;
  final MainAxisAlignment alineacion;

  const GrupoBotonesAccion({
    super.key,
    this.textoPrimario = 'Guardar',
    this.textoSecundario = 'Cancelar',
    this.onPrimario,
    this.onSecundario,
    this.iconoPrimario,
    this.iconoSecundario,
    this.cargando = false,
    this.habilitado = true,
    this.alineacion = MainAxisAlignment.end,
  });

  @override
  Widget build(BuildContext context) {
    final bool esMobile = ResponsiveHelper.esMobile(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.valor(context, mobile: 16, tablet: 20, desktop: 24),
      ),
      child: esMobile
          ? Column(
              children: [
                if (textoPrimario != null)
                  BotonPrimario(
                    texto: textoPrimario!,
                    onPressed: onPrimario,
                    icono: iconoPrimario,
                    cargando: cargando,
                    habilitado: habilitado,
                    expandir: true,
                  ),
                if (textoSecundario != null) ...[
                  const SizedBox(height: 12),
                  BotonSecundario(
                    texto: textoSecundario!,
                    onPressed: onSecundario,
                    icono: iconoSecundario,
                    habilitado: !cargando,
                    expandir: true,
                  ),
                ],
              ],
            )
          : Row(
              mainAxisAlignment: alineacion,
              children: [
                if (textoSecundario != null) ...[
                  BotonSecundario(
                    texto: textoSecundario!,
                    onPressed: onSecundario,
                    icono: iconoSecundario,
                    habilitado: !cargando,
                  ),
                  const SizedBox(width: 16),
                ],
                if (textoPrimario != null)
                  BotonPrimario(
                    texto: textoPrimario!,
                    onPressed: onPrimario,
                    icono: iconoPrimario,
                    cargando: cargando,
                    habilitado: habilitado,
                  ),
              ],
            ),
    );
  }
}