import 'package:flutter/material.dart';
import '../../../../compartidos/componentes/campo_texto.dart';
import '../../../../compartidos/utilidades/validadores.dart';

class CampoPassword extends StatefulWidget {
  final TextEditingController controlador;
  final FocusNode? focusNode;
  final Function(String)? onSubmitted;

  const CampoPassword({
    super.key,
    required this.controlador,
    this.focusNode,
    this.onSubmitted,
  });

  @override
  State<CampoPassword> createState() => _CampoPasswordState();
}

class _CampoPasswordState extends State<CampoPassword> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return CampoTexto(
      etiqueta: 'Contraseña',
      placeholder: 'Ingresa tu contraseña',
      controlador: widget.controlador,
      focusNode: widget.focusNode,
      iconoPrefijo: Icons.lock_outline,
      iconoSufijo: _passwordVisible ? Icons.visibility_off : Icons.visibility,
      onIconoSufijoTap: () {
        setState(() {
          _passwordVisible = !_passwordVisible;
        });
      },
      obscureText: !_passwordVisible,
      tipoTeclado: TextInputType.visiblePassword,
      accionTeclado: TextInputAction.done,
      validador: (valor) => Validadores.requerido(valor, campo: 'La contraseña'),
      onSubmitted: widget.onSubmitted,
      requerido: true,
    );
  }
}