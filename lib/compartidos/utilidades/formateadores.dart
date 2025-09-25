import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class Formateadores {
  // Prevenir instanciación
  Formateadores._();

  // Formateadores de fecha
  static final DateFormat _fechaCorta = DateFormat('dd/MM/yyyy');
  static final DateFormat _fechaLarga = DateFormat('EEEE, d \'de\' MMMM \'de\' yyyy', 'es');
  static final DateFormat _fechaMedia = DateFormat('d \'de\' MMM \'de\' yyyy', 'es');
  static final DateFormat _soloMesAnio = DateFormat('MMMM yyyy', 'es');
  static final DateFormat _soloDia = DateFormat('EEEE', 'es');
  static final DateFormat _fechaHora = DateFormat('dd/MM/yyyy HH:mm');
  
  // Formateadores de hora
  static final DateFormat _hora24 = DateFormat('HH:mm');
  static final DateFormat _hora12 = DateFormat('h:mm a');

  // Formatear fecha
  static String fecha(DateTime? fecha, {String formato = 'corta'}) {
    if (fecha == null) return '';
    
    switch (formato) {
      case 'larga':
        return _fechaLarga.format(fecha);
      case 'media':
        return _fechaMedia.format(fecha);
      case 'mes':
        return _soloMesAnio.format(fecha);
      case 'dia':
        return _soloDia.format(fecha);
      case 'fechaHora':
        return _fechaHora.format(fecha);
      default:
        return _fechaCorta.format(fecha);
    }
  }

  // Formatear hora
  static String hora(DateTime? hora, {bool formato24 = true}) {
    if (hora == null) return '';
    
    return formato24 ? _hora24.format(hora) : _hora12.format(hora);
  }

  // Formatear fecha relativa
  static String fechaRelativa(DateTime? fecha) {
    if (fecha == null) return '';
    
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);
    
    if (diferencia.inDays == 0) {
      if (diferencia.inHours == 0) {
        if (diferencia.inMinutes == 0) {
          return 'Hace un momento';
        }
        return 'Hace ${diferencia.inMinutes} ${diferencia.inMinutes == 1 ? 'minuto' : 'minutos'}';
      }
      return 'Hace ${diferencia.inHours} ${diferencia.inHours == 1 ? 'hora' : 'horas'}';
    } else if (diferencia.inDays == 1) {
      return 'Ayer';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} días';
    } else if (diferencia.inDays < 30) {
      final semanas = (diferencia.inDays / 7).floor();
      return 'Hace $semanas ${semanas == 1 ? 'semana' : 'semanas'}';
    } else if (diferencia.inDays < 365) {
      final meses = (diferencia.inDays / 30).floor();
      return 'Hace $meses ${meses == 1 ? 'mes' : 'meses'}';
    } else {
      final anios = (diferencia.inDays / 365).floor();
      return 'Hace $anios ${anios == 1 ? 'año' : 'años'}';
    }
  }

  // Formatear nombre completo
  static String nombreCompleto({
    String? nombres,
    String? apellidoPaterno,
    String? apellidoMaterno,
  }) {
    final partes = <String>[];
    
    if (nombres != null && nombres.trim().isNotEmpty) {
      partes.add(nombres.trim());
    }
    if (apellidoPaterno != null && apellidoPaterno.trim().isNotEmpty) {
      partes.add(apellidoPaterno.trim());
    }
    if (apellidoMaterno != null && apellidoMaterno.trim().isNotEmpty) {
      partes.add(apellidoMaterno.trim());
    }
    
    return partes.join(' ');
  }

  // Formatear iniciales
  static String iniciales({
    String? nombres,
    String? apellidos,
  }) {
    String resultado = '';
    
    if (nombres != null && nombres.trim().isNotEmpty) {
      resultado += nombres.trim()[0].toUpperCase();
    }
    if (apellidos != null && apellidos.trim().isNotEmpty) {
      resultado += apellidos.trim()[0].toUpperCase();
    }
    
    return resultado.isEmpty ? '?' : resultado;
  }

  // Formatear teléfono
  static String telefono(String? numero) {
    if (numero == null || numero.isEmpty) return '';
    
    // Limpiar el número
    String limpio = numero.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Formato peruano: 999 999 999
    if (limpio.length == 9) {
      return '${limpio.substring(0, 3)} ${limpio.substring(3, 6)} ${limpio.substring(6)}';
    }
    
    return limpio;
  }

  // Formatear código de estudiante
  static String codigoEstudiante(String? codigo) {
    if (codigo == null || codigo.isEmpty) return '';
    
    // Formato: 2019-1234
    if (codigo.length == 8) {
      return '${codigo.substring(0, 4)}-${codigo.substring(4)}';
    }
    
    return codigo;
  }

  // Capitalizar texto
  static String capitalizar(String? texto) {
    if (texto == null || texto.isEmpty) return '';
    
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  // Capitalizar cada palabra
  static String capitalizarCadaPalabra(String? texto) {
    if (texto == null || texto.isEmpty) return '';
    
    return texto.split(' ').map((palabra) => capitalizar(palabra)).join(' ');
  }

  // Formatear número de atención
  static String numeroAtencion(int? numero) {
    if (numero == null) return '';
    
    return numero.toString().padLeft(2, '0');
  }

  // Formatear estado/condición
  static String condicion(String? condicion) {
    if (condicion == null || condicion.isEmpty) return '';
    
    switch (condicion.toLowerCase()) {
      case 'iniciativa':
        return 'Por Iniciativa';
      case 'derivado':
        return 'Derivado';
      case 'entrevista':
        return 'Entrevista';
      default:
        return capitalizar(condicion);
    }
  }

  // Formatear turno
  static String turno(String? turno) {
    if (turno == null || turno.isEmpty) return '';
    
    switch (turno.toLowerCase()) {
      case 'manana':
      case 'mañana':
        return 'Mañana';
      case 'tarde':
        return 'Tarde';
      case 'noche':
        return 'Noche';
      default:
        return capitalizar(turno);
    }
  }

  // Truncar texto
  static String truncar(String? texto, int longitudMaxima, {String sufijo = '...'}) {
    if (texto == null || texto.isEmpty) return '';
    
    if (texto.length <= longitudMaxima) {
      return texto;
    }
    
    return '${texto.substring(0, longitudMaxima)}$sufijo';
  }

  // Formatear para URL
  static String paraUrl(String? texto) {
    if (texto == null || texto.isEmpty) return '';
    
    return texto
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[^a-z0-9]'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}

// Input Formatters personalizados
class TelefonoInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Eliminar todo lo que no sea número
    String nuevotexto = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limitar a 9 dígitos
    if (nuevotexto.length > 9) {
      nuevotexto = nuevotexto.substring(0, 9);
    }
    
    // Aplicar formato: 999 999 999
    String textoFormateado = '';
    for (int i = 0; i < nuevotexto.length; i++) {
      if (i == 3 || i == 6) {
        textoFormateado += ' ';
      }
      textoFormateado += nuevotexto[i];
    }
    
    return TextEditingValue(
      text: textoFormateado,
      selection: TextSelection.collapsed(offset: textoFormateado.length),
    );
  }
}

class CodigoEstudianteInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Eliminar todo lo que no sea número
    String nuevoTexto = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limitar a 8 dígitos
    if (nuevoTexto.length > 8) {
      nuevoTexto = nuevoTexto.substring(0, 8);
    }
    
    return TextEditingValue(
      text: nuevoTexto,
      selection: TextSelection.collapsed(offset: nuevoTexto.length),
    );
  }
}

class SoloLetrasInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Permitir solo letras y espacios
    final RegExp patron = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]*$');
    
    if (patron.hasMatch(newValue.text)) {
      return newValue;
    }
    
    return oldValue;
  }
}

class SoloNumerosInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Permitir solo números
    final RegExp patron = RegExp(r'^[0-9]*$');

    if (patron.hasMatch(newValue.text)) {
      return newValue;
    }
    
    return oldValue;
  }
}

class MayusculasInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class PrimeraLetraMayusculaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String texto = newValue.text;
    
    if (texto.isNotEmpty) {
      // Capitalizar después de cada espacio
      List<String> palabras = texto.split(' ');
      palabras = palabras.map((palabra) {
        if (palabra.isEmpty) return palabra;
        return palabra[0].toUpperCase() + palabra.substring(1).toLowerCase();
      }).toList();
      texto = palabras.join(' ');
    }
    
    return TextEditingValue(
      text: texto,
      selection: newValue.selection,
    );
  }
}