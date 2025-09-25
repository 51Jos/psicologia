import 'package:flutter/material.dart';
import '../tema/colores_app.dart';
import '../utilidades/responsive_helper.dart';

class CampoSelector<T> extends StatefulWidget {
  final String? etiqueta;
  final String? placeholder;
  final T? valorInicial;
  final List<OpcionSelector<T>> opciones;
  final String? Function(T?)? validador;
  final void Function(T?)? onChanged;
  final bool habilitado;
  final bool requerido;
  final Widget? iconoPrefijo;
  final bool busquedaHabilitada;
  final bool multiseleccion;
  final List<T>? valoresIniciales;
  final void Function(List<T>)? onMultiseleccionChanged;

  const CampoSelector({
    Key? key,
    this.etiqueta,
    this.placeholder = 'Seleccionar opción',
    this.valorInicial,
    required this.opciones,
    this.validador,
    this.onChanged,
    this.habilitado = true,
    this.requerido = false,
    this.iconoPrefijo,
    this.busquedaHabilitada = false,
    this.multiseleccion = false,
    this.valoresIniciales,
    this.onMultiseleccionChanged,
  }) : super(key: key);

  @override
  State<CampoSelector<T>> createState() => _CampoSelectorState<T>();
}

class _CampoSelectorState<T> extends State<CampoSelector<T>> {
  T? _valorSeleccionado;
  List<T> _valoresSeleccionados = [];
  final FocusNode _focusNode = FocusNode();
  bool _tieneFoco = false;

