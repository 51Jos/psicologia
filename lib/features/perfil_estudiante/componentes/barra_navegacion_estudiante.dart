import 'package:flutter/material.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../servicios/perfil_servicio.dart';

class BarraNavegacionEstudiante extends StatelessWidget {
  final int indiceActual;
  final Function(int) onItemTap;

  const BarraNavegacionEstudiante({
    super.key,
    required this.indiceActual,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final esMovil = MediaQuery.of(context).size.width < 768;

    if (esMovil) {
      return _buildBottomNavBar(context);
    } else {
      return _buildSideNavRail(context);
    }
  }

  // Barra de navegación inferior para móvil
  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: indiceActual,
      onTap: onItemTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: ColoresApp.primario,
      unselectedItemColor: ColoresApp.textoGris,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
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
    );
  }

  // Barra de navegación lateral para tablet/desktop
  Widget _buildSideNavRail(BuildContext context) {
    final esDesktop = MediaQuery.of(context).size.width >= 1200;

    return NavigationRail(
      selectedIndex: indiceActual,
      onDestinationSelected: onItemTap,
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
              decoration: BoxDecoration(
                color: ColoresApp.primario,
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
                  color: ColoresApp.textoGris,
                ),
              ),
              const Text(
                'Estudiante',
                style: TextStyle(
                  fontSize: 10,
                  color: ColoresApp.textoGrisClaro,
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
                  color: ColoresApp.error,
                ),
                if (esDesktop)
                  const Text(
                    'Salir',
                    style: TextStyle(
                      fontSize: 10,
                      color: ColoresApp.error,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Inicio'),
        ),
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
        color: ColoresApp.primario,
        size: 28,
      ),
      unselectedIconTheme: const IconThemeData(
        color: ColoresApp.textoGris,
        size: 24,
      ),
      selectedLabelTextStyle: const TextStyle(
        color: ColoresApp.primario,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      unselectedLabelTextStyle: const TextStyle(
        color: ColoresApp.textoGris,
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
              backgroundColor: ColoresApp.error,
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
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
}
