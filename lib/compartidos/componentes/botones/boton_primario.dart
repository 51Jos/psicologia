import 'package:flutter/material.dart';
import '../../tema/colores_app.dart';
import '../../utilidades/responsive_helper.dart';

class BotonPrimario extends StatefulWidget {
  final String texto;
  final VoidCallback? onPressed;
  final IconData? icono;
  final bool cargando;
  final bool habilitado;
  final double? ancho;
  final double? alto;
  final Color? color;
  final Color? colorTexto;
  final double? tamanoTexto;
  final EdgeInsets? padding;
  final bool expandir;
  final bool esDestructivo;

  const BotonPrimario({
    super.key,
    required this.texto,
    this.onPressed,
    this.icono,
    this.cargando = false,
    this.habilitado = true,
    this.ancho,
    this.alto,
    this.color,
    this.colorTexto,
    this.tamanoTexto,
    this.padding,
    this.expandir = false,
    this.esDestructivo = false,
  });

  @override
  State<BotonPrimario> createState() => _BotonPrimarioState();
}

class _BotonPrimarioState extends State<BotonPrimario> with SingleTickerProviderStateMixin {
  late AnimationController _animacionControlador;
  late Animation<double> _escalaAnimacion;
  bool _presionado = false;

  @override
  void initState() {
    super.initState();
    _animacionControlador = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _escalaAnimacion = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _animacionControlador,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animacionControlador.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.habilitado && !widget.cargando) {
      setState(() => _presionado = true);
      _animacionControlador.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.habilitado && !widget.cargando) {
      setState(() => _presionado = false);
      _animacionControlador.reverse();
    }
  }

  void _onTapCancel() {
    setState(() => _presionado = false);
    _animacionControlador.reverse();
  }

  Color _obtenerColor() {
    if (widget.esDestructivo) {
      return ColoresApp.error;
    }
    return widget.color ?? ColoresApp.primario;
  }

  @override
  Widget build(BuildContext context) {
    final bool esMobile = ResponsiveHelper.esMobile(context);
    ResponsiveHelper.esTablet(context);
    
    final double altoBoton = widget.alto ?? ResponsiveHelper.valor(
      context,
      mobile: 48,
      tablet: 52,
      desktop: 56,
    );
    
    final double tamanoFuente = widget.tamanoTexto ?? ResponsiveHelper.fontSize(
      context,
      base: 16,
    );
    
    final EdgeInsets paddingBoton = widget.padding ?? EdgeInsets.symmetric(
      horizontal: ResponsiveHelper.valor(context, mobile: 20, tablet: 24, desktop: 28),
      vertical: ResponsiveHelper.valor(context, mobile: 12, tablet: 14, desktop: 16),
    );

    Widget boton = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: (widget.habilitado && !widget.cargando) ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _escalaAnimacion,
        builder: (context, child) {
          return Transform.scale(
            scale: _escalaAnimacion.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.ancho,
              height: altoBoton,
              padding: paddingBoton,
              decoration: BoxDecoration(
                color: !widget.habilitado
                    ? ColoresApp.textoGrisClaro
                    : _presionado
                        // ignore: deprecated_member_use
                        ? _obtenerColor().withOpacity(0.8)
                        : _obtenerColor(),
                borderRadius: BorderRadius.circular(8),
                boxShadow: widget.habilitado && !_presionado
                    ? [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: _obtenerColor().withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: widget.cargando
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.colorTexto ?? ColoresApp.textoBlanco,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icono != null) ...[
                            Icon(
                              widget.icono,
                              color: widget.colorTexto ?? ColoresApp.textoBlanco,
                              size: ResponsiveHelper.valor(
                                context,
                                mobile: 18,
                                tablet: 20,
                                desktop: 22,
                              ),
                            ),
                            SizedBox(width: esMobile ? 6 : 8),
                          ],
                          Flexible(
                            child: Text(
                              widget.texto,
                              style: TextStyle(
                                color: widget.colorTexto ?? ColoresApp.textoBlanco,
                                fontSize: tamanoFuente,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );

    if (widget.expandir) {
      return SizedBox(
        width: double.infinity,
        child: boton,
      );
    }

    return boton;
  }
}

// Variante para botón con gradiente
class BotonGradiente extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final IconData? icono;
  final bool cargando;
  final bool habilitado;
  final bool expandir;
  final List<Color>? colores;

  const BotonGradiente({
    super.key,
    required this.texto,
    this.onPressed,
    this.icono,
    this.cargando = false,
    this.habilitado = true,
    this.expandir = false,
    this.colores,
  });

  @override
  Widget build(BuildContext context) {
    final gradiente = colores ?? [
      ColoresApp.primarioClaro,
      ColoresApp.primario,
    ];

    return Container(
      width: expandir ? double.infinity : null,
      height: ResponsiveHelper.valor(
        context,
        mobile: 48,
        tablet: 52,
        desktop: 56,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: habilitado 
              ? gradiente
              : [ColoresApp.textoGrisClaro, ColoresApp.textoGris],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: habilitado
            ? [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: gradiente.last.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: (habilitado && !cargando) ? onPressed : null,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: cargando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ColoresApp.textoBlanco,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icono != null) ...[
                        Icon(
                          icono,
                          color: ColoresApp.textoBlanco,
                          size: ResponsiveHelper.valor(
                            context,
                            mobile: 18,
                            tablet: 20,
                            desktop: 22,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        texto,
                        style: TextStyle(
                          color: ColoresApp.textoBlanco,
                          fontSize: ResponsiveHelper.fontSize(context, base: 16),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}