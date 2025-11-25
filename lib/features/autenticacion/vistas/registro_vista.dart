import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controladores/auth_controlador.dart';
import '../componentes/registro/formulario_registro.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../../../compartidos/utilidades/responsive_helper.dart';
import 'dart:ui';

class RegistroVista extends StatelessWidget {
  const RegistroVista({super.key});

  @override
  Widget build(BuildContext context) {
    final authControlador = Provider.of<AuthControlador>(context);
    final esMobile = ResponsiveHelper.esMobile(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: ColoresApp.gradienteLogin,
        ),
        child: Stack(
          children: [
            // Efectos de fondo decorativos
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ColoresApp.acento.withValues(alpha: 0.12),
                      ColoresApp.acento.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ),
            ),

            // Contenido principal
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(
                    ResponsiveHelper.valor(
                      context,
                      mobile: 16.0,
                      tablet: 24.0,
                      desktop: 32.0,
                    ),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveHelper.valor(
                        context,
                        mobile: double.infinity,
                        tablet: 550,
                        desktop: 600,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.valor(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        ),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.valor(
                                context,
                                mobile: 16,
                                tablet: 20,
                                desktop: 24,
                              ),
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                              ResponsiveHelper.valor(
                                context,
                                mobile: 24.0,
                                tablet: 32.0,
                                desktop: 40.0,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Botón de regresar
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Material(
                                    color: ColoresApp.secundario.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () => Navigator.pop(context),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.arrow_back,
                                          color: ColoresApp.secundario,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: esMobile ? 16 : 20),

                                // Logo o Icono
                                Center(
                                  child: Container(
                                    width: ResponsiveHelper.valor(
                                      context,
                                      mobile: 70,
                                      tablet: 80,
                                      desktop: 90,
                                    ),
                                    height: ResponsiveHelper.valor(
                                      context,
                                      mobile: 70,
                                      tablet: 80,
                                      desktop: 90,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: ColoresApp.gradienteDorado,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: ColoresApp.secundario.withValues(alpha: 0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.school_rounded,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(height: esMobile ? 20 : 24),

                                // Título
                                Text(
                                  'Registro de Estudiante',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: ColoresApp.textoNegro,
                                        fontSize: ResponsiveHelper.fontSize(
                                          context,
                                          base: 24,
                                        ),
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),

                                // Subtítulo
                                Text(
                                  'Crea tu cuenta con tu código de estudiante',
                                  style: TextStyle(
                                    color: ColoresApp.textoGris,
                                    fontSize: ResponsiveHelper.fontSize(
                                      context,
                                      base: 14,
                                    ),
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: esMobile ? 24 : 32),

                                // Formulario de Registro
                                FormularioRegistro(
                                  onRegistrar: (codigo, password, nombres, apellidos, telefono, facultad, programa) async {
                                    await authControlador.registrarEstudiante(
                                      context: context,
                                      codigo: codigo,
                                      password: password,
                                      nombres: nombres,
                                      apellidos: apellidos,
                                      telefono: telefono,
                                      facultad: facultad,
                                      programa: programa,
                                    );
                                  },
                                  cargando: authControlador.estaCargando,
                                ),
                                SizedBox(height: esMobile ? 20 : 24),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: ColoresApp.borde)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'o',
                                        style: TextStyle(
                                          color: ColoresApp.textoGrisClaro,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: ColoresApp.borde)),
                                  ],
                                ),
                                SizedBox(height: esMobile ? 20 : 24),

                                // Link para iniciar sesión
                                Center(
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: ResponsiveHelper.fontSize(
                                            context,
                                            base: 14,
                                          ),
                                          color: ColoresApp.textoGris,
                                        ),
                                        children: [
                                          const TextSpan(text: '¿Ya tienes cuenta? '),
                                          TextSpan(
                                            text: 'Inicia Sesión',
                                            style: TextStyle(
                                              color: ColoresApp.secundario,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
