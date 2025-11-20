import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:psicologia/features/citas/modelos/filtros_modelo.dart';
import '../../controlador/cita_controlador.dart';
import '../../modelos/cita_modelo.dart';

class FiltrosBusquedaComponente extends StatefulWidget {
  const FiltrosBusquedaComponente({super.key});

  @override
  State<FiltrosBusquedaComponente> createState() => _FiltrosBusquedaComponenteState();
}

class _FiltrosBusquedaComponenteState extends State<FiltrosBusquedaComponente> {
  final TextEditingController _busquedaController = TextEditingController();
  bool _filtrosExpandidos = false;

  final List<Map<String, String>> _facultades = [
    {'codigo': 'FC', 'nombre': 'Facultad de Ciencias'},
    {'codigo': 'FCS', 'nombre': 'Facultad de Ciencias de la Salud'},
    {'codigo': 'FEI', 'nombre': 'Facultad de Estudios a Distancia e Ingeniería'},
    {'codigo': 'FCE', 'nombre': 'Facultad de Ciencias Económicas'},
  ];

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    final esPantallaGrande = ancho >= 900;

    return Consumer<CitaControlador>(
      builder: (context, controlador, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: esPantallaGrande
              ? _construirLayoutGrande(controlador)
              : _construirLayoutPequeno(controlador),
        );
      },
    );
  }

  Widget _construirLayoutGrande(CitaControlador controlador) {
    return Column(
      children: [
        Row(
          children: [
            // Barra de búsqueda
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _busquedaController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre, facultad, programa...',
                    prefixIcon: Icon(Icons.search, color: Color(0xFF667EEA)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                  onChanged: (valor) {
                    controlador.aplicarBusqueda(valor);
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Filtro de fecha
            _buildFiltroFecha(controlador),
            const SizedBox(width: 12),
            // Filtro por facultad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String?>(
                value: controlador.filtros.facultad,
                hint: const Text('Todas las Facultades'),
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todas las Facultades'),
                  ),
                  ..._facultades.map((facultad) => DropdownMenuItem<String?>(
                    value: facultad['codigo'],
                    child: Text('${facultad['codigo']} - ${facultad['nombre']}'),
                  )),
                ],
                onChanged: (valor) {
                  controlador.filtrarPorFacultad(valor);
                },
              ),
            ),
            const SizedBox(width: 12),
            // Filtro por estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<EstadoCita?>(
                value: controlador.filtros.estado,
                hint: const Text('Todos los Estados'),
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem<EstadoCita?>(
                    value: null,
                    child: Text('Todos los Estados'),
                  ),
                  ...EstadoCita.values.map((estado) => DropdownMenuItem<EstadoCita?>(
                    value: estado,
                    child: Text(estado.texto),
                  )),
                ],
                onChanged: (valor) {
                  controlador.filtrarPorEstado(valor);
                },
              ),
            ),
            const SizedBox(width: 12),
            // Botón para limpiar filtros
            if (controlador.filtros.hayFiltros)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFC),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {
                    _busquedaController.clear();
                    controlador.limpiarFiltros();
                  },
                  icon: const Icon(Icons.clear, color: Color(0xFF718096)),
                  tooltip: 'Limpiar filtros',
                ),
              ),
            const SizedBox(width: 12),
            // Botón para cambiar vista
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF667EEA), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: () {
                  controlador.cambiarTipoVista(
                    controlador.tipoVista == TipoVista.tabla
                        ? TipoVista.tarjetas
                        : TipoVista.tabla,
                  );
                },
                icon: Icon(
                  controlador.tipoVista == TipoVista.tabla
                      ? Icons.view_module
                      : Icons.table_rows,
                  color: const Color(0xFF667EEA),
                ),
                tooltip: controlador.tipoVista == TipoVista.tabla
                    ? 'Vista de tarjetas'
                    : 'Vista de tabla',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFiltroFecha(CitaControlador controlador) {
    final hasFiltroFecha = controlador.filtros.fechaInicio != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: hasFiltroFecha ? const Color(0xFF667EEA) : const Color(0xFFE2E8F0),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: hasFiltroFecha ? const Color(0xFF667EEA).withOpacity(0.1) : Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            color: hasFiltroFecha ? const Color(0xFF667EEA) : const Color(0xFF718096),
            size: 20,
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _mostrarSelectorFecha(controlador),
            child: Text(
              _obtenerTextoFecha(controlador),
              style: TextStyle(
                color: hasFiltroFecha ? const Color(0xFF667EEA) : const Color(0xFF718096),
                fontWeight: hasFiltroFecha ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.arrow_drop_down,
              color: hasFiltroFecha ? const Color(0xFF667EEA) : const Color(0xFF718096),
            ),
            onSelected: (value) => _aplicarFiltroFechaRapido(controlador, value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'hoy', child: Text('Hoy')),
              const PopupMenuItem(value: 'manana', child: Text('Mañana')),
              const PopupMenuItem(value: 'semana', child: Text('Esta semana')),
              const PopupMenuItem(value: 'mes', child: Text('Este mes')),
              const PopupMenuItem(value: 'personalizado', child: Text('Personalizado...')),
              if (hasFiltroFecha)
                const PopupMenuItem(value: 'limpiar', child: Text('Limpiar filtro')),
            ],
          ),
        ],
      ),
    );
  }

  String _obtenerTextoFecha(CitaControlador controlador) {
    if (controlador.filtros.fechaInicio == null) {
      return 'Filtrar por fecha';
    }

    final inicio = controlador.filtros.fechaInicio!;
    final fin = controlador.filtros.fechaFin;

    final hoy = DateTime.now();
    final esHoy = inicio.year == hoy.year &&
                  inicio.month == hoy.month &&
                  inicio.day == hoy.day;

    if (esHoy && fin != null) {
      final esMismoDia = fin.year == hoy.year &&
                         fin.month == hoy.month &&
                         fin.day == hoy.day;
      if (esMismoDia) return 'Hoy';
    }

    if (fin != null && inicio.day != fin.day) {
      return '${DateFormat('dd/MM').format(inicio)} - ${DateFormat('dd/MM').format(fin)}';
    }

    return DateFormat('dd/MM/yyyy').format(inicio);
  }

  void _aplicarFiltroFechaRapido(CitaControlador controlador, String opcion) {
    final ahora = DateTime.now();

    switch (opcion) {
      case 'hoy':
        controlador.filtrarPorHoy();
        break;
      case 'manana':
        final manana = ahora.add(const Duration(days: 1));
        controlador.filtrarPorFecha(
          manana.copyWith(hour: 0, minute: 0, second: 0),
          manana.copyWith(hour: 23, minute: 59, second: 59),
        );
        break;
      case 'semana':
        final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
        final finSemana = inicioSemana.add(const Duration(days: 6));
        controlador.filtrarPorFecha(
          inicioSemana.copyWith(hour: 0, minute: 0, second: 0),
          finSemana.copyWith(hour: 23, minute: 59, second: 59),
        );
        break;
      case 'mes':
        final inicioMes = DateTime(ahora.year, ahora.month, 1);
        final finMes = DateTime(ahora.year, ahora.month + 1, 0);
        controlador.filtrarPorFecha(
          inicioMes.copyWith(hour: 0, minute: 0, second: 0),
          finMes.copyWith(hour: 23, minute: 59, second: 59),
        );
        break;
      case 'personalizado':
        _mostrarSelectorFecha(controlador);
        break;
      case 'limpiar':
        controlador.filtrarPorFecha(null, null);
        break;
    }
  }

  Future<void> _mostrarSelectorFecha(CitaControlador controlador) async {
    final DateTimeRange? rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: controlador.filtros.fechaInicio != null && controlador.filtros.fechaFin != null
          ? DateTimeRange(
              start: controlador.filtros.fechaInicio!,
              end: controlador.filtros.fechaFin!,
            )
          : null,
      locale: const Locale('es', 'ES'),
    );

    if (rango != null) {
      controlador.filtrarPorFecha(
        rango.start.copyWith(hour: 0, minute: 0, second: 0),
        rango.end.copyWith(hour: 23, minute: 59, second: 59),
      );
    }
  }

  Widget _construirLayoutPequeno(CitaControlador controlador) {
    return Column(
      children: [
        // Barra de búsqueda
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _busquedaController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre, facultad, programa...',
                    prefixIcon: Icon(Icons.search, color: Color(0xFF667EEA)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                  onChanged: (valor) {
                    controlador.aplicarBusqueda(valor);
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Botón para expandir filtros
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF667EEA), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _filtrosExpandidos = !_filtrosExpandidos;
                  });
                },
                icon: Icon(
                  _filtrosExpandidos ? Icons.filter_list_off : Icons.filter_list,
                  color: const Color(0xFF667EEA),
                ),
                tooltip: _filtrosExpandidos ? 'Ocultar filtros' : 'Mostrar filtros',
              ),
            ),
            const SizedBox(width: 8),
            // Botón para cambiar vista
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF667EEA), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: () {
                  controlador.cambiarTipoVista(
                    controlador.tipoVista == TipoVista.tabla
                        ? TipoVista.tarjetas
                        : TipoVista.tabla,
                  );
                },
                icon: Icon(
                  controlador.tipoVista == TipoVista.tabla
                      ? Icons.view_module
                      : Icons.table_rows,
                  color: const Color(0xFF667EEA),
                ),
                tooltip: controlador.tipoVista == TipoVista.tabla
                    ? 'Vista de tarjetas'
                    : 'Vista de tabla',
              ),
            ),
          ],
        ),
        // Filtros desplegables
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              const SizedBox(height: 12),
              // Filtro de fecha en móvil
              SizedBox(
                width: double.infinity,
                child: _buildFiltroFecha(controlador),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Filtro por facultad
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String?>(
                      value: controlador.filtros.facultad,
                      hint: const Text('Todas las Facultades'),
                      underline: const SizedBox(),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todas las Facultades'),
                        ),
                        ..._facultades.map((facultad) => DropdownMenuItem<String?>(
                          value: facultad['codigo'],
                          child: Text('${facultad['codigo']} - ${facultad['nombre']}'),
                        )),
                      ],
                      onChanged: (valor) {
                        controlador.filtrarPorFacultad(valor);
                      },
                    ),
                  ),
                  // Filtro por estado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<EstadoCita?>(
                      value: controlador.filtros.estado,
                      hint: const Text('Todos los Estados'),
                      underline: const SizedBox(),
                      items: [
                        const DropdownMenuItem<EstadoCita?>(
                          value: null,
                          child: Text('Todos los Estados'),
                        ),
                        ...EstadoCita.values.map((estado) => DropdownMenuItem<EstadoCita?>(
                          value: estado,
                          child: Text(estado.texto),
                        )),
                      ],
                      onChanged: (valor) {
                        controlador.filtrarPorEstado(valor);
                      },
                    ),
                  ),
                  // Botón para limpiar filtros
                  if (controlador.filtros.hayFiltros)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAFC),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () {
                          _busquedaController.clear();
                          controlador.limpiarFiltros();
                        },
                        icon: const Icon(Icons.clear, color: Color(0xFF718096)),
                        tooltip: 'Limpiar filtros',
                      ),
                    ),
                ],
              ),
            ],
          ),
          crossFadeState: _filtrosExpandidos
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}