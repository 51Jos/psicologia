import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controladores/auth_controlador.dart';
import '../componentes/login/login_fondo.dart';
import '../componentes/login/login_card.dart';

class LoginVista extends StatelessWidget {
  const LoginVista({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthControlador(),
      child: Scaffold(
        body: LoginFondo(
          child: const LoginCard(),
        ),
      ),
    );
  }
}