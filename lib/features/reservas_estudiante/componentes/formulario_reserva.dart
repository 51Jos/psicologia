import 'package:flutter/material.dart';
import '../../autenticacion/modelos/usuario.dart';
import '../../citas/modelos/cita_modelo.dart';
import '../servicios/reserva_servicio.dart';
import 'selector_fecha_hora.dart';
import '../../../compartidos/componentes/botones/boton_primario.dart';
import '../../../compartidos/componentes/modal_carga.dart';

class FormularioReserva extends StatefulWidget {
  final UsuarioModelo estudiante;
  final VoidCallback? onReservaCreada;

  const FormularioReserva({
    super.key,
    required this.estudiante,
    this.onReservaCreada,
  });

  @override
  State<FormularioReserva> createState() => _FormularioReservaState();
}

class _FormularioReservaState extends State<FormularioReserva> {
  final _formKey = GlobalKey<FormState>();
  final _reservaServicio = ReservaServicio();

  // Estados
  bool _cargandoPsicologo = true;
  bool _cargandoHorarios = false;
  List<DateTime> _horariosDisponibles = [];
  String? _errorPsicologo;

  // Valores del formulario
  UsuarioModelo? _psicologoGenerico;
  DateTime? _fechaSeleccionada;
  DateTime? _horaSeleccionada;
  DuracionCita _duracionSeleccionada = DuracionCita.minutos45;
  final TextEditingController _motivoController = TextEditingController();
  TipoCita _tipoSeleccionado = TipoCita.presencial;

  @override
  void initState() {
    super.initState();
    _cargarPsicologoGenerico();
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _cargarPsicologoGenerico() async {
    setState(() {
      _cargandoPsicologo = true;
      _errorPsicologo = null;
    });

    try {
      final psicologo = await _reservaServicio.obtenerPsicologoGenerico();

      if (psicologo == null) {
        setState(() {
          _psicologoGenerico = null;
          _cargandoPsicologo = false;
          _errorPsicologo = 'No se pudo cargar el servicio de psicología. Por favor contacta al administrador.';
        });
        return;
      }

      setState(() {
        _psicologoGenerico = psicologo;
        _cargandoPsicologo = false;
      });
    } catch (e) {
      setState(() {
        _cargandoPsicologo = false;
        _errorPsicologo = 'Error al cargar el servicio: $e';
      });
    }
  }

  Future<void> _cargarHorariosDisponibles() async {
    if (_psicologoGenerico == null || _fechaSeleccionada == null) {
      return;
    }

    setState(() {
      _cargandoHorarios = true;
      _horaSeleccionada = null;
    });

    try {
      final horarios = await _reservaServicio.obtenerHorariosDisponibles(
        _psicologoGenerico!.id,
        _fechaSeleccionada!,
      );

      setState(() {
        _horariosDisponibles = horarios;
        _cargandoHorarios = false;
      });
    } catch (e) {
      setState(() => _cargandoHorarios = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar horarios: $e')),
        );
      }
    }
  }

