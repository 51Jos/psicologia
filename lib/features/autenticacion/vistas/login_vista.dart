import 'package:flutter/material.dart';
import '../componentes/login/login_fondo.dart';
import '../componentes/login/login_card.dart';

class LoginVista extends StatelessWidget {
  const LoginVista({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginFondo(
        child: const LoginCard(),
      ),
    );
  }
}