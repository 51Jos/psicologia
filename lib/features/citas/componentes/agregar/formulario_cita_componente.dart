import 'package:flutter/material.dart';
import '../../modelos/cita_modelo.dart';
import '../../servicios/cita_servicio.dart';
import '../../../../compartidos/componentes/campo_texto.dart';
import '../../../../compartidos/componentes/campo_fecha.dart';
import '../../../../compartidos/componentes/campo_hora.dart';
import '../../../../compartidos/componentes/campo_selector.dart';
import '../../../../compartidos/componentes/campo_textarea.dart';
import '../../../../compartidos/componentes/botones/boton_secundario.dart';
import '../../../../compartidos/componentes/modal_carga.dart';
import '../../../../compartidos/tema/colores_app.dart';

class FormularioCitaComponente extends StatefulWidget {
  final CitaModelo? citaInicial;
  final Function(CitaModelo) onGuardar;
  final VoidCallback? onCancelar;

  const FormularioCitaComponente({
    super.key,
    this.citaInicial,
    required this.onGuardar,
    this.onCancelar,
  });

  @override
  State<FormularioCitaComponente> createState() => _FormularioCitaComponenteState();
}

class _FormularioCitaComponenteState extends State<FormularioCitaComponente> {
  final _formKey = GlobalKey<FormState>();
  final CitaServicio _citaServicio = CitaServicio();

  // Controladores de texto
  final _estudianteNombreController = TextEditingController();
  final _estudianteApellidosController = TextEditingController();
  final _estudianteCodigoController = TextEditingController();
  final _estudianteEmailController = TextEditingController();
  final _estudianteTelefonoController = TextEditingController();
  final _programaController = TextEditingController();
  final _motivoController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _psicologoIdController = TextEditingController();

  // Variables de estado
  String? _facultadSeleccionada;
  String? _programaSeleccionado;
  DuracionCita _duracionSeleccionada = DuracionCita.minutos45;
  TipoCita _tipoSeleccionado = TipoCita.presencial;
  EstadoCita _estadoSeleccionado = EstadoCita.programada;
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  bool _esPrimeraVez = true;

  bool _inicializado = false;
  List<Map<String, String>> _estudiantesRegistrados = [];
  List<Map<String, dynamic>> _horariosOcupados = [];
  bool _validandoHorario = false;
  String? _conflictoHorario;

  // Variable para almacenar el estudiante seleccionado del autocomplete
  Map<String, String>? _estudianteSeleccionado;

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

