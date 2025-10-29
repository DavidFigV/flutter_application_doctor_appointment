import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

// Evento para cargar datos del usuario
class UserLoadRequested extends UserEvent {
  final String uid;

  const UserLoadRequested(this.uid);

  @override
  List<Object?> get props => [uid];
}

// Evento para actualizar datos del usuario
class UserUpdateRequested extends UserEvent {
  final UserModel user;

  const UserUpdateRequested(this.user);

  @override
  List<Object?> get props => [user];
}

// Evento para limpiar datos del usuario (al cerrar sesión)
class UserClearRequested extends UserEvent {
  const UserClearRequested();
}
