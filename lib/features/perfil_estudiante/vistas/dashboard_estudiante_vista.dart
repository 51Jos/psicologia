import 'package:flutter/material.dart';
import '../componentes/barra_navegacion_estudiante.dart';
import '../vistas/perfil_estudiante_vista.dart';
import '../../reservas_estudiante/vistas/reservas_estudiante_vista.dart';

class DashboardEstudianteVista extends StatefulWidget {
  const DashboardEstudianteVista({super.key});

  @override
  State<DashboardEstudianteVista> createState() => _DashboardEstudianteVistaState();
}

class _DashboardEstudianteVistaState extends State<DashboardEstudianteVista> {
  int _indiceActual = 0;

  final List<Widget> _vistas = [
    const _VistaInicio(),
    const ReservasEstudianteVista(),
    const PerfilEstudianteVista(),
  ];

  @override
  Widget build(BuildContext context) {
    final esMovil = MediaQuery.of(context).size.width < 768;

    if (esMovil) {
      // Layout móvil con BottomNavigationBar
      return Scaffold(
        body: _vistas[_indiceActual],
        bottomNavigationBar: BarraNavegacionEstudiante(
          indiceActual: _indiceActual,
          onItemTap: (index) {
            setState(() {
              _indiceActual = index;
            });
          },
        ),
      );
    } else {
      // Layout desktop/tablet con NavigationRail
      return Scaffold(
        body: Row(
          children: [
            BarraNavegacionEstudiante(
              indiceActual: _indiceActual,
              onItemTap: (index) {
                setState(() {
                  _indiceActual = index;
                });
              },
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: _vistas[_indiceActual],
            ),
          ],
        ),
      );
    }
  }
}

// Vista de inicio temporal (placeholder)
class _VistaInicio extends StatelessWidget {
  const _VistaInicio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: const Color(0xFF2D3748),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.psychology_outlined,
                size: 120,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 24),
              Text(
                'Bienvenido al Portal del Estudiante',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Aquí podrás gestionar tus citas y actualizar tu perfil.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF666666),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildActionCard(
                    context,
                    icon: Icons.calendar_today,
                    title: 'Mis Citas',
                    description: 'Ver y gestionar tus reservas',
                    color: const Color(0xFF0891B2),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.person,
                    title: 'Mi Perfil',
                    description: 'Actualizar datos personales',
                    color: const Color(0xFF10B981),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
