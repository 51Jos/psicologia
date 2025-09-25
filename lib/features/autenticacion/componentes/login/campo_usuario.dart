import 'package:flutter/material.dart';
import '../../../../compartidos/componentes/campo_texto.dart';
import '../../../../compartidos/utilidades/validadores.dart';

class CampoUsuario extends StatelessWidget {
  final TextEditingController controlador;
  final FocusNode? focusNode;
  final Function(String)? onSubmitted;

  const CampoUsuario({
    Key? key,
    required this.controlador,
    this.focusNode,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CampoTexto(
      etiqueta: 'Usuario',
      placeholder: 'Ingresa tu usuario',
      controlador: controlador,
      focusNode: focusNode,
      iconoPrefijo: Icons.person_outline,
      tipoTeclado: TextInputType.emailAddress,
      accionTeclado: TextInputAction.next,
      validador: (valor) => Validadores.requerido(valor, campo: 'El usuario'),
      onSubmitted: onSubmitted,
      requerido: true,
    );
  }
}