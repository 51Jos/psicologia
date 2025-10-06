import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../modelos/cita_modelo.dart';
import '../../../../compartidos/tema/colores_app.dart';

class DetalleCitaComponente extends StatelessWidget {
  final CitaModelo cita;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  const DetalleCitaComponente({
    super.key,
    required this.cita,
    this.onEditar,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estado y acciones
            _buildHeader(context),
            const SizedBox(height: 24),

            // Información del estudiante
            _buildSeccion(
              titulo: 'Información del Estudiante',
              icono: Icons.person,
              color: ColoresApp.primario,
              children: [
                _buildInfoRow('Nombre completo', cita.nombreCompleto, Icons.badge),
                if (cita.estudianteCodigo != null)
                  _buildInfoRow('Código', cita.estudianteCodigo!, Icons.numbers),
                _buildInfoRow('Facultad', cita.facultad, Icons.school),
                _buildInfoRow('Programa', cita.programa, Icons.book),
                if (cita.estudianteEmail != null)
                  _buildInfoRow('Email', cita.estudianteEmail!, Icons.email),
                if (cita.estudianteTelefono != null)
                  _buildInfoRow('Teléfono', cita.estudianteTelefono!, Icons.phone),
              ],
            ),

            const SizedBox(height: 20),

            // Información de la cita
            _buildSeccion(
              titulo: 'Información de la Cita',
              icono: Icons.event_note,
              color: const Color(0xFF8B5CF6),
              children: [
                _buildInfoRow(
                  'Fecha y Hora',
                  DateFormat('EEEE, dd MMMM yyyy - HH:mm', 'es').format(cita.fechaHora),
                  Icons.calendar_today,
                ),
                _buildInfoRow('Duración', cita.duracion.texto, Icons.timer),
                _buildInfoRow('Tipo de Cita', cita.tipoCita.texto, cita.tipoCita.icono),
                _buildInfoRow('Turno', _obtenerTurno(cita.fechaHora), Icons.wb_sunny),
                _buildInfoRow(
                  'Primera Consulta',
                  cita.primeraVez ? 'Sí (Consulta inicial)' : 'No (Seguimiento)',
                  cita.primeraVez ? Icons.star : Icons.replay,
                ),
                _buildInfoRow('Psicólogo', cita.psicologoId, Icons.psychology),
              ],
            ),

            const SizedBox(height: 20),

            // Motivo de consulta
            _buildSeccion(
              titulo: 'Motivo de Consulta',
              icono: Icons.description,
              color: const Color(0xFFEF4444),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColoresApp.fondoSecundario,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColoresApp.borde),
                  ),
                  child: Text(
                    cita.motivoConsulta,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: ColoresApp.textoNegro,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Observaciones (si existen)
            if (cita.observaciones != null && cita.observaciones!.isNotEmpty)
              _buildSeccion(
                titulo: 'Observaciones',
                icono: Icons.notes,
                color: const Color(0xFFF59E0B),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Text(
                      cita.observaciones!,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Color(0xFF78350F),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // Metadatos
            _buildSeccion(
              titulo: 'Información del Registro',
              icono: Icons.info,
              color: ColoresApp.textoGris,
              children: [
                _buildInfoRow(
                  'Fecha de creación',
                  DateFormat('dd/MM/yyyy HH:mm').format(cita.fechaCreacion),
                  Icons.access_time,
                ),
                _buildInfoRow('ID de la cita', cita.id.isEmpty ? 'Nuevo' : cita.id, Icons.fingerprint),
              ],
            ),

            const SizedBox(height: 24),

            // Botones de acción
            _buildAcciones(context),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cita.estado.color.withOpacity(0.1),
            cita.estado.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cita.estado.color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cita.estado.color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              cita.estado.icono,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de la Cita',
                  style: TextStyle(
                    fontSize: 13,
                    color: ColoresApp.textoGris,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cita.estado.texto,
                  style: TextStyle(
                    fontSize: 20,
                    color: cita.estado.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (cita.primeraVez)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Color(0xFF16A34A), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Primera vez',
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSeccion({
    required String titulo,
    required IconData icono,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.borde),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la sección
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icono, color: color, size: 22),
                const SizedBox(width: 12),
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icono) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColoresApp.fondoSecundario,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, size: 18, color: ColoresApp.textoGris),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColoresApp.textoGris,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: ColoresApp.textoNegro,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcciones(BuildContext context) {
    return Row(
      children: [
        if (onEditar != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onEditar,
              icon: const Icon(Icons.edit, size: 20),
              label: const Text('Editar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColoresApp.primario,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
        if (onEditar != null && onEliminar != null) const SizedBox(width: 12),
        if (onEliminar != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onEliminar,
              icon: const Icon(Icons.delete, size: 20),
              label: const Text('Eliminar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
      ],
    );
  }

  String _obtenerTurno(DateTime fecha) {
    final hora = fecha.hour;
    if (hora >= 6 && hora < 12) {
      return '☀️ Mañana (6:00 - 12:00)';
    } else if (hora >= 12 && hora < 18) {
      return '🌤️ Tarde (12:00 - 18:00)';
    } else {
      return '🌙 Noche (18:00 - 6:00)';
    }
  }
}
