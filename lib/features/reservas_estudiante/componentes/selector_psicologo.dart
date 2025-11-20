import 'package:flutter/material.dart';
import '../../autenticacion/modelos/usuario.dart';
import '../../../compartidos/tema/colores_app.dart';

class SelectorPsicologo extends StatelessWidget {
  final List<UsuarioModelo> psicologos;
  final UsuarioModelo? psicologoSeleccionado;
  final Function(UsuarioModelo?) onChanged;
  final bool cargando;

  const SelectorPsicologo({
    super.key,
    required this.psicologos,
    required this.psicologoSeleccionado,
    required this.onChanged,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: ColoresApp.primario),
                const SizedBox(width: 8),
                Text(
                  'Seleccionar Psicólogo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (psicologos.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No hay psicólogos disponibles en este momento'),
                ),
              )
            else
              DropdownButtonFormField<UsuarioModelo>(
                value: psicologoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Psicólogo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.psychology),
                ),
                items: psicologos.map((psicologo) {
                  return DropdownMenuItem<UsuarioModelo>(
                    value: psicologo,
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min, // <-- evita ancho infinito
                      children: [
                        CircleAvatar(
                          backgroundColor: ColoresApp.primario,
                          child: Text(
                            psicologo.iniciales,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          // <-- en lugar de Expanded
                          fit: FlexFit.loose,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                psicologo.nombreCompleto,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                psicologo.email,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                validator: (value) {
                  if (value == null) {
                    return 'Por favor seleccione un psicólogo';
                  }
                  return null;
                },
              ),
          ],
        ),
      ),
    );
  }
}
