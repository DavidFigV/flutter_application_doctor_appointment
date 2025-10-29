import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

// Estado inicial
class UserInitial extends UserState {
  const UserInitial();
}

// Estado de carga
class UserLoading extends UserState {
  const UserLoading();
}

// Estado con datos cargados
class UserLoaded extends UserState {
  final UserModel user;

  const UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

// Estado de éxito en operación (guardar)
class UserOperationSuccess extends UserState {
  final String message;

  const UserOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Estado de error
class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}
