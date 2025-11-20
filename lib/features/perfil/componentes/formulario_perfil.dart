import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../compartidos/componentes/botones/boton_primario.dart';

class FormularioPerfil extends StatefulWidget {
  final String? nombresIniciales;
  final String? apellidosIniciales;
  final String? telefonoInicial;
  final String? especialidadInicial;
  final Function(String nombres, String apellidos, String? telefono, String? especialidad) onGuardar;
  final bool cargando;

  const FormularioPerfil({
    super.key,
    this.nombresIniciales,
    this.apellidosIniciales,
    this.telefonoInicial,
    this.especialidadInicial,
    required this.onGuardar,
    this.cargando = false,
  });

  @override
  State<FormularioPerfil> createState() => _FormularioPerfilState();
}

class _FormularioPerfilState extends State<FormularioPerfil> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombresController;
  late TextEditingController _apellidosController;
  late TextEditingController _telefonoController;
  late TextEditingController _especialidadController;

  @override
  void initState() {
    super.initState();
    _nombresController = TextEditingController(text: widget.nombresIniciales);
    _apellidosController = TextEditingController(text: widget.apellidosIniciales);
    _telefonoController = TextEditingController(text: widget.telefonoInicial);
    _especialidadController = TextEditingController(text: widget.especialidadInicial);
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _especialidadController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onGuardar(
        _nombresController.text.trim(),
        _apellidosController.text.trim(),
        _telefonoController.text.trim().isNotEmpty ? _telefonoController.text.trim() : null,
        _especialidadController.text.trim().isNotEmpty ? _especialidadController.text.trim() : null,
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
          // Nombres
          TextFormField(
            controller: _nombresController,
            decoration: InputDecoration(
              labelText: 'Nombres *',
              hintText: 'Ingresa tus nombres',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
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
              labelText: 'Apellidos *',
              hintText: 'Ingresa tus apellidos',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
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
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
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

          // Especialidad (Opcional)
          TextFormField(
            controller: _especialidadController,
            decoration: InputDecoration(
              labelText: 'Especialidad (Opcional)',
              hintText: 'Ejemplo: Psicología Clínica',
              prefixIcon: const Icon(Icons.school),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),

          // Botón Guardar
          BotonPrimario(
            texto: 'Guardar Perfil',
            onPressed: widget.cargando ? null : _submitForm,
            cargando: widget.cargando,
            icono: Icons.save,
            expandir: true,
          ),
        ],
      ),
    );
  }
}
