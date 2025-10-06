import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../modelos/cita_modelo.dart';

class TarjetasCitasComponente extends StatelessWidget {
  final List<CitaModelo> citas;
  final Function(CitaModelo) onVerDetalles;
  final Function(CitaModelo) onEditar;
  final Function(CitaModelo) onEliminar;

  const TarjetasCitasComponente({
    super.key,
    required this.citas,
    required this.onVerDetalles,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    if (citas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: Color(0xFF718096),
              ),
              SizedBox(height: 16),
              Text(
                'No se encontraron citas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A5568),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Intenta ajustar los filtros de búsqueda',
                style: TextStyle(
                  color: Color(0xFF718096),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: citas.length,
      itemBuilder: (context, index) {
        final cita = citas[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCitaCard(cita),
        );
      },
    );
  }

  Widget _buildCitaCard(CitaModelo cita) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de la tarjeta
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cita.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildFacultadBadge(cita.facultad),
                    ],
                  ),
                ),
                _buildEstadoIndicator(cita.estado),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 12),
            // Información de la cita
            _buildInfoRow('Programa:', cita.programa),
            _buildInfoRow('Motivo:', cita.motivoConsulta),
            _buildInfoRow('Atención:', '${cita.primeraVez ? "#01" : "#02+"} - ${DateFormat('dd/MM/yyyy').format(cita.fechaHora)}'),
            _buildInfoRow('Turno:', _obtenerTurno(cita.fechaHora)),
            if (cita.estudianteTelefono?.isNotEmpty == true)
              _buildInfoRow('Teléfono:', cita.estudianteTelefono!),
            if (cita.estudianteEmail?.isNotEmpty == true)
              _buildInfoRow('Email:', cita.estudianteEmail!),
            if (cita.observaciones?.isNotEmpty == true)
              _buildInfoRow('Observaciones:', cita.observaciones!),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 12),
            // Acciones
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Ver',
                    Icons.visibility,
                    const Color(0xFF48BB78),
                    () => onVerDetalles(cita),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'Editar',
                    Icons.edit,
                    const Color(0xFF4299E1),
                    () => onEditar(cita),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'Eliminar',
                    Icons.delete,
                    const Color(0xFFEF4444),
                    () => onEliminar(cita),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _obtenerTurno(DateTime fecha) {
    final hora = fecha.hour;
    if (hora >= 6 && hora < 12) {
      return 'Mañana';
    } else if (hora >= 12 && hora < 18) {
      return 'Tarde';
    } else {
      return 'Noche';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF718096),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultadBadge(String facultad) {
    Color backgroundColor;
    Color textColor;

    switch (facultad.toUpperCase()) {
      case 'FC':
        backgroundColor = const Color(0xFFC6F6D5);
        textColor = const Color(0xFF22543D);
        break;
      case 'FCS':
        backgroundColor = const Color(0xFFFED7D7);
        textColor = const Color(0xFF742A2A);
        break;
      case 'FEI':
        backgroundColor = const Color(0xFFBEE3F8);
        textColor = const Color(0xFF2C5282);
        break;
      case 'FCE':
        backgroundColor = const Color(0xFFFEEBC8);
        textColor = const Color(0xFF744210);
        break;
      default:
        backgroundColor = const Color(0xFFE2E8F0);
        textColor = const Color(0xFF4A5568);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        facultad,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEstadoIndicator(EstadoCita estado) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: estado.color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildActionButton(
    String texto,
    IconData icono,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icono, size: 16),
      label: Text(texto),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

}