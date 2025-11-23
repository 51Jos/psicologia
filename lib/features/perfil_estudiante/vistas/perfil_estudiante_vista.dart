import 'package:flutter/material.dart';
import '../../../compartidos/componentes/campo_texto.dart';
import '../../../compartidos/componentes/campo_fecha.dart';
import '../../../compartidos/componentes/campo_selector.dart';
import '../../../compartidos/componentes/botones/boton_primario.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../../citas/modelos/estudiante_modelo.dart';
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
  final _codigoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _cicloController = TextEditingController();

  // Controladores de contraseña
  final _contrasenaActualController = TextEditingController();
  final _nuevaContrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();

  // Variables de estado
  String? _facultadSeleccionada;
  String? _programaSeleccionado;
  DateTime? _fechaNacimiento;
  String? _generoSeleccionado;
  bool _cargando = true;
  bool _guardando = false;
  bool _cambiandoContrasena = false;
  bool _mostrarCambioContrasena = false;

  // Programas académicos por facultad - UCSS Nueva Cajamarca
  final Map<String, List<OpcionSelector<String>>> _programasPorFacultad = {
    'FC': [
      OpcionSelector(valor: 'Biología', etiqueta: 'Biología'),
      OpcionSelector(valor: 'Matemática', etiqueta: 'Matemática'),
    ],
    'FCS': [
      OpcionSelector(valor: 'Enfermería', etiqueta: 'Enfermería'),
      OpcionSelector(valor: 'Psicología', etiqueta: 'Psicología'),
      OpcionSelector(valor: 'Obstetricia', etiqueta: 'Obstetricia'),
    ],
    'FEI': [
      OpcionSelector(valor: 'Ingeniería Civil', etiqueta: 'Ingeniería Civil'),
      OpcionSelector(valor: 'Ingeniería de Sistemas', etiqueta: 'Ingeniería de Sistemas'),
      OpcionSelector(valor: 'Ingeniería Agrónoma', etiqueta: 'Ingeniería Agrónoma'),
      OpcionSelector(valor: 'Ingeniería Ambiental', etiqueta: 'Ingeniería Ambiental'),
    ],
    'FCE': [
      OpcionSelector(valor: 'Administración', etiqueta: 'Administración'),
      OpcionSelector(valor: 'Contabilidad', etiqueta: 'Contabilidad'),
      OpcionSelector(valor: 'Economía', etiqueta: 'Economía'),
    ],
    'FD': [
      OpcionSelector(valor: 'Derecho', etiqueta: 'Derecho'),
    ],
  };

  EstudianteModelo? _estudiante;

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
    _codigoController.dispose();
    _direccionController.dispose();
    _cicloController.dispose();
    _contrasenaActualController.dispose();
    _nuevaContrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  Future<void> _cargarPerfil() async {
    setState(() => _cargando = true);

    final estudiante = await _perfilServicio.obtenerPerfilActual();

    if (estudiante != null) {
      setState(() {
        _estudiante = estudiante;
        _nombresController.text = estudiante.nombres;
        _apellidosController.text = estudiante.apellidos;
        _emailController.text = estudiante.email;
        _telefonoController.text = estudiante.telefono ?? '';
        _codigoController.text = estudiante.codigo ?? '';
        _direccionController.text = estudiante.direccion ?? '';
        _cicloController.text = estudiante.ciclo ?? '';
        _facultadSeleccionada = estudiante.facultad;
        _programaSeleccionado = estudiante.programa;
        _fechaNacimiento = estudiante.fechaNacimiento;
        _generoSeleccionado = estudiante.genero;
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

    final estudianteActualizado = EstudianteModelo(
      id: _estudiante!.id,
      codigo: _codigoController.text,
      nombres: _nombresController.text,
      apellidos: _apellidosController.text,
      email: _estudiante!.email, // Email no se puede cambiar
      telefono: _telefonoController.text,
      facultad: _facultadSeleccionada ?? '',
      programa: _programaSeleccionado ?? '',
      ciclo: _cicloController.text,
      fechaNacimiento: _fechaNacimiento,
      genero: _generoSeleccionado,
      direccion: _direccionController.text,
      fechaRegistro: _estudiante!.fechaRegistro,
      activo: _estudiante!.activo,
      totalCitas: _estudiante!.totalCitas,
      totalAtenciones: _estudiante!.totalAtenciones,
    );

    final exito = await _perfilServicio.actualizarPerfil(estudianteActualizado);

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
                  constraints: const BoxConstraints(maxWidth: 1000),
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
                _estudiante != null
                    ? '${_estudiante!.nombres[0]}${_estudiante!.apellidos[0]}'
                    : '??',
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
                    _estudiante != null
                        ? '${_estudiante!.nombres} ${_estudiante!.apellidos}'
                        : 'Cargando...',
                    style: TextStyle(
                      fontSize: esMovil ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.textoNegro,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _estudiante?.email ?? '',
                    style: TextStyle(
                      fontSize: esMovil ? 14 : 16,
                      color: ColoresApp.textoGris,
                    ),
                  ),
                  if (_estudiante?.codigo != null && _estudiante!.codigo.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Código: ${_estudiante!.codigo}',
                      style: TextStyle(
                        fontSize: esMovil ? 13 : 15,
                        color: ColoresApp.textoGris,
                      ),
                    ),
                  ],
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
                iconoPrefijo: Icons.lock,
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

              // Teléfono y Código
              if (esMovil) ...[
                CampoTexto(
                  controlador: _telefonoController,
                  etiqueta: 'Teléfono',
                  placeholder: 'Ingresa tu teléfono',
                  tipoTeclado: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  controlador: _codigoController,
                  etiqueta: 'Código de estudiante',
                  placeholder: 'Código',
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: CampoTexto(
                        controlador: _telefonoController,
                        etiqueta: 'Teléfono',
                        placeholder: 'Ingresa tu teléfono',
                        tipoTeclado: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CampoTexto(
                        controlador: _codigoController,
                        etiqueta: 'Código de estudiante',
                        placeholder: 'Código',
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Facultad y Programa
              if (esMovil) ...[
                CampoSelector<String>(
                  key: ValueKey(_facultadSeleccionada),
                  etiqueta: 'Facultad',
                  requerido: true,
                  valorInicial: _facultadSeleccionada,
                  opciones: [
                    OpcionSelector(valor: 'FC', etiqueta: 'Ciencias'),
                    OpcionSelector(valor: 'FCS', etiqueta: 'Ciencias de la Salud'),
                    OpcionSelector(valor: 'FEI', etiqueta: 'Ingeniería'),
                    OpcionSelector(valor: 'FCE', etiqueta: 'Ciencias Económicas'),
                    OpcionSelector(valor: 'FD', etiqueta: 'Derecho'),
                  ],
                  onChanged: (valor) {
                    setState(() {
                      _facultadSeleccionada = valor;
                      _programaSeleccionado = null;
                    });
                  },
                  validador: (valor) {
                    if (valor == null) {
                      return 'La facultad es requerida';
                    }
                    return null;
                  },
                ),
              ] else
                CampoSelector<String>(
                  key: ValueKey(_facultadSeleccionada),
                  etiqueta: 'Facultad',
                  requerido: true,
                  valorInicial: _facultadSeleccionada,
                  opciones: [
                    OpcionSelector(valor: 'FC', etiqueta: 'Facultad de Ciencias'),
                    OpcionSelector(valor: 'FCS', etiqueta: 'Facultad de Ciencias de la Salud'),
                    OpcionSelector(valor: 'FEI', etiqueta: 'Facultad de Ingeniería'),
                    OpcionSelector(valor: 'FCE', etiqueta: 'Facultad de Ciencias Económicas'),
                    OpcionSelector(valor: 'FD', etiqueta: 'Facultad de Derecho'),
                  ],
                  onChanged: (valor) {
                    setState(() {
                      _facultadSeleccionada = valor;
                      _programaSeleccionado = null;
                    });
                  },
                  validador: (valor) {
                    if (valor == null) {
                      return 'La facultad es requerida';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),

              // Programa Académico
              if (_facultadSeleccionada != null && _programasPorFacultad.containsKey(_facultadSeleccionada))
                CampoSelector<String>(
                  key: ValueKey('$_facultadSeleccionada-$_programaSeleccionado'),
                  etiqueta: 'Programa Académico',
                  requerido: true,
                  valorInicial: _programaSeleccionado,
                  opciones: _programasPorFacultad[_facultadSeleccionada]!,
                  onChanged: (valor) {
                    setState(() {
                      _programaSeleccionado = valor;
                    });
                  },
                  validador: (valor) {
                    if (valor == null) {
                      return 'El programa es requerido';
                    }
                    return null;
                  },
                )
              else
                CampoTexto(
                  etiqueta: 'Programa Académico',
                  requerido: true,
                  placeholder: 'Primero selecciona una facultad',
                  habilitado: false,
                ),
              const SizedBox(height: 16),

              // Ciclo y Fecha de Nacimiento
              if (esMovil) ...[
                CampoTexto(
                  controlador: _cicloController,
                  etiqueta: 'Ciclo',
                  placeholder: 'Ej: V',
                ),
                const SizedBox(height: 16),
                CampoFecha(
                  etiqueta: 'Fecha de Nacimiento',
                  valorInicial: _fechaNacimiento,
                  fechaMaxima: DateTime.now(),
                  onChanged: (fecha) {
                    setState(() {
                      _fechaNacimiento = fecha;
                    });
                  },
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: CampoTexto(
                        controlador: _cicloController,
                        etiqueta: 'Ciclo',
                        placeholder: 'Ej: V',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CampoFecha(
                        etiqueta: 'Fecha de Nacimiento',
                        valorInicial: _fechaNacimiento,
                        fechaMaxima: DateTime.now(),
                        onChanged: (fecha) {
                          setState(() {
                            _fechaNacimiento = fecha;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Género y Dirección
              if (esMovil) ...[
                CampoSelector<String>(
                  etiqueta: 'Género',
                  valorInicial: _generoSeleccionado,
                  opciones: [
                    OpcionSelector(valor: 'M', etiqueta: 'Masculino'),
                    OpcionSelector(valor: 'F', etiqueta: 'Femenino'),
                    OpcionSelector(valor: 'O', etiqueta: 'Otro'),
                  ],
                  onChanged: (valor) {
                    setState(() {
                      _generoSeleccionado = valor;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  controlador: _direccionController,
                  etiqueta: 'Dirección',
                  placeholder: 'Ingresa tu dirección',
                  lineasMax: 2,
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: CampoSelector<String>(
                        etiqueta: 'Género',
                        valorInicial: _generoSeleccionado,
                        opciones: [
                          OpcionSelector(valor: 'M', etiqueta: 'Masculino'),
                          OpcionSelector(valor: 'F', etiqueta: 'Femenino'),
                          OpcionSelector(valor: 'O', etiqueta: 'Otro'),
                        ],
                        onChanged: (valor) {
                          setState(() {
                            _generoSeleccionado = valor;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CampoTexto(
                        controlador: _direccionController,
                        etiqueta: 'Dirección',
                        placeholder: 'Ingresa tu dirección',
                        lineasMax: 2,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

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
