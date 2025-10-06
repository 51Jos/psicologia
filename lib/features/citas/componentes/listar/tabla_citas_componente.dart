import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../modelos/cita_modelo.dart';

class TablaCitasComponente extends StatelessWidget {
  final List<CitaModelo> citas;
  final Function(CitaModelo) onVerDetalles;
  final Function(CitaModelo) onEditar;
  final Function(CitaModelo) onEliminar;

  const TablaCitasComponente({
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

    return Container(
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          horizontalMargin: 20,
          headingRowColor: MaterialStateProperty.all(const Color(0xFFF7FAFC)),
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
            fontSize: 13,
          ),
          dataTextStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF2D3748),
          ),
          columns: const [
            DataColumn(
              label: SizedBox(
                width: 180,
                child: Text('NOMBRE Y APELLIDO'),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 80,
                child: Text('FACULTAD'),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 150,
                child: Text('PROGRAMA'),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 200,
                child: Text('MOTIVO/CONSULTA'),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 100,
                child: Text('N° ATENCIÓN'),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 100,
                child: Text('CIM'),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 80,
                child: Text('TURNO'),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 120,
                child: Text('TELÉFONO'),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 200,
                child: Text('EMAIL'),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 180,
                child: Text('OBSERVACIONES'),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 120,
                child: Text('ACCIONES'),
              ),
            ),
          ],
          rows: citas.map((cita) => DataRow(
            cells: [
              DataCell(
                SizedBox(
                  width: 180,
                  child: Text(
                    cita.nombreCompleto,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 80,
                  child: _buildFacultadBadge(cita.facultad),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 150,
                  child: Text(
                    cita.programa,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 200,
                  child: Text(
                    cita.motivoConsulta,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 100,
                  child: Text(cita.primeraVez ? '01' : '02+'),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 100,
                  child: Text(DateFormat('dd/MM/yyyy').format(cita.fechaHora)),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 80,
                  child: Text(_obtenerTurno(cita.fechaHora)),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 120,
                  child: Text(
                    cita.estudianteTelefono ?? '',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 200,
                  child: Text(
                    cita.estudianteEmail ?? '',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 180,
                  child: Text(
                    cita.observaciones ?? '-',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 120,
                  child: _buildAcciones(cita),
                ),
              ),
            ],
          )).toList(),
        ),
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

  Widget _buildAcciones(CitaModelo cita) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => onVerDetalles(cita),
          icon: const Icon(Icons.visibility, color: Color(0xFF48BB78)),
          tooltip: 'Ver detalles',
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        IconButton(
          onPressed: () => onEditar(cita),
          icon: const Icon(Icons.edit, color: Color(0xFF4299E1)),
          tooltip: 'Editar',
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        IconButton(
          onPressed: () => onEliminar(cita),
          icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
          tooltip: 'Eliminar',
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
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

}