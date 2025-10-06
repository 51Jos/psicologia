import 'package:flutter/material.dart';
import '../tema/colores_app.dart';

enum EstadoModal {
  cargando,
  exito,
  error,
}

class ModalCarga extends StatelessWidget {
  final String mensaje;
  final bool mostrar;
  final EstadoModal estado;

  const ModalCarga({
    super.key,
    this.mensaje = 'Cargando...',
    this.mostrar = true,
    this.estado = EstadoModal.cargando,
  });

  static void mostrarModal(BuildContext context, {String mensaje = 'Cargando...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => ModalCarga(mensaje: mensaje),
    );
  }

  static void mostrarExito(BuildContext context, {String mensaje = 'Operación exitosa'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => ModalCarga(
        mensaje: mensaje,
        estado: EstadoModal.exito,
      ),
    );
  }

  static void mostrarError(BuildContext context, {String mensaje = 'Ha ocurrido un error'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => ModalCarga(
        mensaje: mensaje,
        estado: EstadoModal.error,
      ),
    );
  }

  static void ocultarModal(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!mostrar) return const SizedBox.shrink();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador según el estado
            _buildIndicador(),
            const SizedBox(height: 24),
            // Mensaje
            Text(
              mensaje,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A5568),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Submensaje según estado
            Text(
              _getSubmensaje(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            // Botón de cerrar para éxito/error
            if (estado != EstadoModal.cargando) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: estado == EstadoModal.exito
                      ? ColoresApp.exito
                      : ColoresApp.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Entendido',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIndicador() {
    switch (estado) {
      case EstadoModal.cargando:
        return Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(ColoresApp.primario),
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF667EEA),
                    Color(0xFF764BA2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColoresApp.primario.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.hourglass_empty,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        );

      case EstadoModal.exito:
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColoresApp.exito,
            boxShadow: [
              BoxShadow(
                color: ColoresApp.exito.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: Colors.white,
            size: 50,
          ),
        );

      case EstadoModal.error:
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColoresApp.error,
            boxShadow: [
              BoxShadow(
                color: ColoresApp.error.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 50,
          ),
        );
    }
  }

  String _getSubmensaje() {
    switch (estado) {
      case EstadoModal.cargando:
        return 'Por favor espera...';
      case EstadoModal.exito:
        return '¡Todo salió bien!';
      case EstadoModal.error:
        return 'Por favor, intenta nuevamente';
    }
  }
}

// Widget para usar dentro del árbol de widgets
class OverlayCarga extends StatelessWidget {
  final bool cargando;
  final String mensaje;
  final Widget child;

  const OverlayCarga({
    super.key,
    required this.cargando,
    required this.child,
    this.mensaje = 'Cargando...',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (cargando)
          Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(ColoresApp.primario),
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF667EEA),
                                Color(0xFF764BA2),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ColoresApp.primario.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.hourglass_empty,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      mensaje,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A5568),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Por favor espera...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
