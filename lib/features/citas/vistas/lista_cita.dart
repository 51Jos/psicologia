import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controlador/cita_controlador.dart';
import '../modelos/cita_modelo.dart';
import '../modelos/filtros_modelo.dart';
import '../componentes/listar/filtros_busqueda_componente.dart';
import '../componentes/listar/tabla_citas_componente.dart';
import '../componentes/listar/tarjetas_citas_componente.dart';
import '../componentes/listar/estadisticas_componente.dart';
import '../componentes/agregar/formulario_cita_componente.dart';
import '../componentes/detalle/detalle_cita_componente.dart';
import '../../../compartidos/componentes/modal_carga.dart' show ModalCarga, EstadoModal;
import '../../../compartidos/tema/colores_app.dart';

class ListaCita extends StatefulWidget {
  const ListaCita({super.key});

  @override
  State<ListaCita> createState() => _ListaCitaState();
}

class _ListaCitaState extends State<ListaCita> {
  late CitaControlador _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = Provider.of<CitaControlador>(context, listen: false);
    _controlador.inicializar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 1600 ? 60 :
                           MediaQuery.of(context).size.width > 1200 ? 40 : 20,
                vertical: 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width > 1600 ? 1800 : 1400,
                ),
                child: Column(
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 20),
                    // Contenido principal
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Controles (búsqueda, filtros y acciones)
                            _buildControles(),
                            const SizedBox(height: 25),
                            // Lista de citas
                            _buildListaCitas(),
                            const SizedBox(height: 25),
                            // Estadísticas
                            const EstadisticasComponente(),
                          ],
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A5568),
            Color(0xFF2D3748),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Text(
            '🏛️ Sistema de Registro de Atenciones Estudiantiles',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Gestión Integral de Consultas Psicológicas y Seguimiento Académico',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildControles() {
    return Column(
      children: [
        // Búsqueda y filtros
        const FiltrosBusquedaComponente(),
        const SizedBox(height: 16),
        // Botones de acción
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Contador de resultados
            Consumer<CitaControlador>(
              builder: (context, controlador, child) {
                return Text(
                  '${controlador.citas.length} citas encontradas',
                  style: const TextStyle(
                    color: Color(0xFF718096),
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
            // Botones de acción
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _navegarAAgregarCita(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('➕ Nuevo Registro', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                OutlinedButton(
                  onPressed: () => _exportarDatos(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF667EEA),
                    side: const BorderSide(color: Color(0xFF667EEA), width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('📊 Exportar Datos', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListaCitas() {
    return Consumer<CitaControlador>(
      builder: (context, controlador, child) {
        if (controlador.cargando) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(
                color: Color(0xFF667EEA),
              ),
            ),
          );
        }

        if (controlador.hayError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar las citas',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A5568),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controlador.error ?? 'Error desconocido',
                    style: const TextStyle(
                      color: Color(0xFF718096),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      controlador.limpiarError();
                      controlador.inicializar();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        // Mostrar vista según el tipo seleccionado
        if (MediaQuery.of(context).size.width > 768) {
          // Vista desktop
          return controlador.tipoVista == TipoVista.tabla
              ? TablaCitasComponente(
                  citas: controlador.citas,
                  onVerDetalles: _verDetallesCita,
                  onEditar: _editarCita,
                  onEliminar: _eliminarCita,
                )
              : TarjetasCitasComponente(
                  citas: controlador.citas,
                  onVerDetalles: _verDetallesCita,
                  onEditar: _editarCita,
                  onEliminar: _eliminarCita,
                );
        } else {
          // Vista móvil - siempre tarjetas
          return TarjetasCitasComponente(
            citas: controlador.citas,
            onVerDetalles: _verDetallesCita,
            onEditar: _editarCita,
            onEliminar: _eliminarCita,
          );
        }
      },
    );
  }

  // Navegación y acciones
  void _navegarAAgregarCita() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildFormularioDialog(null),
    );
  }

  Widget _buildFormularioDialog(CitaModelo? cita) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.9; // 90% de la altura de la pantalla

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 900,
          maxHeight: dialogHeight,
        ),
        height: dialogHeight,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Header del diálogo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: ColoresApp.primario,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cita == null ? 'Nueva Cita' : 'Editar Cita',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.textoBlanco,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: ColoresApp.textoBlanco),
                  ),
                ],
              ),
            ),
            // Contenido con scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FormularioCitaComponente(
                  citaInicial: cita,
                  onGuardar: (nuevaCita) async {
                    // Guardar referencia al BuildContext
                    final dialogContext = context;

                    // Guardar en Firebase
                    final exito = cita == null
                        ? await _controlador.crearCita(nuevaCita)
                        : await _controlador.actualizarCita(nuevaCita);

                    if (!dialogContext.mounted) return;

                    // Cerrar el modal de carga
                    Navigator.of(dialogContext, rootNavigator: false).pop();

                    if (exito) {
                      // Mostrar modal de éxito
                      await showDialog(
                        context: dialogContext,
                        barrierDismissible: false,
                        builder: (ctx) => const ModalCarga(
                          mensaje: 'Cita guardada exitosamente',
                          estado: EstadoModal.exito,
                        ),
                      );

                      // Auto-cerrar después de 1.5 segundos
                      await Future.delayed(const Duration(milliseconds: 1500));

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext, rootNavigator: false).pop(); // Cerrar modal de éxito
                        Navigator.of(dialogContext, rootNavigator: false).pop(); // Cerrar formulario
                      }
                    } else {
                      // Mostrar modal de error
                      await showDialog(
                        context: dialogContext,
                        barrierDismissible: false,
                        builder: (ctx) => ModalCarga(
                          mensaje: _controlador.error ?? 'Error al guardar la cita',
                          estado: EstadoModal.error,
                        ),
                      );
                      // El modal de error se cierra con el botón "Entendido"
                    }
                  },
                  onCancelar: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _verDetallesCita(CitaModelo cita) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.9;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 900,
            maxHeight: dialogHeight,
          ),
          height: dialogHeight,
          child: Column(
            children: [
              // Header del diálogo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: ColoresApp.primario,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detalles de la Cita',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoBlanco,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: ColoresApp.textoBlanco),
                    ),
                  ],
                ),
              ),
              // Contenido
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: DetalleCitaComponente(
                    cita: cita,
                    onEditar: () {
                      Navigator.of(context).pop();
                      _editarCita(cita);
                    },
                    onEliminar: () {
                      Navigator.of(context).pop();
                      _eliminarCita(cita);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editarCita(CitaModelo cita) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildFormularioDialog(cita),
    );
  }

  void _eliminarCita(CitaModelo cita) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar la cita de ${cita.nombreCompleto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Cerrar diálogo de confirmación
              Navigator.pop(dialogContext);

              if (!mounted) return;

              // Mostrar modal de carga
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => const ModalCarga(
                  mensaje: 'Eliminando cita...',
                  estado: EstadoModal.cargando,
                ),
              );

              final exito = await _controlador.eliminarCita(cita.id);

              if (!mounted) return;

              // Cerrar modal de carga
              Navigator.pop(context);

              if (exito) {
                // Mostrar snackbar de éxito en lugar de modal
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cita eliminada exitosamente'),
                    backgroundColor: Color(0xFF48BB78),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                // Mostrar modal de error
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => ModalCarga(
                    mensaje: _controlador.error ?? 'Error al eliminar la cita',
                    estado: EstadoModal.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _exportarDatos() {
    _controlador.exportarDatos();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportando datos...'),
        backgroundColor: Color(0xFF4299E1),
      ),
    );
  }
}