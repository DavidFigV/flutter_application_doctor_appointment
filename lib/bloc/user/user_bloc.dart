import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const UserInitial()) {
    // Registrar manejadores de eventos
    on<UserLoadRequested>(_onUserLoadRequested);
    on<UserUpdateRequested>(_onUserUpdateRequested);
    on<UserClearRequested>(_onUserClearRequested);
  }

  // Cargar datos del usuario
  Future<void> _onUserLoadRequested(
    UserLoadRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    try {
      final user = await _userRepository.getUserData(event.uid);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Actualizar datos del usuario
  Future<void> _onUserUpdateRequested(
    UserUpdateRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    try {
      await _userRepository.saveUserData(event.user);
      emit(const UserOperationSuccess('Información guardada exitosamente'));
      // Recargar datos para reflejar cambios
      emit(UserLoaded(event.user));
    } catch (e) {
      emit(UserError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Limpiar datos del usuario (al cerrar sesión)
  Future<void> _onUserClearRequested(
    UserClearRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserInitial());
  }
}