  Future<void> _crearReserva() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccione una hora')),
      );
      return;
    }

    // Combinar fecha y hora
    final fechaHora = DateTime(
      _fechaSeleccionada!.year,
      _fechaSeleccionada!.month,
      _fechaSeleccionada!.day,
      _horaSeleccionada!.hour,
      _horaSeleccionada!.minute,
    );

    final cita = CitaModelo(
      id: '',
      estudianteId: widget.estudiante.id,
      estudianteNombre: widget.estudiante.nombres,
      estudianteApellidos: widget.estudiante.apellidos,
      estudianteEmail: widget.estudiante.email,
      estudianteTelefono: widget.estudiante.telefono,
      estudianteCodigo: widget.estudiante.email.split('@')[0], // Código del email
      facultad: 'Por definir', // Esto se puede mejorar
      programa: 'Por definir', // Esto se puede mejorar
      fechaHora: fechaHora,
      duracion: _duracionSeleccionada,
      psicologoId: _psicologoGenerico!.id,
      psicologoNombre: _psicologoGenerico!.nombreCompleto,
      motivoConsulta: _motivoController.text.trim(),
      tipoCita: _tipoSeleccionado,
      estado: EstadoCita.programada,
      fechaCreacion: DateTime.now(),
      primeraVez: true,
    );

    ModalCarga.mostrarModal(context);

    try {
      final citaId = await _reservaServicio.crearReserva(cita);

      if (mounted) {
        ModalCarga.ocultarModal(context);
      }

      if (citaId != null && citaId.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Reserva creada exitosamente!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Llamar al callback onReservaCreada si existe
          widget.onReservaCreada?.call();

          // Limpiar el formulario
          _limpiarFormulario();
        }
      } else {
        throw Exception('No se pudo crear la reserva');
      }
    } catch (e) {
      debugPrint('❌ Error capturado en formulario: $e');

      if (mounted) {
        // Asegurar que el modal se cierre
        try {
          ModalCarga.ocultarModal(context);
        } catch (_) {
          // Ignorar si ya estaba cerrado
        }

        // Mostrar mensaje de error más específico
        String mensajeError = 'Error al crear la reserva';
        if (e.toString().contains('PERMISSION_DENIED') ||
            e.toString().contains('permission-denied') ||
            e.toString().contains('permisos')) {
          mensajeError = 'Error de permisos. Por favor, cierra sesión y vuelve a iniciar.';
        } else if (e.toString().contains('network') ||
            e.toString().contains('conexión')) {
          mensajeError = 'Error de conexión. Verifica tu internet.';
        } else {
          mensajeError = e.toString().replaceAll('Exception:', '').trim();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensajeError),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Cerrar',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  void _limpiarFormulario() {
    setState(() {
      // No limpiamos _psicologoGenerico ya que siempre es el mismo
      _fechaSeleccionada = null;
      _horaSeleccionada = null;
      _horariosDisponibles = [];
      _duracionSeleccionada = DuracionCita.minutos45;
      _tipoSeleccionado = TipoCita.presencial;
      _motivoController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar error si no se pudo cargar el psicólogo genérico
    if (_errorPsicologo != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red[300],
              ),
              const SizedBox(height: 24),
              Text(
                'Error al cargar el servicio',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorPsicologo!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _cargarPsicologoGenerico,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mostrar cargando mientras se obtiene el psicólogo genérico
    if (_cargandoPsicologo) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando servicio de psicología...'),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Información del servicio de psicología
            Card(
              elevation: 2,
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tu cita será agendada con el servicio de psicología de la universidad',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Selector de Fecha y Hora
            SelectorFechaHora(
                fechaSeleccionada: _fechaSeleccionada,
                horaSeleccionada: _horaSeleccionada,
                duracionSeleccionada: _duracionSeleccionada,
                horariosDisponibles: _horariosDisponibles,
                cargandoHorarios: _cargandoHorarios,
                onFechaChanged: (fecha) {
                  setState(() => _fechaSeleccionada = fecha);
                  _cargarHorariosDisponibles();
                },
                onHoraChanged: (hora) {
                  setState(() => _horaSeleccionada = hora);
                },
                onDuracionChanged: (duracion) {
                  setState(() {
                    _duracionSeleccionada = duracion ?? DuracionCita.minutos45;
                  });
                  _cargarHorariosDisponibles();
                },
              ),
            const SizedBox(height: 16),

            // Tipo de Cita
            Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tipo de Consulta',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<TipoCita>(
                        value: _tipoSeleccionado,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.medical_services),
                        ),
                        items: TipoCita.values.map((tipo) {
                          return DropdownMenuItem<TipoCita>(
                            value: tipo,
                            child: Row(
                              children: [
                                Icon(tipo.icono, size: 20),
                                const SizedBox(width: 8),
                                Text(tipo.texto),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (valor) {
                          setState(() => _tipoSeleccionado = valor!);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Motivo de Consulta
            Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Motivo de Consulta',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _motivoController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Describe brevemente el motivo de tu consulta...',
                          prefixIcon: Icon(Icons.note_alt),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El motivo de consulta es requerido';
                          }
                          if (value.trim().length < 10) {
                            return 'El motivo debe tener al menos 10 caracteres';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Botón de Crear Reserva
            BotonPrimario(
                texto: 'Crear Reserva',
                onPressed: _crearReserva,
                icono: Icons.check,
              ),
          ],
        ),
      ),
    );
  }
}
