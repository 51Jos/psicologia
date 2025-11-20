import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../compartidos/componentes/botones/boton_primario.dart';
import '../../../../compartidos/tema/colores_app.dart';

class FormularioRegistro extends StatefulWidget {
  final Function(String codigo, String password, String nombres, String apellidos, String? telefono) onRegistrar;
  final bool cargando;

  const FormularioRegistro({
    super.key,
    required this.onRegistrar,
    this.cargando = false,
  });

  @override
  State<FormularioRegistro> createState() => _FormularioRegistroState();
}

class _FormularioRegistroState extends State<FormularioRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmarPassword = true;

  @override
  void dispose() {
    _codigoController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onRegistrar(
        _codigoController.text.trim(),
        _passwordController.text,
        _nombresController.text.trim(),
        _apellidosController.text.trim(),
        _telefonoController.text.trim().isNotEmpty ? _telefonoController.text.trim() : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Código de Estudiante
          TextFormField(
            controller: _codigoController,
            decoration: InputDecoration(
              labelText: 'Código de Estudiante',
              hintText: 'Ejemplo: 2018102435',
              prefixIcon: Icon(Icons.badge_outlined, color: ColoresApp.secundario),
              suffixText: '@ucss.pe',
              suffixStyle: TextStyle(
                color: ColoresApp.secundario,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El código es requerido';
              }
              if (value.trim().length < 8) {
                return 'El código debe tener al menos 8 dígitos';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Nombres
          TextFormField(
            controller: _nombresController,
            decoration: InputDecoration(
              labelText: 'Nombres',
              hintText: 'Ingresa tus nombres',
              prefixIcon: Icon(Icons.person_outline, color: ColoresApp.secundario),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Los nombres son requeridos';
              }
              if (value.trim().length < 2) {
                return 'Ingresa un nombre válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Apellidos
          TextFormField(
            controller: _apellidosController,
            decoration: InputDecoration(
              labelText: 'Apellidos',
              hintText: 'Ingresa tus apellidos',
              prefixIcon: Icon(Icons.people_outline, color: ColoresApp.secundario),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Los apellidos son requeridos';
              }
              if (value.trim().length < 2) {
                return 'Ingresa un apellido válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Teléfono (Opcional)
          TextFormField(
            controller: _telefonoController,
            decoration: InputDecoration(
              labelText: 'Teléfono (Opcional)',
              hintText: 'Ejemplo: 987654321',
              prefixIcon: Icon(Icons.phone_outlined, color: ColoresApp.secundario),
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                if (value.trim().length != 9) {
                  return 'El teléfono debe tener 9 dígitos';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Contraseña
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              hintText: 'Mínimo 6 caracteres',
              prefixIcon: Icon(Icons.lock_outline, color: ColoresApp.secundario),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: ColoresApp.textoGris,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La contraseña es requerida';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirmar Contraseña
          TextFormField(
            controller: _confirmarPasswordController,
            obscureText: _obscureConfirmarPassword,
            decoration: InputDecoration(
              labelText: 'Confirmar Contraseña',
              hintText: 'Repite tu contraseña',
              prefixIcon: Icon(Icons.lock_open_outlined, color: ColoresApp.secundario),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmarPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: ColoresApp.textoGris,
                ),
                onPressed: () {
                  setState(() => _obscureConfirmarPassword = !_obscureConfirmarPassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirma tu contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Información adicional
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColoresApp.secundario.withValues(alpha: 0.1),
                  ColoresApp.secundarioClaro.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColoresApp.secundario.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: ColoresApp.secundario,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tu correo será: ${_codigoController.text.isNotEmpty ? "${_codigoController.text}@ucss.pe" : "codigo@ucss.pe"}',
                    style: TextStyle(
                      fontSize: 13,
                      color: ColoresApp.secundarioOscuro,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Botón de Registro
          BotonPrimario(
            texto: 'Crear Cuenta',
            onPressed: widget.cargando ? null : _submitForm,
            cargando: widget.cargando,
            icono: Icons.person_add,
            expandir: true,
          ),
        ],
      ),
    );
  }
}
