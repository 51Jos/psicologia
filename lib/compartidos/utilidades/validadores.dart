class Validadores {
  // Prevenir instanciación
  Validadores._();

  // Expresiones regulares
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _telefonoRegExp = RegExp(
    r'^[0-9]{9}$', // Formato peruano: 9 dígitos
  );

  static final RegExp _soloLetrasRegExp = RegExp(
    r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$',
  );

  static final RegExp _soloNumerosRegExp = RegExp(
    r'^[0-9]+$',
  );

  static final RegExp _codigoEstudianteRegExp = RegExp(
    r'^[0-9]{8}$', // 8 dígitos para código de estudiante
  );

  // Validador de campo requerido
  static String? requerido(String? valor, {String campo = 'Este campo'}) {
    if (valor == null || valor.trim().isEmpty) {
      return '$campo es requerido';
    }
    return null;
  }

  // Validador de email
  static String? email(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El email es requerido';
    }
    
    if (!_emailRegExp.hasMatch(valor.trim())) {
      return 'Ingrese un email válido';
    }
    
    return null;
  }

  // Validador de contraseña
  static String? password(String? valor, {int longitudMinima = 6}) {
    if (valor == null || valor.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (valor.length < longitudMinima) {
      return 'La contraseña debe tener al menos $longitudMinima caracteres';
    }
    
    // Opcional: agregar más validaciones (mayúsculas, números, etc.)
    if (!valor.contains(RegExp(r'[0-9]'))) {
      return 'La contraseña debe contener al menos un número';
    }
    
    if (!valor.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe contener al menos una mayúscula';
    }
    
    return null;
  }

  // Validador de confirmación de contraseña
  static String? confirmarPassword(String? valor, String password) {
    if (valor == null || valor.isEmpty) {
      return 'Por favor confirme su contraseña';
    }
    
    if (valor != password) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }

  // Validador de teléfono
  static String? telefono(String? valor, {bool opcional = false}) {
    if (opcional && (valor == null || valor.trim().isEmpty)) {
      return null;
    }
    
    if (valor == null || valor.trim().isEmpty) {
      return 'El teléfono es requerido';
    }
    
    String telefonoLimpio = valor.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (!_telefonoRegExp.hasMatch(telefonoLimpio)) {
      return 'Ingrese un número de teléfono válido (9 dígitos)';
    }
    
    return null;
  }

  // Validador de nombres y apellidos
  static String? nombres(String? valor, {String campo = 'Este campo'}) {
    if (valor == null || valor.trim().isEmpty) {
      return '$campo es requerido';
    }
    
    if (valor.trim().length < 2) {
      return '$campo debe tener al menos 2 caracteres';
    }
    
    if (!_soloLetrasRegExp.hasMatch(valor.trim())) {
      return '$campo solo debe contener letras';
    }
    
    return null;
  }

  // Validador de código de estudiante
  static String? codigoEstudiante(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El código de estudiante es requerido';
    }
    
    if (!_codigoEstudianteRegExp.hasMatch(valor.trim())) {
      return 'El código debe tener 8 dígitos';
    }
    
    return null;
  }

  // Validador de longitud mínima
  static String? longitudMinima(String? valor, int longitud, {String campo = 'Este campo'}) {
    if (valor == null || valor.trim().isEmpty) {
      return '$campo es requerido';
    }
    
    if (valor.trim().length < longitud) {
      return '$campo debe tener al menos $longitud caracteres';
    }
    
    return null;
  }

  // Validador de longitud máxima
  static String? longitudMaxima(String? valor, int longitud, {String campo = 'Este campo'}) {
    if (valor != null && valor.length > longitud) {
      return '$campo no debe exceder $longitud caracteres';
    }
    
    return null;
  }

  // Validador de rango de longitud
  static String? rangoLongitud(
    String? valor,
    int min,
    int max, {
    String campo = 'Este campo',
  }) {
    if (valor == null || valor.trim().isEmpty) {
      return '$campo es requerido';
    }
    
    if (valor.trim().length < min || valor.trim().length > max) {
      return '$campo debe tener entre $min y $max caracteres';
    }
    
    return null;
  }

  // Validador de solo números
  static String? soloNumeros(String? valor, {String campo = 'Este campo'}) {
    if (valor == null || valor.trim().isEmpty) {
      return '$campo es requerido';
    }
    
    if (!_soloNumerosRegExp.hasMatch(valor.trim())) {
      return '$campo solo debe contener números';
    }
    
    return null;
  }

  // Validador de fecha
  static String? fecha(DateTime? fecha, {bool opcional = false}) {
    if (opcional && fecha == null) {
      return null;
    }
    
    if (fecha == null) {
      return 'La fecha es requerida';
    }
    
    return null;
  }

  // Validador de fecha futura
  static String? fechaFutura(DateTime? fecha) {
    if (fecha == null) {
      return 'La fecha es requerida';
    }
    
    if (fecha.isBefore(DateTime.now())) {
      return 'La fecha debe ser futura';
    }
    
    return null;
  }

  // Validador de fecha pasada
  static String? fechaPasada(DateTime? fecha) {
    if (fecha == null) {
      return 'La fecha es requerida';
    }
    
    if (fecha.isAfter(DateTime.now())) {
      return 'La fecha no puede ser futura';
    }
    
    return null;
  }

  // Validador de edad mínima
  static String? edadMinima(DateTime? fechaNacimiento, int edadMinima) {
    if (fechaNacimiento == null) {
      return 'La fecha de nacimiento es requerida';
    }
    
    final ahora = DateTime.now();
    int edad = ahora.year - fechaNacimiento.year;
    
    if (ahora.month < fechaNacimiento.month ||
        (ahora.month == fechaNacimiento.month && ahora.day < fechaNacimiento.day)) {
      edad--;
    }
    
    if (edad < edadMinima) {
      return 'Debe tener al menos $edadMinima años';
    }
    
    return null;
  }

  // Validador de selección (dropdown)
  static String? seleccion<T>(T? valor, {String campo = 'Una opción'}) {
    if (valor == null) {
      return 'Debe seleccionar $campo';
    }
    
    return null;
  }

  // Validador múltiple - combina varios validadores
  static String? multiple(String? valor, List<String? Function(String?)> validadores) {
    for (var validador in validadores) {
      final resultado = validador(valor);
      if (resultado != null) {
        return resultado;
      }
    }
    return null;
  }

  // Validador de motivo de consulta
  static String? motivoConsulta(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El motivo de consulta es requerido';
    }
    
    if (valor.trim().length < 10) {
      return 'Por favor, describa el motivo con más detalle (mínimo 10 caracteres)';
    }
    
    if (valor.trim().length > 500) {
      return 'El motivo de consulta no debe exceder 500 caracteres';
    }
    
    return null;
  }

  // Validador de observaciones (opcional)
  static String? observaciones(String? valor) {
    if (valor != null && valor.trim().length > 1000) {
      return 'Las observaciones no deben exceder 1000 caracteres';
    }
    
    return null;
  }
}