  @override
  void initState() {
    super.initState();
    _valorSeleccionado = widget.valorInicial;
    _valoresSeleccionados = widget.valoresIniciales ?? [];
    
    _focusNode.addListener(() {
      setState(() {
        _tieneFoco = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _mostrarOpciones() async {
    if (widget.busquedaHabilitada || widget.multiseleccion) {
      final resultado = await showDialog<dynamic>(
        context: context,
        builder: (context) => _DialogoOpciones<T>(
          opciones: widget.opciones,
          valorSeleccionado: _valorSeleccionado,
          valoresSeleccionados: _valoresSeleccionados,
          busquedaHabilitada: widget.busquedaHabilitada,
          multiseleccion: widget.multiseleccion,
          titulo: widget.etiqueta ?? 'Seleccionar',
        ),
      );

      if (resultado != null) {
        if (widget.multiseleccion) {
          setState(() {
            _valoresSeleccionados = resultado as List<T>;
          });
          if (widget.onMultiseleccionChanged != null) {
            widget.onMultiseleccionChanged!(_valoresSeleccionados);
          }
        } else {
          setState(() {
            _valorSeleccionado = resultado as T;
          });
          if (widget.onChanged != null) {
            widget.onChanged!(_valorSeleccionado);
          }
        }
      }
    }
  }

  String _obtenerTextoMostrado() {
    if (widget.multiseleccion) {
      if (_valoresSeleccionados.isEmpty) {
        return '';
      }
      final textos = _valoresSeleccionados.map((valor) {
        final opcion = widget.opciones.firstWhere(
          (o) => o.valor == valor,
          orElse: () => OpcionSelector(valor: valor, etiqueta: valor.toString()),
        );
        return opcion.etiqueta;
      }).toList();
      
      if (textos.length <= 2) {
        return textos.join(', ');
      } else {
        return '${textos.take(2).join(', ')} (+${textos.length - 2})';
      }
    } else {
      if (_valorSeleccionado == null) {
        return '';
      }
      final opcion = widget.opciones.firstWhere(
        (o) => o.valor == _valorSeleccionado,
        orElse: () => OpcionSelector(valor: _valorSeleccionado!, etiqueta: _valorSeleccionado.toString()),
      );
      return opcion.etiqueta;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esMobile = ResponsiveHelper.esMobile(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.etiqueta != null) ...[
          Row(
            children: [
              Text(
                widget.etiqueta!,
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(context, base: 14),
                  fontWeight: FontWeight.w600,
                  color: ColoresApp.textoNegro,
                ),
              ),
              if (widget.requerido)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: ColoresApp.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          SizedBox(height: esMobile ? 6 : 8),
        ],
        
        if (!widget.busquedaHabilitada && !widget.multiseleccion)
          DropdownButtonFormField<T>(
            value: _valorSeleccionado,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.placeholder,
              filled: true,
              fillColor: widget.habilitado 
                  ? (_tieneFoco ? Colors.white : ColoresApp.fondoBlanco)
                  : ColoresApp.fondoSecundario,
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.valor(context, mobile: 12, tablet: 14, desktop: 16),
                vertical: ResponsiveHelper.valor(context, mobile: 12, tablet: 14, desktop: 16),
              ),
              prefixIcon: widget.iconoPrefijo,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ColoresApp.borde),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ColoresApp.borde, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ColoresApp.primario, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ColoresApp.bordeClaro, width: 1),
              ),
            ),
            dropdownColor: ColoresApp.fondoBlanco,
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(context, base: 16),
              color: ColoresApp.textoNegro,
            ),
            icon: Icon(
              Icons.arrow_drop_down,
              size: ResponsiveHelper.valor(context, mobile: 24, tablet: 26, desktop: 28),
            ),
            isExpanded: true,
            items: widget.opciones.map((opcion) {
              return DropdownMenuItem<T>(
                value: opcion.valor,
                enabled: opcion.habilitado,
                child: Row(
                  children: [
                    if (opcion.icono != null) ...[
                      Icon(
                        opcion.icono,
                        size: ResponsiveHelper.valor(context, mobile: 18, tablet: 20, desktop: 22),
                        color: opcion.color ?? ColoresApp.textoGris,
                      ),
                    ],
                    Text(opcion.etiqueta),
                  ],
                ),
              );
            }).toList(),
            onChanged: widget.habilitado 
                ? (valor) {
                    setState(() {
                      _valorSeleccionado = valor;
                    });
                    if (widget.onChanged != null) {
                      widget.onChanged!(valor);
                    }
                  }
                : null,
            validator: widget.validador,
          )
        else
          InkWell(
            onTap: widget.habilitado ? _mostrarOpciones : null,
            child: InputDecorator(
              decoration: InputDecoration(
                hintText: widget.placeholder,
                filled: true,
                fillColor: widget.habilitado 
                    ? ColoresApp.fondoBlanco
                    : ColoresApp.fondoSecundario,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.valor(context, mobile: 12, tablet: 14, desktop: 16),
                  vertical: ResponsiveHelper.valor(context, mobile: 12, tablet: 14, desktop: 16),
                ),
                prefixIcon: widget.iconoPrefijo,
                suffixIcon: Icon(
                  Icons.arrow_drop_down,
                  size: ResponsiveHelper.valor(context, mobile: 24, tablet: 26, desktop: 28),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: ColoresApp.borde),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: ColoresApp.borde, width: 1),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: ColoresApp.bordeClaro, width: 1),
                ),
              ),
              isEmpty: _obtenerTextoMostrado().isEmpty,
              child: Text(
                _obtenerTextoMostrado().isEmpty 
                    ? widget.placeholder ?? '' 
                    : _obtenerTextoMostrado(),
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(context, base: 16),
                  color: _obtenerTextoMostrado().isEmpty 
                      ? ColoresApp.textoGrisClaro 
                      : ColoresApp.textoNegro,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Clase para las opciones del selector
class OpcionSelector<T> {
  final T valor;
  final String etiqueta;
  final String? subtitulo;
  final IconData? icono;
  final Color? color;
  final bool habilitado;

  OpcionSelector({
    required this.valor,
    required this.etiqueta,
    this.subtitulo,
    this.icono,
    this.color,
    this.habilitado = true,
  });
}

// Diálogo para búsqueda y multiselección
class _DialogoOpciones<T> extends StatefulWidget {
  final List<OpcionSelector<T>> opciones;
  final T? valorSeleccionado;
  final List<T> valoresSeleccionados;
  final bool busquedaHabilitada;
  final bool multiseleccion;
  final String titulo;

  const _DialogoOpciones({
    super.key,
    required this.opciones,
    this.valorSeleccionado,
    required this.valoresSeleccionados,
    required this.busquedaHabilitada,
    required this.multiseleccion,
    required this.titulo,
  });

  @override
  State<_DialogoOpciones<T>> createState() => __DialogoOpcionesState<T>();
}

class __DialogoOpcionesState<T> extends State<_DialogoOpciones<T>> {
  late List<OpcionSelector<T>> _opcionesFiltradas;
  final TextEditingController _controladorBusqueda = TextEditingController();
  late List<T> _valoresSeleccionadosTemp;
  T? _valorSeleccionadoTemp;

  @override
  void initState() {
    super.initState();
    _opcionesFiltradas = widget.opciones;
    _valoresSeleccionadosTemp = List.from(widget.valoresSeleccionados);
    _valorSeleccionadoTemp = widget.valorSeleccionado;
  }

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  void _filtrarOpciones(String busqueda) {
    setState(() {
      if (busqueda.isEmpty) {
        _opcionesFiltradas = widget.opciones;
      } else {
        _opcionesFiltradas = widget.opciones.where((opcion) {
          return opcion.etiqueta.toLowerCase().contains(busqueda.toLowerCase()) ||
                 (opcion.subtitulo?.toLowerCase().contains(busqueda.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool esMobile = ResponsiveHelper.esMobile(context);
    final ancho = ResponsiveHelper.anchoPantalla(context);
    final alto = ResponsiveHelper.altoPantalla(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: esMobile ? ancho * 0.9 : ancho * 0.5,
        height: alto * 0.7,
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Column(
          children: [
            // Encabezado
            Container(
              padding: EdgeInsets.all(ResponsiveHelper.valor(context, mobile: 16, desktop: 20)),
              decoration: const BoxDecoration(
                color: ColoresApp.fondoPrimario,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.titulo,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.fontSize(context, base: 18),
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoBlanco,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: ColoresApp.textoBlanco),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Campo de búsqueda
            if (widget.busquedaHabilitada)
              Padding(
                padding: EdgeInsets.all(ResponsiveHelper.valor(context, mobile: 12, desktop: 16)),
                child: TextField(
                  controller: _controladorBusqueda,
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.valor(context, mobile: 12, desktop: 16),
                      vertical: ResponsiveHelper.valor(context, mobile: 10, desktop: 12),
                    ),
                  ),
                  onChanged: _filtrarOpciones,
                ),
              ),
            
            // Lista de opciones
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveHelper.valor(context, mobile: 8, desktop: 12),
                ),
                itemCount: _opcionesFiltradas.length,
                itemBuilder: (context, index) {
                  final opcion = _opcionesFiltradas[index];
                  final bool seleccionado = widget.multiseleccion
                      ? _valoresSeleccionadosTemp.contains(opcion.valor)
                      : _valorSeleccionadoTemp == opcion.valor;
                  
                  return ListTile(
                    leading: opcion.icono != null
                        ? Icon(
                            opcion.icono,
                            color: opcion.color ?? ColoresApp.textoGris,
                          )
                        : null,
                    title: Text(opcion.etiqueta),
                    subtitle: opcion.subtitulo != null
                        ? Text(opcion.subtitulo!)
                        : null,
                    trailing: widget.multiseleccion
                        ? Checkbox(
                            value: seleccionado,
                            onChanged: opcion.habilitado
                                ? (valor) {
                                    setState(() {
                                      if (valor ?? false) {
                                        _valoresSeleccionadosTemp.add(opcion.valor);
                                      } else {
                                        _valoresSeleccionadosTemp.remove(opcion.valor);
                                      }
                                    });
                                  }
                                : null,
                          )
                        : seleccionado
                            ? const Icon(Icons.check, color: ColoresApp.primario)
                            : null,
                    enabled: opcion.habilitado,
                    onTap: opcion.habilitado
                        ? () {
                            if (widget.multiseleccion) {
                              setState(() {
                                if (_valoresSeleccionadosTemp.contains(opcion.valor)) {
                                  _valoresSeleccionadosTemp.remove(opcion.valor);
                                } else {
                                  _valoresSeleccionadosTemp.add(opcion.valor);
                                }
                              });
                            } else {
                              Navigator.of(context).pop(opcion.valor);
                            }
                          }
                        : null,
                  );
                },
              ),
            ),
            
            // Botones de acción para multiselección
            if (widget.multiseleccion)
              Container(
                padding: EdgeInsets.all(ResponsiveHelper.valor(context, mobile: 12, desktop: 16)),
                decoration: BoxDecoration(
                  color: ColoresApp.fondoSecundario,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    SizedBox(width: ResponsiveHelper.valor(context, mobile: 8, desktop: 12)),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_valoresSeleccionadosTemp),
                      child: Text(
                        'Aceptar (${_valoresSeleccionadosTemp.length})',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}