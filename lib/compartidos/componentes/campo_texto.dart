import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tema/colores_app.dart';
import '../utilidades/responsive_helper.dart';

class CampoTexto extends StatefulWidget {
  final String? etiqueta;
  final String? placeholder;
  final String? valorInicial;
  final TextEditingController? controlador;
  final String? Function(String?)? validador;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final TextInputType tipoTeclado;
  final TextInputAction accionTeclado;
  final bool obscureText;
  final bool habilitado;
  final bool soloLectura;
  final int? lineasMax;
  final int? longitudMax;
  final Widget? prefijo;
  final Widget? sufijo;
  final IconData? iconoPrefijo;
  final IconData? iconoSufijo;
  final void Function()? onIconoSufijoTap;
  final List<TextInputFormatter>? formateadores;
  final bool autovalidar;
  final bool requerido;
  final FocusNode? focusNode;
  final TextCapitalization capitalizacion;
  final TextAlign alineacionTexto;
  final bool expandir;

  const CampoTexto({
    Key? key,
    this.etiqueta,
    this.placeholder,
    this.valorInicial,
    this.controlador,
    this.validador,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.tipoTeclado = TextInputType.text,
    this.accionTeclado = TextInputAction.next,
    this.obscureText = false,
    this.habilitado = true,
    this.soloLectura = false,
    this.lineasMax = 1,
    this.longitudMax,
    this.prefijo,
    this.sufijo,
    this.iconoPrefijo,
    this.iconoSufijo,
    this.onIconoSufijoTap,
    this.formateadores,
    this.autovalidar = false,
    this.requerido = false,
    this.focusNode,
    this.capitalizacion = TextCapitalization.none,
    this.alineacionTexto = TextAlign.start,
    this.expandir = false,
  }) : super(key: key);

  @override
  State<CampoTexto> createState() => _CampoTextoState();
}

class _CampoTextoState extends State<CampoTexto> {
  late TextEditingController _controlador;
  late FocusNode _focusNode;
  bool _tieneFoco = false;
  String? _errorTexto;

  @override
  void initState() {
    super.initState();
    _controlador = widget.controlador ?? TextEditingController(text: widget.valorInicial);
    _focusNode = widget.focusNode ?? FocusNode();
    
    _focusNode.addListener(() {
      setState(() {
        _tieneFoco = _focusNode.hasFocus;
        if (!_tieneFoco && widget.autovalidar) {
          _validar();
        }
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

  void _validar() {
    if (widget.validador != null) {
      setState(() {
        _errorTexto = widget.validador!(_controlador.text);
      });
    }
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
          SizedBox(height: esMobile ? 6 : 8),
        ],
        
        TextFormField(
          controller: _controlador,
          focusNode: _focusNode,
          enabled: widget.habilitado,
          readOnly: widget.soloLectura,
          obscureText: widget.obscureText,
          keyboardType: widget.tipoTeclado,
          textInputAction: widget.accionTeclado,
          maxLines: widget.expandir ? null : widget.lineasMax,
          minLines: widget.expandir ? widget.lineasMax : null,
          maxLength: widget.longitudMax,
          inputFormatters: widget.formateadores,
          textCapitalization: widget.capitalizacion,
          textAlign: widget.alineacionTexto,
          style: TextStyle(
            fontSize: ResponsiveHelper.fontSize(context, base: 16),
            color: widget.habilitado ? ColoresApp.textoNegro : ColoresApp.textoGris,
          ),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            errorText: _errorTexto,
            filled: true,
            fillColor: widget.habilitado 
                ? (_tieneFoco ? Colors.white : ColoresApp.fondoBlanco)
                : ColoresApp.fondoSecundario,
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.valor(context, mobile: 12, tablet: 14, desktop: 16),
              vertical: ResponsiveHelper.valor(context, mobile: 12, tablet: 14, desktop: 16),
            ),
            prefixIcon: widget.iconoPrefijo != null
                ? Icon(
                    widget.iconoPrefijo,
                    size: ResponsiveHelper.valor(context, mobile: 20, tablet: 22, desktop: 24),
                    color: _tieneFoco ? ColoresApp.primario : ColoresApp.textoGris,
                  )
                : widget.prefijo,
            suffixIcon: widget.iconoSufijo != null
                ? IconButton(
                    icon: Icon(
                      widget.iconoSufijo,
                      size: ResponsiveHelper.valor(context, mobile: 20, tablet: 22, desktop: 24),
                    ),
                    color: _tieneFoco ? ColoresApp.primario : ColoresApp.textoGris,
                    onPressed: widget.onIconoSufijoTap ?? () {},
                  )
                : widget.sufijo,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ColoresApp.borde),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _errorTexto != null ? ColoresApp.error : ColoresApp.borde,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _errorTexto != null ? ColoresApp.error : ColoresApp.primario,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: ColoresApp.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: ColoresApp.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: ColoresApp.bordeClaro,
                width: 1,
              ),
            ),
          ),
          onChanged: (valor) {
            if (widget.onChanged != null) {
              widget.onChanged!(valor);
            }
            if (widget.autovalidar && _errorTexto != null) {
              _validar();
            }
          },
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          validator: widget.validador,
        ),
      ],
    );
  }
}