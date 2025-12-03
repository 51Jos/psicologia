import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/autenticacion/controladores/auth_controlador.dart';
import '../../features/autenticacion/estados/auth_estado.dart';
import '../../features/autenticacion/modelos/usuario.dart';

/// Widget que envuelve las rutas protegidas y verifica la autenticación
class AuthWrapper extends StatelessWidget {
  final Widget child;
  final List<TipoUsuario> rolesPermitidos;

  const AuthWrapper({
    super.key,
    required this.child,
    this.rolesPermitidos = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthControlador>(
      builder: (context, authControlador, _) {
        // Verificar estado de autenticación
        if (authControlador.estado is AuthCargando) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si no está autenticado, mostrar vista de no autorizado
        if (!authControlador.estaAutenticado || authControlador.usuarioActual == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sesión expirada o no autorizado',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/',
                        (route) => false,
                      );
                    },
                    child: const Text('Ir al login'),
                  ),
                ],
              ),
            ),
          );
        }

        // Verificar roles si están especificados
        if (rolesPermitidos.isNotEmpty) {
          final usuario = authControlador.usuarioActual!;
          bool tienePermiso = false;

          for (final rol in rolesPermitidos) {
            switch (rol) {
              case TipoUsuario.administrador:
                if (usuario.esAdministrador) tienePermiso = true;
                break;
              case TipoUsuario.psicologo:
                if (usuario.esPsicologo) tienePermiso = true;
                break;
              case TipoUsuario.estudiante:
                if (usuario.esEstudiante) tienePermiso = true;
                break;
            }
          }

          if (!tienePermiso) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No tienes permisos para acceder a esta sección',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/',
                          (route) => false,
                        );
                      },
                      child: const Text('Volver al inicio'),
                    ),
                  ],
                ),
              ),
            );
          }
        }

        // Usuario autenticado y con permisos
        return child;
      },
    );
  }
}

/// Widget específico para rutas de psicólogo/admin
class PsicologoAuthWrapper extends StatelessWidget {
  final Widget child;

  const PsicologoAuthWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      rolesPermitidos: const [
        TipoUsuario.psicologo,
        TipoUsuario.administrador,
      ],
      child: child,
    );
  }
}

/// Widget específico para rutas de estudiante
class EstudianteAuthWrapper extends StatelessWidget {
  final Widget child;

  const EstudianteAuthWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      rolesPermitidos: const [
        TipoUsuario.estudiante,
      ],
      child: child,
    );
  }
}
