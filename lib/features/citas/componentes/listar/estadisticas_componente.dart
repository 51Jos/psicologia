import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psicologia/features/citas/modelos/cita_modelo.dart';
import '../../controlador/cita_controlador.dart';

class EstadisticasComponente extends StatelessWidget {
  const EstadisticasComponente({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CitaControlador>(
      builder: (context, controlador, child) {
        final stats = controlador.estadisticas;

        return Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estadísticas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: _getCrossAxisCount(context),
                childAspectRatio: 2.5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildStatCard(
                    'Total Registros',
                    stats.totalRegistros.toString(),
                    const Color(0xFF667EEA),
                    Icons.assignment,
                  ),
                  _buildStatCard(
                    'FC',
                    (stats.porFacultad['FC'] ?? 0).toString(),
                    const Color(0xFF48BB78),
                    Icons.science,
                  ),
                  _buildStatCard(
                    'FCS',
                    (stats.porFacultad['FCS'] ?? 0).toString(),
                    const Color(0xFFEF4444),
                    Icons.psychology,
                  ),
                  _buildStatCard(
                    'FEI',
                    (stats.porFacultad['FEI'] ?? 0).toString(),
                    const Color(0xFF4299E1),
                    Icons.engineering,
                  ),
                  _buildStatCard(
                    'FCE',
                    (stats.porFacultad['FCE'] ?? 0).toString(),
                    const Color(0xFFED8936),
                    Icons.business,
                  ),
                  _buildStatCard(
                    'Primeras Atenciones',
                    stats.primerasAtenciones.toString(),
                    const Color(0xFF10B981),
                    Icons.new_label,
                  ),
                  _buildStatCard(
                    'Seguimientos',
                    stats.seguimientos.toString(),
                    const Color(0xFF8B5CF6),
                    Icons.refresh,
                  ),
                  _buildStatCard(
                    'Programadas',
                    (stats.porEstado[EstadoCita.programada] ?? 0).toString(),
                    const Color(0xFF4299E1),
                    Icons.schedule,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF718096),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 2;
  }
}