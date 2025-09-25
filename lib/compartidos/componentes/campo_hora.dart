import 'package:flutter/material.dart';
import '../tema/colores_app.dart';
import '../utilidades/formateadores.dart';
import 'campo_texto.dart';

class CampoHora extends StatefulWidget {
  final String? etiqueta;
  final String? placeholder;
  final TimeOfDay? valorInicial;
  final String? Function(TimeOfDay?)? validador;
  final void Function(TimeOfDay?)? onChanged;
  final bool habilitado;
  final bool requerido;
  final bool formato24Horas;

  const CampoHora({
    super.key,
    this.etiqueta,
    this.placeholder = 'Seleccionar hora',
    this.valorInicial,
    this.validador,
    this.onChanged,
    this.habilitado = true,
    this.requerido = false,
    this.formato24Horas = true,
  });

  @override
  State<CampoHora> createState() => _CampoHoraState();
}

class _CampoHoraState extends State<CampoHora> {
  late TextEditingController _controlador;
  TimeOfDay? _horaSeleccionada;

  @override
  void initState() {
    super.initState();
    _horaSeleccionada = widget.valorInicial;
    _controlador = TextEditingController(
      text: _formatearHora(_horaSeleccionada),
    );
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  String _formatearHora(TimeOfDay? hora) {
    if (hora == null) return '';
    
    final ahora = DateTime.now();
    final fechaHora = DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
      hora.hour,
      hora.minute,
    );
    
    return Formateadores.hora(fechaHora, formato24: widget.formato24Horas);
  }

  Future<void> _seleccionarHora() async {
    if (!widget.habilitado) return;

    final TimeOfDay horaInicial = _horaSeleccionada ?? TimeOfDay.now();

    final TimeOfDay? horaNueva = await showTimePicker(
      context: context,
      initialTime: horaInicial,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColoresApp.primario,
              onPrimary: ColoresApp.textoBlanco,
              surface: ColoresApp.fondoBlanco,
              onSurface: ColoresApp.textoNegro,
            ),
            dialogBackgroundColor: ColoresApp.fondoBlanco,
            timePickerTheme: TimePickerThemeData(
              backgroundColor: ColoresApp.fondoBlanco,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              hourMinuteTextColor: ColoresApp.textoNegro,
              dayPeriodTextColor: ColoresApp.textoNegro,
              dialHandColor: ColoresApp.primario,
              dialTextColor: ColoresApp.textoNegro,
              entryModeIconColor: ColoresApp.primario,
              helpTextStyle: const TextStyle(
                color: ColoresApp.textoGris,
                fontSize: 14,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: ColoresApp.primario,
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: widget.formato24Horas,
            ),
            child: child!,
          ),
        );
      },
    );

    if (horaNueva != null && horaNueva != _horaSeleccionada) {
      setState(() {
        _horaSeleccionada = horaNueva;
        _controlador.text = _formatearHora(_horaSeleccionada);
      });
      
      if (widget.onChanged != null) {
        widget.onChanged!(_horaSeleccionada);
      }
    }
  }

  void _limpiarHora() {
    if (!widget.habilitado) return;

    setState(() {
      _horaSeleccionada = null;
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
      onTap: _seleccionarHora,
      iconoPrefijo: Icons.access_time,
      iconoSufijo: _horaSeleccionada != null && widget.habilitado 
          ? Icons.clear 
          : Icons.arrow_drop_down,
      onIconoSufijoTap: _horaSeleccionada != null && widget.habilitado 
          ? _limpiarHora 
          : _seleccionarHora,
      validador: widget.validador != null 
          ? (valor) => widget.validador!(_horaSeleccionada)
          : null,
    );
  }
}