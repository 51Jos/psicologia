import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psicologia/compartidos/componentes/campo_selector.dart';
import 'package:psicologia/compartidos/componentes/campo_texto.dart';
import 'package:psicologia/compartidos/tema/colores_app.dart';
import 'package:psicologia/compartidos/utilidades/formateadores.dart';
import 'package:psicologia/compartidos/utilidades/responsive_helper.dart';
import 'package:psicologia/compartidos/utilidades/validadores.dart';
import '../modelos/estudiante_modelo.dart';

class DatosEstudianteCard extends StatelessWidget {
  final TextEditingController busquedaEstudianteController;
  final TextEditingController codigoController;
  final TextEditingController nombresController;
  final TextEditingController apellidosController;
  final TextEditingController emailController;
  final TextEditingController telefonoController;
  final TextEditingController facultadController;
  final TextEditingController programaController;
  final bool datosEstudianteBloqueados;
  final bool buscandoEstudiante;
  final List<EstudianteModelo> estudiantesSugeridos;
  final Function(EstudianteModelo) onSeleccionarEstudiante;
  final VoidCallback onLimpiarEstudiante;

  const DatosEstudianteCard({
    Key? key,
    required this.busquedaEstudianteController,
    required this.codigoController,
    required this.nombresController,
    required this.apellidosController,
    required this.emailController,
    required this.telefonoController,
    required this.facultadController,
    required this.programaController,
    required this.datosEstudianteBloqueados,
    required this.buscandoEstudiante,
    required this.estudiantesSugeridos,
    required this.onSeleccionarEstudiante,
    required this.onLimpiarEstudiante,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool esMobile = ResponsiveHelper.esMobile(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          ResponsiveHelper.valor(context, mobile: 16, tablet: 20, desktop: 24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: ColoresApp.primario, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Datos del Estudiante',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(context, base: 18),
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.primario,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildBuscadorEstudiante(context),
            const SizedBox(height: 16),
            if (esMobile)
              ..._buildCamposEstudianteMobile()
            else
              ..._buildCamposEstudianteDesktop(),
          ],
        ),
      ),
    );
  }

  Widget _buildBuscadorEstudiante(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CampoTexto(
                etiqueta: 'Buscar Estudiante',
                placeholder: 'Escriba el nombre, apellido o código del estudiante...',
                controlador: busquedaEstudianteController,
                habilitado: !datosEstudianteBloqueados,
                iconoPrefijo: Icons.search,
                iconoSufijo: datosEstudianteBloqueados ? Icons.lock : null,
              ),
            ),
            if (datosEstudianteBloqueados) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, color: ColoresApp.primario),
                onPressed: onLimpiarEstudiante,
                tooltip: 'Cambiar estudiante',
              ),
            ],
          ],
        ),
        if (estudiantesSugeridos.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: estudiantesSugeridos.map((estudiante) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: ColoresApp.primario.withOpacity(0.1),
                    child: Text(
                      estudiante.iniciales,
                      style: const TextStyle(
                        color: ColoresApp.primario,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(estudiante.nombreCompleto),
                  subtitle: Text('${estudiante.codigo} - ${estudiante.programa}'),
                  trailing: Chip(
                    label: Text(
                      estudiante.facultad,
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: ColoresApp.primario.withOpacity(0.1),
                  ),
                  onTap: () => onSeleccionarEstudiante(estudiante),
                );
              }).toList(),
            ),
          ),
        if (buscandoEstudiante)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildCamposEstudianteMobile() {
    return [
      CampoTexto(
        etiqueta: 'Código',
        placeholder: 'Código del estudiante',
        controlador: codigoController,
        habilitado: !datosEstudianteBloqueados,
        requerido: true,
        tipoTeclado: TextInputType.number,
        formateadores: [FilteringTextInputFormatter.digitsOnly],
        validador: Validadores.codigoEstudiante,
      ),
      const SizedBox(height: 16),
      CampoTexto(
        etiqueta: 'Nombres',
        placeholder: 'Nombres del estudiante',
        controlador: nombresController,
        habilitado: !datosEstudianteBloqueados,
        requerido: true,
        validador: (valor) => Validadores.nombres(valor, campo: 'Nombres'),
      ),
      const SizedBox(height: 16),
      CampoTexto(
        etiqueta: 'Apellidos',
        placeholder: 'Apellidos del estudiante',
        controlador: apellidosController,
        habilitado: !datosEstudianteBloqueados,
        requerido: true,
        validador: (valor) => Validadores.nombres(valor, campo: 'Apellidos'),
      ),
      const SizedBox(height: 16),
      CampoTexto(
        etiqueta: 'Email',
        placeholder: 'correo@ejemplo.com',
        controlador: emailController,
        habilitado: !datosEstudianteBloqueados,
        requerido: true,
        tipoTeclado: TextInputType.emailAddress,
        validador: Validadores.email,
      ),
      const SizedBox(height: 16),
      CampoTexto(
        etiqueta: 'Teléfono',
        placeholder: '999 999 999',
        controlador: telefonoController,
        habilitado: !datosEstudianteBloqueados,
        tipoTeclado: TextInputType.phone,
        formateadores: [TelefonoInputFormatter()],
        validador: (valor) => Validadores.telefono(valor, opcional: true),
      ),
      const SizedBox(height: 16),
      CampoSelector<String>(
        etiqueta: 'Facultad',
        placeholder: 'Seleccione la facultad',
        valorInicial: facultadController.text.isEmpty ? null : facultadController.text,
        opciones: _obtenerOpcionesFacultades(),
        onChanged: (valor) => facultadController.text = valor ?? '',
        requerido: true,
        habilitado: !datosEstudianteBloqueados,
        validador: (valor) => Validadores.seleccion(valor, campo: 'la facultad'),
      ),
      const SizedBox(height: 16),
      CampoTexto(
        etiqueta: 'Programa',
        placeholder: 'Programa académico',
        controlador: programaController,
        habilitado: !datosEstudianteBloqueados,
        requerido: true,
        validador: (valor) => Validadores.requerido(valor, campo: 'El programa'),
      ),
    ];
  }

  List<Widget> _buildCamposEstudianteDesktop() {
    return [
      Row(
        children: [
          Expanded(
            flex: 2,
            child: CampoTexto(
              etiqueta: 'Código',
              placeholder: 'Código del estudiante',
              controlador: codigoController,
              habilitado: !datosEstudianteBloqueados,
              requerido: true,
              tipoTeclado: TextInputType.number,
              formateadores: [FilteringTextInputFormatter.digitsOnly],
              validador: Validadores.codigoEstudiante,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: CampoTexto(
              etiqueta: 'Nombres',
              placeholder: 'Nombres del estudiante',
              controlador: nombresController,
              habilitado: !datosEstudianteBloqueados,
              requerido: true,
              validador: (valor) => Validadores.nombres(valor, campo: 'Nombres'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: CampoTexto(
              etiqueta: 'Apellidos',
              placeholder: 'Apellidos del estudiante',
              controlador: apellidosController,
              habilitado: !datosEstudianteBloqueados,
              requerido: true,
              validador: (valor) => Validadores.nombres(valor, campo: 'Apellidos'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: CampoTexto(
              etiqueta: 'Email',
              placeholder: 'correo@ejemplo.com',
              controlador: emailController,
              habilitado: !datosEstudianteBloqueados,
              requerido: true,
              tipoTeclado: TextInputType.emailAddress,
              validador: Validadores.email,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CampoTexto(
              etiqueta: 'Teléfono',
              placeholder: '999 999 999',
              controlador: telefonoController,
              habilitado: !datosEstudianteBloqueados,
              tipoTeclado: TextInputType.phone,
              formateadores: [TelefonoInputFormatter()],
              validador: (valor) => Validadores.telefono(valor, opcional: true),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: CampoSelector<String>(
              etiqueta: 'Facultad',
              placeholder: 'Seleccione la facultad',
              valorInicial: facultadController.text.isEmpty ? null : facultadController.text,
              opciones: _obtenerOpcionesFacultades(),
              onChanged: (valor) => facultadController.text = valor ?? '',
              requerido: true,
              habilitado: !datosEstudianteBloqueados,
              validador: (valor) => Validadores.seleccion(valor, campo: 'la facultad'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CampoTexto(
              etiqueta: 'Programa',
              placeholder: 'Programa académico',
              controlador: programaController,
              habilitado: !datosEstudianteBloqueados,
              requerido: true,
              validador: (valor) => Validadores.requerido(valor, campo: 'El programa'),
            ),
          ),
        ],
      ),
    ];
  }

  List<OpcionSelector<String>> _obtenerOpcionesFacultades() {
    return [
      OpcionSelector(valor: 'FC', etiqueta: 'FC - Ciencias'),
      OpcionSelector(valor: 'FCS', etiqueta: 'FCS - Ciencias Sociales'),
      OpcionSelector(valor: 'FEI', etiqueta: 'FEI - Ingeniería'),
      OpcionSelector(valor: 'FCE', etiqueta: 'FCE - Economía'),
    ];
  }
}