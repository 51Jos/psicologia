import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../autenticacion/controladores/auth_controlador.dart';
import '../../autenticacion/servicios/auth_servicio.dart';
import '../componentes/formulario_perfil.dart';
import '../../../compartidos/componentes/layout/cabecera_pagina.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../../../compartidos/componentes/botones/boton_secundario.dart';

class PerfilVista extends StatefulWidget {
  const PerfilVista({super.key});

  @override
  State<PerfilVista> createState() => _PerfilVistaState();
}

class _PerfilVistaState extends State<PerfilVista> {
  final _authServicio = AuthServicio();
  bool _cargando = false;

  Future<void> _guardarPerfil(
    String nombres,
    String apellidos,
    String? telefono,
    String? especialidad,
  ) async {
    final authControlador = context.read<AuthControlador>();
    final usuario = authControlador.usuarioActual;

    if (usuario == null) return;

    setState(() => _cargando = true);

    try {
      final exito = await _authServicio.actualizarPerfilPsicologo(
        userId: usuario.id,
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
        especialidad: especialidad,
      );

      if (exito) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );

          // Recargar el usuario
          await authControlador.cerrarSesion(context);
        }
      } else {
        throw Exception('Error al actualizar perfil');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _cambiarContrasena() async {
    final TextEditingController actualController = TextEditingController();
    final TextEditingController nuevaController = TextEditingController();
    final TextEditingController confirmarController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: actualController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña Actual',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu contraseña actual';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nuevaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva Contraseña',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa la nueva contraseña';
                  }
                  if (value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmarController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  prefixIcon: Icon(Icons.lock_clock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != nuevaController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await _authServicio.cambiarPassword(
                    actualController.text,
                    nuevaController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );

    if (resultado == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña cambiada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authControlador = Provider.of<AuthControlador>(context);
    final usuario = authControlador.usuarioActual;

    if (usuario == null) {
      return const Scaffold(
        body: Center(
          child: Text('Usuario no autenticado'),
        ),
      );
    }

    final bool perfilIncompleto = usuario.nombres.isEmpty || usuario.apellidos.isEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          CabeceraPagina(
            titulo: perfilIncompleto ? 'Completa tu Perfil' : 'Mi Perfil',
            subtitulo: usuario.email,
            acciones: perfilIncompleto
                ? null
                : [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      color: Colors.white,
                      onPressed: () async {
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Cerrar Sesión'),
                            content: const Text('¿Estás seguro que deseas cerrar sesión?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Cerrar Sesión'),
                              ),
                            ],
                          ),
                        );

                        if (confirmar == true && mounted) {
                          await authControlador.cerrarSesion(context);
                        }
                      },
                      tooltip: 'Cerrar Sesión',
                    ),
                  ],
          ),

          // Contenido
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (perfilIncompleto) ...[
                        Card(
                          color: ColoresApp.advertencia.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: ColoresApp.advertencia),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Por favor completa tu información de perfil para continuar',
                                    style: TextStyle(
                                      color: ColoresApp.advertencia,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Formulario de Perfil
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Información Personal',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 24),
                              FormularioPerfil(
                                nombresIniciales: usuario.nombres,
                                apellidosIniciales: usuario.apellidos,
                                telefonoInicial: usuario.telefono,
                                especialidadInicial: usuario.especialidad,
                                onGuardar: _guardarPerfil,
                                cargando: _cargando,
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (!perfilIncompleto) ...[
                        const SizedBox(height: 24),

                        // Opción de cambiar contraseña
                        Card(
                          elevation: 2,
                          child: ListTile(
                            leading: Icon(Icons.lock, color: ColoresApp.primario),
                            title: const Text('Cambiar Contraseña'),
                            subtitle: const Text('Actualiza tu contraseña de acceso'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _cambiarContrasena,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Botón de cerrar sesión (alternativo)
                        BotonSecundario(
                          texto: 'Cerrar Sesión',
                          icono: Icons.logout,
                          onPressed: () async {
                            final confirmar = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Cerrar Sesión'),
                                content: const Text('¿Estás seguro que deseas cerrar sesión?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Cerrar Sesión'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmar == true && mounted) {
                              await authControlador.cerrarSesion(context);
                            }
                          },
                          colorBorde: Colors.red,
                          colorTexto: Colors.red,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
