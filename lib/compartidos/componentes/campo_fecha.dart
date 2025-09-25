import 'package:flutter/material.dart';
import '../tema/colores_app.dart';
import '../utilidades/formateadores.dart';
import 'campo_texto.dart';

class CampoFecha extends StatefulWidget {
  final String? etiqueta;
  final String? placeholder;
  final DateTime? valorInicial;
  final DateTime? fechaMinima;
  final DateTime? fechaMaxima;
  final String? Function(DateTime?)? validador;
  final void Function(DateTime?)? onChanged;
  final bool habilitado;
  final bool requerido;
  final DatePickerMode modoInicial;
  final String formatoFecha;

  const CampoFecha({
    super.key,
    this.etiqueta,
    this.placeholder = 'Seleccionar fecha',
    this.valorInicial,
    this.fechaMinima,
    this.fechaMaxima,
    this.validador,
    this.onChanged,
    this.habilitado = true,
    this.requerido = false,
    this.modoInicial = DatePickerMode.day,
    this.formatoFecha = 'corta',
  });

  @override
  State<CampoFecha> createState() => _CampoFechaState();
}

class _CampoFechaState extends State<CampoFecha> {
  late TextEditingController _controlador;
  DateTime? _fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = widget.valorInicial;
    _controlador = TextEditingController(
      text: _fechaSeleccionada != null 
          ? Formateadores.fecha(_fechaSeleccionada, formato: widget.formatoFecha)
          : '',
    );
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    if (!widget.habilitado) return;

    final DateTime ahora = DateTime.now();
    final DateTime fechaInicial = _fechaSeleccionada ?? ahora;
    final DateTime primeraFecha = widget.fechaMinima ?? DateTime(1900);
    final DateTime ultimaFecha = widget.fechaMaxima ?? DateTime(2100);

    final DateTime? fechaNueva = await showDatePicker(
      context: context,
      initialDate: fechaInicial.isBefore(primeraFecha) 
          ? primeraFecha 
          : fechaInicial.isAfter(ultimaFecha) 
              ? ultimaFecha 
              : fechaInicial,
      firstDate: primeraFecha,
      lastDate: ultimaFecha,
      initialDatePickerMode: widget.modoInicial,
      locale: const Locale('es', 'ES'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColoresApp.primario,
              onPrimary: ColoresApp.textoBlanco,
              surface: ColoresApp.fondoBlanco,
              onSurface: ColoresApp.textoNegro,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: ColoresApp.primario,
              ),
            ), dialogTheme: DialogThemeData(backgroundColor: ColoresApp.fondoBlanco),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false,
            ),
            child: child!,
          ),
        );
      },
    );

    if (fechaNueva != null && fechaNueva != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = fechaNueva;
        _controlador.text = Formateadores.fecha(_fechaSeleccionada, formato: widget.formatoFecha);
      });
      
      if (widget.onChanged != null) {
        widget.onChanged!(_fechaSeleccionada);
      }
    }
  }

  void _limpiarFecha() {
    if (!widget.habilitado) return;

    setState(() {
      _fechaSeleccionada = null;
      _controlador.text = '';
    });
    
    if (widget.onChanged != null) {
      widget.onChanged!(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CampoTexto(
      etiqueta: widget.etiqueta,
      placeholder: widget.placeholder,
      controlador: _controlador,
      habilitado: widget.habilitado,
      soloLectura: true,
      requerido: widget.requerido,
      onTap: _seleccionarFecha,
      iconoPrefijo: Icons.calendar_today,
      iconoSufijo: _fechaSeleccionada != null && widget.habilitado 
          ? Icons.clear 
          : Icons.arrow_drop_down,
      onIconoSufijoTap: _fechaSeleccionada != null && widget.habilitado 
          ? _limpiarFecha 
          : _seleccionarFecha,
      validador: widget.validador != null 
          ? (valor) => widget.validador!(_fechaSeleccionada)
          : null,
    );
  }
}