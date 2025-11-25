import 'package:flutter/material.dart';
import '../../../compartidos/componentes/campo_texto.dart';
import '../../../compartidos/componentes/botones/boton_primario.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../../autenticacion/modelos/usuario.dart';
import '../servicios/perfil_servicio.dart';

class PerfilEstudianteVista extends StatefulWidget {
  const PerfilEstudianteVista({super.key});

  @override
  State<PerfilEstudianteVista> createState() => _PerfilEstudianteVistaState();
}

class _PerfilEstudianteVistaState extends State<PerfilEstudianteVista> {
  final _perfilServicio = PerfilServicio();
  final _formKey = GlobalKey<FormState>();
  final _contrasenaFormKey = GlobalKey<FormState>();

  // Controladores de perfil
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();

  // Estado para facultad y programa
  String? _facultadSeleccionada;
  String? _programaSeleccionado;

  // Programas por facultad - UCSS Nueva Cajamarca
  final Map<String, List<Map<String, String>>> _programasPorFacultad = {
    'FC': [
      {'valor': 'Biología', 'nombre': 'Biología'},
      {'valor': 'Matemática', 'nombre': 'Matemática'},
    ],
    'FCS': [
      {'valor': 'Enfermería', 'nombre': 'Enfermería'},
      {'valor': 'Psicología', 'nombre': 'Psicología'},
      {'valor': 'Obstetricia', 'nombre': 'Obstetricia'},
    ],
    'FEI': [
      {'valor': 'Ingeniería Civil', 'nombre': 'Ingeniería Civil'},
      {'valor': 'Ingeniería de Sistemas', 'nombre': 'Ingeniería de Sistemas'},
      {'valor': 'Ingeniería Agrónoma', 'nombre': 'Ingeniería Agrónoma'},
      {'valor': 'Ingeniería Ambiental', 'nombre': 'Ingeniería Ambiental'},
    ],
    'FCE': [
      {'valor': 'Administración', 'nombre': 'Administración'},
      {'valor': 'Contabilidad', 'nombre': 'Contabilidad'},
      {'valor': 'Economía', 'nombre': 'Economía'},
    ],
    'FD': [
      {'valor': 'Derecho', 'nombre': 'Derecho'},
    ],
  };

  // Controladores de contraseña
  final _contrasenaActualController = TextEditingController();
  final _nuevaContrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();

  // Variables de estado
  bool _cargando = true;
  bool _guardando = false;
  bool _cambiandoContrasena = false;
  bool _mostrarCambioContrasena = false;

  UsuarioModelo? _usuario;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _contrasenaActualController.dispose();
    _nuevaContrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  Future<void> _cargarPerfil() async {
    setState(() => _cargando = true);

    final usuario = await _perfilServicio.obtenerPerfilActual();

    if (usuario != null) {
      setState(() {
        _usuario = usuario;
        _nombresController.text = usuario.nombres;
        _apellidosController.text = usuario.apellidos;
        _emailController.text = usuario.email;
        _telefonoController.text = usuario.telefono ?? '';
        _facultadSeleccionada = usuario.facultad;
        _programaSeleccionado = usuario.programa;
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar el perfil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _guardarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final usuarioActualizado = _usuario!.copyWith(
      nombres: _nombresController.text,
      apellidos: _apellidosController.text,
      telefono: _telefonoController.text.isEmpty ? null : _telefonoController.text,
      facultad: _facultadSeleccionada,
      programa: _programaSeleccionado,
    );

    final exito = await _perfilServicio.actualizarPerfil(usuarioActualizado);

    setState(() => _guardando = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            exito
                ? '✓ Perfil actualizado correctamente'
                : '✗ Error al actualizar el perfil',
          ),
          backgroundColor: exito ? Colors.green : Colors.red,
        ),
      );

      if (exito) {
        _cargarPerfil(); // Recargar para ver los cambios
      }
    }
  }

