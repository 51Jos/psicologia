import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controlador/cita_controlador.dart';
import '../modelos/cita_modelo.dart';
import '../componentes/agregar/formulario_cita_componente.dart';

class FormularioCitaVista extends StatefulWidget {
  final CitaModelo? cita;

  const FormularioCitaVista({
    super.key,
    this.cita,
  });

  @override
  State<FormularioCitaVista> createState() => _FormularioCitaVistaState();
}

class _FormularioCitaVistaState extends State<FormularioCitaVista> {
  bool _guardando = false;

  bool get _esEdicion => widget.cita != null;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 20),
                    // Formulario
                    Consumer<CitaControlador>(
                      builder: (context, controlador, child) {
                        return Stack(
                          children: [
                            FormularioCitaComponente(
                              citaInicial: widget.cita,
                              onGuardar: (cita) => _guardarCita(cita, controlador),
                              onCancelar: () => Navigator.of(context).pop(),
                            ),
                            if (_guardando || controlador.cargando)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(
                                          color: Color(0xFF667EEA),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Guardando cita...',
                                          style: TextStyle(
                                            color: Color(0xFF4A5568),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
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
      width: double.infinity,
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
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
                tooltip: 'Volver',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _esEdicion ? 'Editar Cita' : 'Nueva Cita',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _esEdicion
                          ? 'Modifica los datos de la cita'
                          : 'Registra una nueva cita psicológica',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              if (_esEdicion) ...[
                const SizedBox(width: 16),
                _buildEstadoBadge(widget.cita!.estado),
              ],
            ],
          ),
          if (_esEdicion) ...[
            const SizedBox(height: 16),
            _buildInfoRapida(),
          ],
        ],
      ),
    );
  }

  Widget _buildEstadoBadge(EstadoCita estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: estado.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: estado.color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            estado.icono,
            size: 16,
            color: estado.color,
          ),
          const SizedBox(width: 6),
          Text(
            estado.texto,
            style: TextStyle(
              color: estado.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRapida() {
    final cita = widget.cita!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoItem(
              'Estudiante',
              cita.nombreCompleto,
              Icons.person,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildInfoItem(
              'Fecha Original',
              '${cita.fechaHora.day}/${cita.fechaHora.month}/${cita.fechaHora.year}',
              Icons.calendar_today,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildInfoItem(
              'Facultad',
              cita.facultad,
              Icons.school,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Future<void> _guardarCita(CitaModelo cita, CitaControlador controlador) async {
    if (_guardando) return;

    setState(() {
      _guardando = true;
    });

    try {
      bool exito;

      if (_esEdicion) {
        exito = await controlador.actualizarCita(cita);
      } else {
        exito = await controlador.crearCita(cita);
      }

      if (exito) {
        if (mounted) {
          _mostrarMensajeExito();
          // Esperar un momento para mostrar el mensaje y luego navegar
          await Future.delayed(const Duration(milliseconds: 1500));
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          _mostrarMensajeError(controlador.error);
        }
      }
    } catch (e) {
      if (mounted) {
        _mostrarMensajeError('Error inesperado: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  void _mostrarMensajeExito() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _esEdicion
                    ? 'Cita actualizada exitosamente'
                    : 'Cita creada exitosamente',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF48BB78),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _mostrarMensajeError(String? mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mensaje ?? 'Error al guardar la cita',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}