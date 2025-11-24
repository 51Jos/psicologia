import 'package:flutter/material.dart';
import '../../perfil_estudiante/vistas/perfil_estudiante_vista.dart';
import '../../perfil_estudiante/servicios/perfil_servicio.dart';
import 'reservas_estudiante_vista.dart';

class EstudiantePrincipalVista extends StatefulWidget {
  const EstudiantePrincipalVista({super.key});

  @override
  State<EstudiantePrincipalVista> createState() => _EstudiantePrincipalVistaState();
}

class _EstudiantePrincipalVistaState extends State<EstudiantePrincipalVista> {
  int _indiceActual = 0; // 0 = Mis Citas (pantalla principal)

  final List<Widget> _vistas = [
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _indiceActual,
          onTap: (index) {
            setState(() {
              _indiceActual = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2D3748),
          unselectedItemColor: const Color(0xFF666666),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Mis Citas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      );
    } else {
      // Layout desktop/tablet con NavigationRail
      return Scaffold(
        body: Row(
          children: [
            _buildNavigationRail(),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: _vistas[_indiceActual],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildNavigationRail() {
    final esDesktop = MediaQuery.of(context).size.width >= 1200;

    return NavigationRail(
      selectedIndex: _indiceActual,
      onDestinationSelected: (index) {
        setState(() {
          _indiceActual = index;
        });
      },
      backgroundColor: Colors.white,
      labelType: esDesktop
          ? NavigationRailLabelType.all
          : NavigationRailLabelType.selected,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF2D3748),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_outlined,
                color: Colors.white,
                size: 32,
              ),
            ),
            if (esDesktop) ...[
              const SizedBox(height: 8),
              const Text(
                'Portal',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF666666),
                ),
              ),
              const Text(
                'Estudiante',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ],
        ),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Cerrar Sesión',
                  onPressed: () => _cerrarSesion(context),
                  color: const Color(0xFFDC2626),
                ),
                if (esDesktop)
                  const Text(
                    'Salir',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFFDC2626),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: Text('Mis Citas'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Perfil'),
        ),
      ],
      selectedIconTheme: const IconThemeData(
        color: Color(0xFF2D3748),
        size: 28,
      ),
      unselectedIconTheme: const IconThemeData(
        color: Color(0xFF666666),
        size: 24,
      ),
      selectedLabelTextStyle: const TextStyle(
        color: Color(0xFF2D3748),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      unselectedLabelTextStyle: const TextStyle(
        color: Color(0xFF666666),
        fontSize: 12,
      ),
    );
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      await PerfilServicio().cerrarSesion();

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }
}
