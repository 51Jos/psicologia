import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Row(
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
    );
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