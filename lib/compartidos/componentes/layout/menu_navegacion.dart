import 'package:flutter/material.dart';
import '../../tema/colores_app.dart';
import '../../utilidades/responsive_helper.dart';

class MenuNavegacion extends StatelessWidget {
  final int indiceSeleccionado;
  final Function(int) onItemSeleccionado;
  final List<ItemMenu> items;
  final Widget? encabezado;
  final Widget? pie;
  final bool expandido;
  final Color? colorFondo;
  final Color? colorSeleccionado;
  final double? anchoExpandido;
  final double? anchoColapsado;

  const MenuNavegacion({
    Key? key,
    required this.indiceSeleccionado,
    required this.onItemSeleccionado,
    required this.items,
    this.encabezado,
    this.pie,
    this.expandido = true,
    this.colorFondo,
    this.colorSeleccionado,
    this.anchoExpandido,
    this.anchoColapsado,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool esMobile = ResponsiveHelper.esMobile(context);
    
    // En móvil, usar BottomNavigationBar
    if (esMobile) {
      return BottomNavigationBar(
        currentIndex: indiceSeleccionado,
        onTap: onItemSeleccionado,
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorFondo ?? ColoresApp.fondoPrimario,
        selectedItemColor: colorSeleccionado ?? ColoresApp.primario,
        unselectedItemColor: ColoresApp.textoGrisClaro,
        selectedFontSize: ResponsiveHelper.fontSize(context, base: 12),
        unselectedFontSize: ResponsiveHelper.fontSize(context, base: 11),
        items: items.map((item) => BottomNavigationBarItem(
          icon: Icon(item.icono),
          activeIcon: Icon(item.iconoActivo ?? item.icono),
          label: item.titulo,
          tooltip: item.tooltip ?? item.titulo,
        )).toList(),
      );
    }
    
    // En tablet/desktop, usar NavigationRail o Drawer
    final double ancho = expandido 
        ? (anchoExpandido ?? ResponsiveHelper.valor(
            context,
            mobile: 250,
            tablet: 280,
            desktop: 300,
          ))
        : (anchoColapsado ?? 72);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: ancho,
      decoration: BoxDecoration(
        color: colorFondo ?? ColoresApp.fondoPrimario,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Encabezado
          if (encabezado != null)
            encabezado!
          else
            _construirEncabezadoDefault(context),
          
          // Divider
          Container(
            height: 1,
            color: ColoresApp.borde.withOpacity(0.2),
          ),
          
          // Items del menú
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveHelper.valor(context, mobile: 8, desktop: 16),
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final bool seleccionado = index == indiceSeleccionado;
                
                if (item.esDivider) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                      color: ColoresApp.borde.withOpacity(0.2),
                      thickness: 1,
                    ),
                  );
                }
                
                if (item.esEncabezado) {
                  return expandido
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            item.titulo,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.fontSize(context, base: 12),
                              fontWeight: FontWeight.w600,
                              color: ColoresApp.textoGrisClaro,
                              letterSpacing: 1.2,
                            ),
                          ),
                        )
                      : const SizedBox(height: 16);
                }
                
                return _construirItemMenu(
                  context,
                  item,
                  seleccionado,
                  () => onItemSeleccionado(index),
                );
              },
            ),
          ),
          
          // Pie
          if (pie != null)
            Container(
              padding: EdgeInsets.all(
                ResponsiveHelper.valor(context, mobile: 12, desktop: 16),
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: ColoresApp.borde.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: pie!,
            ),
        ],
      ),
    );
  }

  Widget _construirEncabezadoDefault(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveHelper.valor(context, mobile: 16, desktop: 24),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ColoresApp.primario,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.school,
              color: ColoresApp.textoBlanco,
              size: 24,
            ),
          ),
          if (expandido) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sistema de',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(context, base: 12),
                      color: ColoresApp.textoGrisClaro,
                    ),
                  ),
                  Text(
                    'Psicología',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(context, base: 16),
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.textoBlanco,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _construirItemMenu(
    BuildContext context,
    ItemMenu item,
    bool seleccionado,
    VoidCallback onTap,
  ) {
    final Color colorIcono = seleccionado
        ? (colorSeleccionado ?? ColoresApp.primario)
        : ColoresApp.textoGrisClaro;
    
    final Color colorTexto = seleccionado
        ? ColoresApp.textoBlanco
        : ColoresApp.textoGrisClaro;
    
    final Color? colorFondoItem = seleccionado
        ? (colorSeleccionado ?? ColoresApp.primario).withOpacity(0.15)
        : null;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.valor(context, mobile: 8, desktop: 12),
        vertical: 2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.habilitado ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.valor(context, mobile: 12, desktop: 16),
              vertical: ResponsiveHelper.valor(context, mobile: 10, desktop: 12),
            ),
            decoration: BoxDecoration(
              color: colorFondoItem,
              borderRadius: BorderRadius.circular(8),
              border: seleccionado
                  ? Border.all(
                      color: (colorSeleccionado ?? ColoresApp.primario).withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  seleccionado && item.iconoActivo != null
                      ? item.iconoActivo
                      : item.icono,
                  color: item.habilitado ? colorIcono : colorIcono.withOpacity(0.5),
                  size: ResponsiveHelper.valor(context, mobile: 20, desktop: 24),
                ),
                if (expandido) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.titulo,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.fontSize(context, base: 14),
                        fontWeight: seleccionado ? FontWeight.w600 : FontWeight.w400,
                        color: item.habilitado ? colorTexto : colorTexto.withOpacity(0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.contador != null && item.contador! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: item.colorContador ?? ColoresApp.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.contador! > 99 ? '99+' : '${item.contador}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: ColoresApp.textoBlanco,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Modelo para los items del menú
class ItemMenu {
  final IconData icono;
  final IconData? iconoActivo;
  final String titulo;
  final String? tooltip;
  final String? ruta;
  final int? contador;
  final Color? colorContador;
  final bool habilitado;
  final bool esDivider;
  final bool esEncabezado;
  final List<ItemMenu>? subItems;

  ItemMenu({
    required this.icono,
    this.iconoActivo,
    required this.titulo,
    this.tooltip,
    this.ruta,
    this.contador,
    this.colorContador,
    this.habilitado = true,
    this.esDivider = false,
    this.esEncabezado = false,
    this.subItems,
  });

  factory ItemMenu.divider() {
    return ItemMenu(
      icono: Icons.remove,
      titulo: '',
      esDivider: true,
    );
  }

  factory ItemMenu.encabezado(String titulo) {
    return ItemMenu(
      icono: Icons.label,
      titulo: titulo,
      esEncabezado: true,
    );
  }
}

// Configuración predefinida del menú
class ConfiguracionMenu {
  static List<ItemMenu> obtenerItemsMenu() {
    return [
      ItemMenu(
        icono: Icons.assignment_outlined,
        iconoActivo: Icons.assignment,
        titulo: 'Atenciones',
        ruta: '/atenciones',
        contador: 5,
      ),
      ItemMenu(
        icono: Icons.calendar_month_outlined,
        iconoActivo: Icons.calendar_month,
        titulo: 'Citas',
        ruta: '/citas',
        contador: 3,
        colorContador: ColoresApp.advertencia,
      ),
      ItemMenu.divider(),
      ItemMenu(
        icono: Icons.settings_outlined,
        iconoActivo: Icons.settings,
        titulo: 'Configuración',
        ruta: '/configuracion',
      ),
    ];
  }
}