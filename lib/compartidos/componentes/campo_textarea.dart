import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tema/colores_app.dart';
import '../utilidades/responsive_helper.dart';

class CampoTextarea extends StatefulWidget {
  final String? etiqueta;
  final String? placeholder;
  final String? valorInicial;
  final TextEditingController? controlador;
  final String? Function(String?)? validador;
  final void Function(String)? onChanged;
  final bool habilitado;
  final bool soloLectura;
  final int lineasMin;
  final int lineasMax;
  final int? longitudMax;
  final bool requerido;
  final bool mostrarContador;
  final FocusNode? focusNode;
  final TextCapitalization capitalizacion;
  final List<TextInputFormatter>? formateadores;

  const CampoTextarea({
    super.key,
    this.etiqueta,
    this.placeholder = 'Escribir aquí...',
    this.valorInicial,
    this.controlador,
    this.validador,
    this.onChanged,
    this.habilitado = true,
    this.soloLectura = false,
    this.lineasMin = 3,
    this.lineasMax = 5,
    this.longitudMax,
    this.requerido = false,
    this.mostrarContador = true,
    this.focusNode,
    this.capitalizacion = TextCapitalization.sentences,
    this.formateadores,
  });

  @override
  State<CampoTextarea> createState() => _CampoTextareaState();
}

class _CampoTextareaState extends State<CampoTextarea> {
  late TextEditingController _controlador;
  late FocusNode _focusNode;
  bool _tieneFoco = false;
  int _caracteresActuales = 0;

  @override
  void initState() {
    super.initState();
    _controlador = widget.controlador ?? TextEditingController(text: widget.valorInicial);
    _focusNode = widget.focusNode ?? FocusNode();
    _caracteresActuales = _controlador.text.length;
    
    _focusNode.addListener(() {
      setState(() {
        _tieneFoco = _focusNode.hasFocus;
      });
    });
    
    _controlador.addListener(() {
      setState(() {
        _caracteresActuales = _controlador.text.length;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controlador == null) {
      _controlador.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool esMobile = ResponsiveHelper.esMobile(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.etiqueta != null) ...[
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      widget.etiqueta!,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.fontSize(context, base: 14),
                        fontWeight: FontWeight.w600,
                        color: ColoresApp.textoNegro,
                      ),
                    ),
                    if (widget.requerido)
                      const Text(
                        ' *',
                        style: TextStyle(
                          color: ColoresApp.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.mostrarContador && widget.longitudMax != null)
                Text(
                  '$_caracteresActuales/${widget.longitudMax}',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(context, base: 12),
                    color: _caracteresActuales > widget.longitudMax!
                        ? ColoresApp.error
                        : ColoresApp.textoGrisClaro,
                  ),
                ),
            ],
          ),
          SizedBox(height: esMobile ? 6 : 8),
        ],
        
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _tieneFoco 
                  ? ColoresApp.primario 
                  : ColoresApp.borde,
              width: _tieneFoco ? 2 : 1,
            ),
            color: widget.habilitado 
                ? (_tieneFoco ? Colors.white : ColoresApp.fondoBlanco)
                : ColoresApp.fondoSecundario,
          ),
          child: TextFormField(
            controller: _controlador,
            focusNode: _focusNode,
            enabled: widget.habilitado,
            readOnly: widget.soloLectura,
            minLines: widget.lineasMin,
            maxLines: widget.lineasMax,
            maxLength: widget.longitudMax,
            textCapitalization: widget.capitalizacion,
            inputFormatters: widget.formateadores,
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(context, base: 16),
              color: widget.habilitado ? ColoresApp.textoNegro : ColoresApp.textoGris,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: TextStyle(
                fontSize: ResponsiveHelper.fontSize(context, base: 16),
                color: ColoresApp.textoGrisClaro,
              ),
              contentPadding: EdgeInsets.all(
                ResponsiveHelper.valor(context, mobile: 12, tablet: 14, desktop: 16),
              ),
              border: InputBorder.none,
              counterText: '', // Ocultamos el contador por defecto
            ),
            onChanged: widget.onChanged,
            validator: widget.validador,
          ),
        ),
        
        // Información adicional o contador personalizado
        if (!widget.etiqueta!.contains('${widget.longitudMax}') && 
            widget.mostrarContador && 
            widget.longitudMax != null)
          Padding(
            padding: EdgeInsets.only(
              top: ResponsiveHelper.valor(context, mobile: 4, desktop: 6),
              left: ResponsiveHelper.valor(context, mobile: 12, desktop: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_caracteresActuales > widget.longitudMax!)
                  Text(
                    'Has excedido el límite de caracteres',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(context, base: 12),
                      color: ColoresApp.error,
                    ),
                  )
                else
                  Text(
                    '${widget.longitudMax! - _caracteresActuales} caracteres restantes',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(context, base: 12),
                      color: ColoresApp.textoGrisClaro,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}