import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Evento para verificar el estado de autenticación
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

// Evento para iniciar sesión
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

// Evento para cerrar sesión
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
