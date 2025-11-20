import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../autenticacion/controladores/auth_controlador.dart';
import '../../citas/modelos/cita_modelo.dart';
import '../servicios/reserva_servicio.dart';
import '../componentes/formulario_reserva.dart';
import '../componentes/lista_mis_reservas.dart';
import '../../../compartidos/componentes/layout/cabecera_pagina.dart';
import '../../../compartidos/tema/colores_app.dart';

class ReservasEstudianteVista extends StatefulWidget {
  const ReservasEstudianteVista({super.key});

  @override
  State<ReservasEstudianteVista> createState() => _ReservasEstudianteVistaState();
}

class _ReservasEstudianteVistaState extends State<ReservasEstudianteVista>
    with SingleTickerProviderStateMixin {
  final _reservaServicio = ReservaServicio();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authControlador = Provider.of<AuthControlador>(context);
    final usuario = authControlador.usuarioActual;

    if (usuario == null) {
      return const Scaffold(
        body: Center(
          child: Text('Usuario no autenticado'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header con botón de cerrar sesión
          Stack(
            children: [
              CabeceraPagina(
                titulo: 'Mis Reservas',
                subtitulo: 'Gestiona tus citas psicológicas',
              ),
              Positioned(
                top: 16,
                right: 16,
                child: _buildBotonCerrarSesion(authControlador, usuario),
              ),
            ],
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: ColoresApp.primario,
              labelColor: ColoresApp.primario,
              unselectedLabelColor: Colors.grey[600],
              tabs: const [
                Tab(
                  icon: Icon(Icons.list),
                  text: 'Mis Citas',
                ),
                Tab(
                  icon: Icon(Icons.add_circle_outline),
                  text: 'Nueva Reserva',
                ),
              ],
            ),
          ),

          // Contenido
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMisCitas(usuario.id),
                FormularioReserva(
                  estudiante: usuario,
                  onReservaCreada: () {
                    // Cambiar al tab de "Mis Citas" cuando se crea la reserva
                    _tabController.animateTo(0);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonCerrarSesion(AuthControlador authControlador, usuario) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[400]!, Colors.red[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _confirmarCerrarSesion(authControlador),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmarCerrarSesion(AuthControlador authControlador) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.red[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Cerrar Sesión',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas cerrar tu sesión?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      await authControlador.cerrarSesion(context);
    }
  }

  Widget _buildMisCitas(String estudianteId) {
    return StreamBuilder<List<CitaModelo>>(
      stream: _reservaServicio.obtenerMisCitas(estudianteId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar reservas',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final citas = snapshot.data ?? [];

        return ListaMisReservas(
          citas: citas,
          onCancelar: (cita) => _cancelarReserva(cita),
        );
      },
    );
  }

  Future<void> _cancelarReserva(CitaModelo cita) async {
    try {
      final motivo = await _solicitarMotivoCancelacion();

      if (motivo == null || motivo.isEmpty) {
        return;
      }

      final exito = await _reservaServicio.cancelarReserva(cita.id, motivo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              exito
                  ? 'Reserva cancelada exitosamente'
                  : 'Error al cancelar la reserva',
            ),
            backgroundColor: exito ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _solicitarMotivoCancelacion() async {
    final TextEditingController motivoController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Motivo de Cancelación'),
        content: TextField(
          controller: motivoController,
          decoration: const InputDecoration(
            hintText: 'Escribe el motivo de la cancelación...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final motivo = motivoController.text.trim();
              Navigator.pop(context, motivo.isNotEmpty ? motivo : null);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
