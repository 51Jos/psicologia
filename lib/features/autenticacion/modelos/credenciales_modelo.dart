import 'package:flutter/material.dart';

class CredencialesModelo {
  final String usuario;
  final String password;
  final bool recordarme;
  final TipoAcceso tipoAcceso;

  CredencialesModelo({
    required this.usuario,
    required this.password,
    this.recordarme = false,
    this.tipoAcceso = TipoAcceso.psicologo,
  });

  // Validación básica
  bool get esValido => usuario.isNotEmpty && password.isNotEmpty;

  // CopyWith
  CredencialesModelo copyWith({
    String? usuario,
    String? password,
    bool? recordarme,
    TipoAcceso? tipoAcceso,
  }) {
    return CredencialesModelo(
      usuario: usuario ?? this.usuario,
      password: password ?? this.password,
      recordarme: recordarme ?? this.recordarme,
      tipoAcceso: tipoAcceso ?? this.tipoAcceso,
    );
  }

  @override
  String toString() {
    return 'CredencialesModelo(usuario: $usuario, recordarme: $recordarme, tipoAcceso: $tipoAcceso)';
  }
}

enum TipoAcceso { 
  administrador, 
  psicologo 
}

extension TipoAccesoExtension on TipoAcceso {
  String get texto {
    switch (this) {
      case TipoAcceso.administrador:
        return 'Administrador';
      case TipoAcceso.psicologo:
        return 'Psicólogo';
    }
  }
  
  IconData get icono {
    switch (this) {
      case TipoAcceso.administrador:
        return Icons.admin_panel_settings;
      case TipoAcceso.psicologo:
        return Icons.psychology;
    }
  }
}