import 'package:flutter/material.dart';
import '../../../../compartidos/componentes/botones/boton_primario.dart';

class BotonLogin extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool cargando;

  const BotonLogin({
    super.key,
    this.onPressed,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    return BotonPrimario(
      texto: 'Iniciar Sesión',
      icono: Icons.login,
      onPressed: onPressed,
      cargando: cargando,
      expandir: true,
    );
  }
}