  @override
  void initState() {
    super.initState();
    _inicializarFormulario();
    _cargarEstudiantesRegistrados();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      _inicializado = true;
    }
  }

  // Método para actualizar los controladores con los datos del estudiante seleccionado
  void _actualizarDatosEstudiante(Map<String, String> estudiante) {
    _estudianteSeleccionado = estudiante;

    // Separar nombre y apellidos correctamente
    _estudianteNombreController.text = estudiante['nombre'] ?? '';
    _estudianteApellidosController.text = estudiante['apellidos'] ?? '';
    _estudianteEmailController.text = estudiante['email'] ?? '';
    _estudianteCodigoController.text = estudiante['codigo'] ?? '';
    _estudianteTelefonoController.text = estudiante['telefono'] ?? '';

    final programa = estudiante['programa'] ?? '';
    _programaController.text = programa;

    // Solo asignar la facultad si es una de las opciones válidas
    final facultad = estudiante['facultad'] ?? '';
    final facultadesValidas = ['FC', 'FCS', 'FEI', 'FCE', 'FD'];
    if (facultad.isNotEmpty && facultadesValidas.contains(facultad)) {
      _facultadSeleccionada = facultad;
      // Asignar el programa solo si está en la lista de esa facultad
      if (_programasPorFacultad.containsKey(facultad)) {
        final programasValidos = _programasPorFacultad[facultad]!
            .map((op) => op.valor)
            .toList();
        if (programa.isNotEmpty && programasValidos.contains(programa)) {
          _programaSeleccionado = programa;
        } else {
          _programaSeleccionado = null;
        }
      }
    } else {
      // Si no es válida, dejar como null para que el usuario la seleccione
      _facultadSeleccionada = null;
      _programaSeleccionado = null;
    }
  }

  Future<void> _cargarEstudiantesRegistrados() async {
    final estudiantes = await _citaServicio.obtenerEstudiantesUnicos();
    setState(() {
      _estudiantesRegistrados = estudiantes;
    });
  }

  Future<void> _cargarHorariosOcupados() async {
    if (_fechaSeleccionada == null) return;

    final psicologoId = _psicologoIdController.text.trim();
    if (psicologoId.isEmpty) return;

    setState(() {
      _validandoHorario = true;
    });

    final horarios = await _citaServicio.obtenerHorariosOcupados(
      psicologoId,
      _fechaSeleccionada!,
    );

    setState(() {
      _horariosOcupados = horarios;
      _validandoHorario = false;
    });

    // Validar el horario actual si ya hay uno seleccionado
    if (_horaSeleccionada != null) {
      _validarHorario();
    }
  }

  void _validarHorario() {
    if (_fechaSeleccionada == null || _horaSeleccionada == null) {
      setState(() {
        _conflictoHorario = null;
      });
      return;
    }

    final inicio = DateTime(
      _fechaSeleccionada!.year,
      _fechaSeleccionada!.month,
      _fechaSeleccionada!.day,
      _horaSeleccionada!.hour,
      _horaSeleccionada!.minute,
    );

    final fin = inicio.add(Duration(minutes: _duracionSeleccionada.minutos));

    // Buscar conflictos
    for (var horario in _horariosOcupados) {
      final ocupadoInicio = horario['inicio'] as DateTime;
      final ocupadoFin = horario['fin'] as DateTime;

      // Verificar solapamiento
      if (inicio.isBefore(ocupadoFin) && fin.isAfter(ocupadoInicio)) {
        setState(() {
          _conflictoHorario = 'Conflicto: Ya existe una cita de ${_formatearHora(ocupadoInicio)} a ${_formatearHora(ocupadoFin)} con ${horario['estudiante']}';
        });
        return;
      }
    }

    setState(() {
      _conflictoHorario = null;
    });
  }

  String _formatearHora(DateTime fecha) {
    return '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  void _inicializarFormulario() {
    final cita = widget.citaInicial;
    if (cita != null) {
      _estudianteNombreController.text = cita.estudianteNombre;
      _estudianteApellidosController.text = cita.estudianteApellidos;
      _estudianteCodigoController.text = cita.estudianteCodigo ?? '';
      _estudianteEmailController.text = cita.estudianteEmail ?? '';
      _estudianteTelefonoController.text = cita.estudianteTelefono ?? '';
      _programaController.text = cita.programa;
      _motivoController.text = cita.motivoConsulta;
      _observacionesController.text = cita.observaciones ?? '';
      _psicologoIdController.text = cita.psicologoId;

      _facultadSeleccionada = cita.facultad;
      _duracionSeleccionada = cita.duracion;
      _tipoSeleccionado = cita.tipoCita;
      _estadoSeleccionado = cita.estado;
      _fechaSeleccionada = cita.fechaHora;
      _horaSeleccionada = TimeOfDay.fromDateTime(cita.fechaHora);
      _esPrimeraVez = cita.primeraVez;
    } else {
      _psicologoIdController.text = 'default_psicologo';
      // Establecer fecha inicial evitando domingos
      DateTime fechaInicial = DateTime.now().add(const Duration(days: 1));
      while (fechaInicial.weekday == DateTime.sunday) {
        fechaInicial = fechaInicial.add(const Duration(days: 1));
      }
      _fechaSeleccionada = fechaInicial;
      _horaSeleccionada = const TimeOfDay(hour: 9, minute: 0);
    }
  }

  @override
  void dispose() {
    _estudianteNombreController.dispose();
    _estudianteApellidosController.dispose();
    _estudianteCodigoController.dispose();
    _estudianteEmailController.dispose();
    _estudianteTelefonoController.dispose();
    _programaController.dispose();
    _motivoController.dispose();
    _observacionesController.dispose();
    _psicologoIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esMovil = MediaQuery.of(context).size.width < 768;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del estudiante
          _buildSeccionTitulo('Información del Estudiante'),
          const SizedBox(height: 16),

          // Nombre y Apellidos - Responsive
          if (esMovil) ...[
            _buildAutocompleteNombre(),
            const SizedBox(height: 16),
            _buildAutocompleteApellidos(),
          ] else
            Row(
              children: [
                Expanded(
                  child: _buildAutocompleteNombre(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAutocompleteApellidos(),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Código y Facultad - Responsive
          if (esMovil) ...[
            CampoTexto(
              controlador: _estudianteCodigoController,
              etiqueta: 'Código de Estudiante',
            ),
            const SizedBox(height: 16),
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
                  // Resetear el programa cuando cambia la facultad
                  _programaSeleccionado = null;
                  _programaController.text = '';
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
            Row(
              children: [
                Expanded(
                  child: CampoTexto(
                    controlador: _estudianteCodigoController,
                    etiqueta: 'Código de Estudiante',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CampoSelector<String>(
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
                        // Resetear el programa cuando cambia la facultad
                        _programaSeleccionado = null;
                        _programaController.text = '';
                      });
                    },
                    validador: (valor) {
                      if (valor == null) {
                        return 'La facultad es requerida';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Programa Académico - dinámico según facultad
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
                  _programaController.text = valor ?? '';
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
              controlador: _programaController,
              etiqueta: 'Programa Académico',
              requerido: true,
              placeholder: 'Primero selecciona una facultad',
              habilitado: false,
              validador: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El programa es requerido';
                }
                return null;
              },
            ),

          const SizedBox(height: 16),

          // Email y Teléfono - Responsive
          if (esMovil) ...[
            CampoTexto(
              controlador: _estudianteEmailController,
              etiqueta: 'Email',
              tipoTeclado: TextInputType.emailAddress,
              validador: (value) {
                if (value != null && value.isNotEmpty) {
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Email inválido';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CampoTexto(
              controlador: _estudianteTelefonoController,
              etiqueta: 'Teléfono',
              tipoTeclado: TextInputType.phone,
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: CampoTexto(
                    controlador: _estudianteEmailController,
                    etiqueta: 'Email',
                    tipoTeclado: TextInputType.emailAddress,
                    validador: (value) {
                      if (value != null && value.isNotEmpty) {
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Email inválido';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CampoTexto(
                    controlador: _estudianteTelefonoController,
                    etiqueta: 'Teléfono',
                    tipoTeclado: TextInputType.phone,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 24),

          // Información de la cita
          _buildSeccionTitulo('Información de la Cita'),
          const SizedBox(height: 16),

          CampoTextarea(
            controlador: _motivoController,
            etiqueta: 'Motivo de Consulta',
            requerido: true,
            lineasMin: 3,
            lineasMax: 5,
            validador: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El motivo de consulta es requerido';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Fecha y Hora - Responsive
          if (esMovil) ...[
            CampoFecha(
              etiqueta: 'Fecha',
              requerido: true,
              valorInicial: _fechaSeleccionada,
              fechaMinima: DateTime.now(),
              fechaMaxima: DateTime.now().add(const Duration(days: 365)),
              onChanged: (fecha) {
                setState(() {
                  _fechaSeleccionada = fecha;
                });
                _cargarHorariosOcupados();
              },
              validador: (fecha) {
                if (fecha == null) {
                  return 'La fecha es requerida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CampoHora(
              etiqueta: 'Hora',
              requerido: true,
              valorInicial: _horaSeleccionada,
              onChanged: (hora) {
                setState(() {
                  _horaSeleccionada = hora;
                });
                _validarHorario();
              },
              validador: (hora) {
                if (hora == null) {
                  return 'La hora es requerida';
                }
                return null;
              },
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: CampoFecha(
                    etiqueta: 'Fecha',
                    requerido: true,
                    valorInicial: _fechaSeleccionada,
                    fechaMinima: DateTime.now(),
                    fechaMaxima: DateTime.now().add(const Duration(days: 365)),
                    onChanged: (fecha) {
                      setState(() {
                        _fechaSeleccionada = fecha;
                      });
                      _cargarHorariosOcupados();
                    },
                    validador: (fecha) {
                      if (fecha == null) {
                        return 'La fecha es requerida';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CampoHora(
                    etiqueta: 'Hora',
                    requerido: true,
                    valorInicial: _horaSeleccionada,
                    onChanged: (hora) {
                      setState(() {
                        _horaSeleccionada = hora;
                      });
                      _validarHorario();
                    },
                    validador: (hora) {
                      if (hora == null) {
                        return 'La hora es requerida';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Mensaje de conflicto de horario
          if (_conflictoHorario != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColoresApp.error),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: ColoresApp.error, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _conflictoHorario!,
                      style: const TextStyle(
                        color: Color(0xFF991B1B),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Indicador de carga al validar
          if (_validandoHorario)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFDEEBFF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColoresApp.primario.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Verificando disponibilidad de horarios...',
                    style: TextStyle(
                      color: ColoresApp.primario,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Tipo y Duración - Responsive
          if (esMovil) ...[
            CampoSelector<TipoCita>(
              etiqueta: 'Tipo de Cita',
              requerido: true,
              valorInicial: _tipoSeleccionado,
              opciones: TipoCita.values.map((tipo) {
                return OpcionSelector(
                  valor: tipo,
                  etiqueta: tipo.texto,
                  icono: tipo.icono,
                );
              }).toList(),
              onChanged: (valor) {
                if (valor != null) {
                  setState(() {
                    _tipoSeleccionado = valor;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            CampoSelector<DuracionCita>(
              etiqueta: 'Duración',
              requerido: true,
              valorInicial: _duracionSeleccionada,
              opciones: DuracionCita.values.map((duracion) {
                return OpcionSelector(
                  valor: duracion,
                  etiqueta: duracion.texto,
                );
              }).toList(),
              onChanged: (valor) {
                if (valor != null) {
                  setState(() {
                    _duracionSeleccionada = valor;
                  });
                  _validarHorario();
                }
              },
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: CampoSelector<TipoCita>(
                    etiqueta: 'Tipo de Cita',
                    requerido: true,
                    valorInicial: _tipoSeleccionado,
                    opciones: TipoCita.values.map((tipo) {
                      return OpcionSelector(
                        valor: tipo,
                        etiqueta: tipo.texto,
                        icono: tipo.icono,
                      );
                    }).toList(),
                    onChanged: (valor) {
                      if (valor != null) {
                        setState(() {
                          _tipoSeleccionado = valor;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CampoSelector<DuracionCita>(
                    etiqueta: 'Duración',
                    requerido: true,
                    valorInicial: _duracionSeleccionada,
                    opciones: DuracionCita.values.map((duracion) {
                      return OpcionSelector(
                        valor: duracion,
                        etiqueta: duracion.texto,
                      );
                    }).toList(),
                    onChanged: (valor) {
                      if (valor != null) {
                        setState(() {
                          _duracionSeleccionada = valor;
                        });
                        _validarHorario();
                      }
                    },
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Estado y Primera vez - Responsive
          if (esMovil) ...[
            CampoSelector<EstadoCita>(
              etiqueta: 'Estado',
              requerido: true,
              valorInicial: _estadoSeleccionado,
              opciones: EstadoCita.values.map((estado) {
                return OpcionSelector(
                  valor: estado,
                  etiqueta: estado.texto,
                  icono: estado.icono,
                  color: estado.color,
                );
              }).toList(),
              onChanged: (valor) {
                if (valor != null) {
                  setState(() {
                    _estadoSeleccionado = valor;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: ColoresApp.borde),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CheckboxListTile(
                title: const Text('¿Primera vez?'),
                value: _esPrimeraVez,
                onChanged: (value) {
                  setState(() {
                    _esPrimeraVez = value ?? true;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: CampoSelector<EstadoCita>(
                    etiqueta: 'Estado',
                    requerido: true,
                    valorInicial: _estadoSeleccionado,
                    opciones: EstadoCita.values.map((estado) {
                      return OpcionSelector(
                        valor: estado,
                        etiqueta: estado.texto,
                        icono: estado.icono,
                        color: estado.color,
                      );
                    }).toList(),
                    onChanged: (valor) {
                      if (valor != null) {
                        setState(() {
                          _estadoSeleccionado = valor;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: ColoresApp.borde),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CheckboxListTile(
                      title: const Text('¿Primera vez?'),
                      value: _esPrimeraVez,
                      onChanged: (value) {
                        setState(() {
                          _esPrimeraVez = value ?? true;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),

          CampoTexto(
            controlador: _psicologoIdController,
            etiqueta: 'ID del Psicólogo',
            requerido: true,
            validador: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El ID del psicólogo es requerido';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          CampoTextarea(
            controlador: _observacionesController,
            etiqueta: 'Observaciones',
            lineasMin: 3,
            lineasMax: 5,
            mostrarContador: false,
          ),

          const SizedBox(height: 32),

          // Botones de acción
          GrupoBotonesAccion(
            onGuardar: _guardarCita,
            onCancelar: widget.onCancelar,
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionTitulo(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: ColoresApp.textoGris,
      ),
    );
  }

  Widget _buildAutocompleteNombre() {
    return CampoTexto(
      controlador: _estudianteNombreController,
      etiqueta: 'Nombre',
      requerido: true,
      placeholder: 'Ingresa el nombre del estudiante',
      iconoPrefijo: Icons.person,
      iconoSufijo: Icons.search,
      onIconoSufijoTap: () => _mostrarBuscadorEstudiantes(),
      validador: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El nombre es requerido';
        }
        return null;
      },
    );
  }

  Widget _buildAutocompleteApellidos() {
    return CampoTexto(
      controlador: _estudianteApellidosController,
      etiqueta: 'Apellidos',
      requerido: true,
      placeholder: 'Ingresa los apellidos del estudiante',
      iconoPrefijo: Icons.person,
      iconoSufijo: Icons.search,
      onIconoSufijoTap: () => _mostrarBuscadorEstudiantes(),
      validador: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Los apellidos son requeridos';
        }
        return null;
      },
    );
  }

  void _mostrarBuscadorEstudiantes() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String busqueda = '';
        return StatefulBuilder(
          builder: (context, setState) {
            final estudiantesFiltrados = busqueda.isEmpty
                ? _estudiantesRegistrados
                : _estudiantesRegistrados.where((estudiante) {
                    final nombreCompleto = estudiante['nombreCompleto']!.toLowerCase();
                    return nombreCompleto.contains(busqueda.toLowerCase());
                  }).toList();

            return AlertDialog(
              title: const Text('Buscar Estudiante'),
              content: SizedBox(
                width: 400,
                height: 500,
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Buscar',
                        hintText: 'Escribe nombre o apellidos...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          busqueda = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: estudiantesFiltrados.isEmpty
                          ? const Center(
                              child: Text('No se encontraron estudiantes'),
                            )
                          : ListView.builder(
                              itemCount: estudiantesFiltrados.length,
                              itemBuilder: (context, index) {
                                final estudiante = estudiantesFiltrados[index];
                                return ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(estudiante['nombreCompleto']!),
                                  subtitle: Text(estudiante['codigo'] ?? ''),
                                  onTap: () {
                                    this.setState(() {
                                      _actualizarDatosEstudiante(estudiante);
                                    });
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _guardarCita() async {
    if (_formKey.currentState!.validate()) {
      if (_fechaSeleccionada == null || _horaSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona fecha y hora'),
            backgroundColor: ColoresApp.error,
          ),
        );
        return;
      }

      // Validar que no haya conflicto de horario
      if (_conflictoHorario != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(_conflictoHorario!),
                ),
              ],
            ),
            backgroundColor: ColoresApp.error,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      final fechaHora = DateTime(
        _fechaSeleccionada!.year,
        _fechaSeleccionada!.month,
        _fechaSeleccionada!.day,
        _horaSeleccionada!.hour,
        _horaSeleccionada!.minute,
      );

      final cita = CitaModelo(
        id: widget.citaInicial?.id ?? '',
        estudianteId: widget.citaInicial?.estudianteId ?? '',
        estudianteNombre: _estudianteNombreController.text.trim(),
        estudianteApellidos: _estudianteApellidosController.text.trim(),
        estudianteCodigo: _estudianteCodigoController.text.trim().isNotEmpty
            ? _estudianteCodigoController.text.trim()
            : null,
        estudianteEmail: _estudianteEmailController.text.trim().isNotEmpty
            ? _estudianteEmailController.text.trim()
            : null,
        estudianteTelefono: _estudianteTelefonoController.text.trim().isNotEmpty
            ? _estudianteTelefonoController.text.trim()
            : null,
        facultad: _facultadSeleccionada!,
        programa: _programaController.text.trim(),
        fechaHora: fechaHora,
        duracion: _duracionSeleccionada,
        psicologoId: _psicologoIdController.text.trim(),
        motivoConsulta: _motivoController.text.trim(),
        tipoCita: _tipoSeleccionado,
        estado: _estadoSeleccionado,
        observaciones: _observacionesController.text.trim().isNotEmpty
            ? _observacionesController.text.trim()
            : null,
        fechaCreacion: widget.citaInicial?.fechaCreacion ?? DateTime.now(),
        primeraVez: _esPrimeraVez,
      );

      // Mostrar modal de carga
      if (mounted) {
        ModalCarga.mostrarModal(
          context,
          mensaje: widget.citaInicial == null
            ? 'Guardando cita...'
            : 'Actualizando cita...',
        );
      }

      // Llamar al callback para guardar
      widget.onGuardar(cita);
    }
  }
}

// Widget personalizado para los botones de acción
class GrupoBotonesAccion extends StatelessWidget {
  final VoidCallback? onGuardar;
  final VoidCallback? onCancelar;

  const GrupoBotonesAccion({
    super.key,
    this.onGuardar,
    this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onCancelar != null)
          BotonSecundario(
            texto: 'Cancelar',
            onPressed: onCancelar,
          ),
        if (onCancelar != null) const SizedBox(width: 12),
        ElevatedButton(
          onPressed: onGuardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColoresApp.primario,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Guardar',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}