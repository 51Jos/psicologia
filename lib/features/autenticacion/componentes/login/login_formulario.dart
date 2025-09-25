import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../compartidos/utilidades/responsive_helper.dart';
import '../../controladores/auth_controlador.dart';
import 'login_cabecera.dart';
import 'campo_usuario.dart';
import 'campo_password.dart';
import 'recordar_checkbox.dart';
import 'boton_login.dart';

class LoginFormulario extends StatefulWidget {
  const LoginFormulario({super.key});

  @override
  State<LoginFormulario> createState() => _LoginFormularioState();
}

class _LoginFormularioState extends State<LoginFormulario> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usuarioFocus = FocusNode();
  final _passwordFocus = FocusNode();
  
  bool _recordarme = false;

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    _usuarioFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _iniciarSesion() {
    if (_formKey.currentState?.validate() ?? false) {
      final authControlador = context.read<AuthControlador>();
      
      authControlador.iniciarSesion(
        usuario: _usuarioController.text.trim(),
        password: _passwordController.text,
        recordarme: _recordarme,
        context: context,
      );
    }
  }

  void _mostrarRecuperarPassword() {
    showDialog(
      context: context,
      builder: (context) => _RecuperarPasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.esMobile(context);
    
    return Consumer<AuthControlador>(
      builder: (context, authControlador, _) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabecera
              const LoginCabecera(),
              
              SizedBox(
                height: ResponsiveHelper.valor(
                  context,
                  mobile: 32,
                  tablet: 40,
                  desktop: 48,
                ),
              ),
              
              // Campo Usuario
              CampoUsuario(
                controlador: _usuarioController,
                focusNode: _usuarioFocus,
                onSubmitted: (_) => _passwordFocus.requestFocus(),
              ),
              
              const SizedBox(height: 20),
              
              // Campo Contraseña
              CampoPassword(
                controlador: _passwordController,
                focusNode: _passwordFocus,
                onSubmitted: (_) => _iniciarSesion(),
              ),
              
              const SizedBox(height: 16),
              
              // Recordarme y Olvidaste contraseña
              RecordarCheckbox(
                valor: _recordarme,
                onChanged: (valor) {
                  setState(() {
                    _recordarme = valor ?? false;
                  });
                },
                onOlvidaste: _mostrarRecuperarPassword,
              ),
              
              const SizedBox(height: 24),
              
              // Botón Iniciar Sesión
              BotonLogin(
                onPressed: authControlador.estaCargando ? null : _iniciarSesion,
                cargando: authControlador.estaCargando,
              ),
            ],
          ),
        );
      },
    );
  }
}

// Diálogo para recuperar contraseña
class _RecuperarPasswordDialog extends StatefulWidget {
  @override
  State<_RecuperarPasswordDialog> createState() => __RecuperarPasswordDialogState();
}

class __RecuperarPasswordDialogState extends State<_RecuperarPasswordDialog> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _enviando = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _enviarRecuperacion() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _enviando = true);
      
      final authControlador = context.read<AuthControlador>();
      await authControlador.recuperarPassword(
        email: _emailController.text.trim(),
        context: context,
      );
      
      setState(() => _enviando = false);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text('Recuperar Contraseña'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                hintText: 'usuario@sistema.edu.pe',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (valor) {
                if (valor == null || valor.isEmpty) {
                  return 'Ingresa tu correo';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _enviando ? null : _enviarRecuperacion,
          child: _enviando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enviar'),
        ),
      ],
    );
  }
}