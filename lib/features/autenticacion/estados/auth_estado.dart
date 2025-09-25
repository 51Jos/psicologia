import '../modelos/usuario.dart';


abstract class AuthEstado {
  const AuthEstado();
}

class AuthInicial extends AuthEstado {
  const AuthInicial();
}

class AuthCargando extends AuthEstado {
  const AuthCargando();
}

class AuthExito extends AuthEstado {
  final UsuarioModelo usuario;
  
  const AuthExito(this.usuario);
}

class AuthError extends AuthEstado {
  final String mensaje;
  final String? codigo;
  
  const AuthError(this.mensaje, [this.codigo]);
}

class AuthNoAutenticado extends AuthEstado {
  const AuthNoAutenticado();
}

class AuthCerrandoSesion extends AuthEstado {
  const AuthCerrandoSesion();
}