  Future<void> _cambiarContrasena() async {
    if (!_contrasenaFormKey.currentState!.validate()) return;

    setState(() => _cambiandoContrasena = true);

    final resultado = await _perfilServicio.cambiarContrasena(
      contrasenaActual: _contrasenaActualController.text,
      nuevaContrasena: _nuevaContrasenaController.text,
    );

    setState(() => _cambiandoContrasena = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['mensaje']),
          backgroundColor: resultado['exito'] ? Colors.green : Colors.red,
        ),
      );

      if (resultado['exito']) {
        // Limpiar campos
        _contrasenaActualController.clear();
        _nuevaContrasenaController.clear();
        _confirmarContrasenaController.clear();
        setState(() => _mostrarCambioContrasena = false);
      }
    }
  }

  String _obtenerNombreFacultad(String codigo) {
    switch (codigo) {
      case 'FC':
        return 'Facultad de Ciencias';
      case 'FCS':
        return 'Facultad de Ciencias de la Salud';
      case 'FEI':
        return 'Facultad de Ingeniería';
      case 'FCE':
        return 'Facultad de Ciencias Económicas';
      case 'FD':
        return 'Facultad de Derecho';
      default:
        return codigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final esMovil = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: ColoresApp.fondoSecundario,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: ColoresApp.primario,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(esMovil ? 16 : 24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Información del perfil
                      _buildSeccionInformacion(esMovil),
                      const SizedBox(height: 24),

                      // Formulario de datos personales
                      _buildFormularioPerfil(esMovil),
                      const SizedBox(height: 24),

                      // Sección de cambio de contraseña
                      _buildSeccionContrasena(esMovil),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSeccionInformacion(bool esMovil) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              radius: esMovil ? 40 : 50,
              backgroundColor: ColoresApp.primario,
              child: Text(
                _usuario != null ? _usuario!.iniciales : '??',
                style: TextStyle(
                  fontSize: esMovil ? 32 : 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _usuario != null ? _usuario!.nombreCompleto : 'Cargando...',
                    style: TextStyle(
                      fontSize: esMovil ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.textoNegro,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _usuario?.email ?? '',
                    style: TextStyle(
                      fontSize: esMovil ? 14 : 16,
                      color: ColoresApp.textoGris,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ColoresApp.primario.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Estudiante',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColoresApp.primario,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioPerfil(bool esMovil) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: ColoresApp.primario),
                  const SizedBox(width: 8),
                  Text(
                    'Datos Personales',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nombres y Apellidos
              if (esMovil) ...[
                CampoTexto(
                  controlador: _nombresController,
                  etiqueta: 'Nombres',
                  requerido: true,
                  placeholder: 'Ingresa tus nombres',
                  iconoPrefijo: Icons.person_outline,
                  validador: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Los nombres son requeridos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  controlador: _apellidosController,
                  etiqueta: 'Apellidos',
                  requerido: true,
                  placeholder: 'Ingresa tus apellidos',
                  iconoPrefijo: Icons.person_outline,
                  validador: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Los apellidos son requeridos';
                    }
                    return null;
                  },
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: CampoTexto(
                        controlador: _nombresController,
                        etiqueta: 'Nombres',
                        requerido: true,
                        placeholder: 'Ingresa tus nombres',
                        iconoPrefijo: Icons.person_outline,
                        validador: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Los nombres son requeridos';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CampoTexto(
                        controlador: _apellidosController,
                        etiqueta: 'Apellidos',
                        requerido: true,
                        placeholder: 'Ingresa tus apellidos',
                        iconoPrefijo: Icons.person_outline,
                        validador: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Los apellidos son requeridos';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Email (solo lectura)
              CampoTexto(
                controlador: _emailController,
                etiqueta: 'Email',
                placeholder: 'Email',
                habilitado: false,
                iconoPrefijo: Icons.email,
              ),
              const SizedBox(height: 4),
              Text(
                'El email no se puede modificar',
                style: TextStyle(
                  fontSize: 12,
                  color: ColoresApp.textoGris,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),

              // Teléfono
              CampoTexto(
                controlador: _telefonoController,
                etiqueta: 'Teléfono',
                placeholder: 'Ingresa tu teléfono',
                tipoTeclado: TextInputType.phone,
                iconoPrefijo: Icons.phone,
              ),
              const SizedBox(height: 16),

              // Facultad - Editable si está vacía
              if (_usuario?.facultad == null)
                DropdownButtonFormField<String>(
                  value: _facultadSeleccionada,
                  decoration: InputDecoration(
                    labelText: 'Facultad',
                    hintText: 'Selecciona tu facultad',
                    prefixIcon: Icon(Icons.school_outlined, color: ColoresApp.primario),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'FC', child: Text('Facultad de Ciencias')),
                    DropdownMenuItem(value: 'FCS', child: Text('Facultad de Ciencias de la Salud')),
                    DropdownMenuItem(value: 'FEI', child: Text('Facultad de Ingeniería')),
                    DropdownMenuItem(value: 'FCE', child: Text('Facultad de Ciencias Económicas')),
                    DropdownMenuItem(value: 'FD', child: Text('Facultad de Derecho')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _facultadSeleccionada = value;
                      _programaSeleccionado = null; // Reset programa cuando cambia facultad
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La facultad es requerida';
                    }
                    return null;
                  },
                )
              else
                TextFormField(
                  initialValue: _obtenerNombreFacultad(_usuario!.facultad!),
                  decoration: const InputDecoration(
                    labelText: 'Facultad',
                    prefixIcon: Icon(Icons.school),
                  ),
                  enabled: false,
                  style: TextStyle(color: ColoresApp.textoGris),
                ),
              const SizedBox(height: 4),
              Text(
                _usuario?.facultad != null
                  ? 'La facultad no se puede modificar'
                  : 'Selecciona tu facultad',
                style: TextStyle(
                  fontSize: 12,
                  color: ColoresApp.textoGris,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),

              // Programa - Editable si está vacío
              if (_usuario?.programa == null)
                DropdownButtonFormField<String>(
                  value: _programaSeleccionado,
                  decoration: InputDecoration(
                    labelText: 'Programa Académico',
                    hintText: _facultadSeleccionada == null
                      ? 'Primero selecciona una facultad'
                      : 'Selecciona tu programa',
                    prefixIcon: Icon(Icons.menu_book_outlined, color: ColoresApp.primario),
                  ),
                  items: _facultadSeleccionada == null
                    ? []
                    : _programasPorFacultad[_facultadSeleccionada]!
                        .map((programa) => DropdownMenuItem<String>(
                              value: programa['valor'],
                              child: Text(programa['nombre']!),
                            ))
                        .toList(),
                  onChanged: _facultadSeleccionada == null
                    ? null
                    : (value) {
                        setState(() {
                          _programaSeleccionado = value;
                        });
                      },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El programa académico es requerido';
                    }
                    return null;
                  },
                )
              else
                TextFormField(
                  initialValue: _usuario!.programa,
                  decoration: const InputDecoration(
                    labelText: 'Programa Académico',
                    prefixIcon: Icon(Icons.menu_book),
                  ),
                  enabled: false,
                  style: TextStyle(color: ColoresApp.textoGris),
                ),
              const SizedBox(height: 4),
              Text(
                _usuario?.programa != null
                  ? 'El programa no se puede modificar'
                  : 'Selecciona tu programa académico',
                style: TextStyle(
                  fontSize: 12,
                  color: ColoresApp.textoGris,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 8),

              // Botón de guardar
              SizedBox(
                width: double.infinity,
                child: BotonPrimario(
                  texto: _guardando ? 'Guardando...' : 'Guardar Cambios',
                  onPressed: _guardando ? null : _guardarPerfil,
                  icono: Icons.save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeccionContrasena(bool esMovil) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock, color: ColoresApp.primario),
                    const SizedBox(width: 8),
                    Text(
                      'Seguridad',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _mostrarCambioContrasena = !_mostrarCambioContrasena;
                      if (!_mostrarCambioContrasena) {
                        _contrasenaActualController.clear();
                        _nuevaContrasenaController.clear();
                        _confirmarContrasenaController.clear();
                      }
                    });
                  },
                  icon: Icon(
                    _mostrarCambioContrasena ? Icons.cancel : Icons.edit,
                  ),
                  label: Text(
                    _mostrarCambioContrasena ? 'Cancelar' : 'Cambiar Contraseña',
                  ),
                ),
              ],
            ),
            if (_mostrarCambioContrasena) ...[
              const SizedBox(height: 24),
              Form(
                key: _contrasenaFormKey,
                child: Column(
                  children: [
                    CampoTexto(
                      controlador: _contrasenaActualController,
                      etiqueta: 'Contraseña Actual',
                      requerido: true,
                      obscureText: true,
                      placeholder: 'Ingresa tu contraseña actual',
                      iconoPrefijo: Icons.lock_outline,
                      validador: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La contraseña actual es requerida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      controlador: _nuevaContrasenaController,
                      etiqueta: 'Nueva Contraseña',
                      requerido: true,
                      obscureText: true,
                      placeholder: 'Ingresa tu nueva contraseña',
                      iconoPrefijo: Icons.lock,
                      validador: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La nueva contraseña es requerida';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      controlador: _confirmarContrasenaController,
                      etiqueta: 'Confirmar Nueva Contraseña',
                      requerido: true,
                      obscureText: true,
                      placeholder: 'Confirma tu nueva contraseña',
                      iconoPrefijo: Icons.lock,
                      validador: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Debes confirmar la contraseña';
                        }
                        if (value != _nuevaContrasenaController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: BotonPrimario(
                        texto: _cambiandoContrasena
                            ? 'Cambiando...'
                            : 'Cambiar Contraseña',
                        onPressed:
                            _cambiandoContrasena ? null : _cambiarContrasena,
                        icono: Icons.security,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
