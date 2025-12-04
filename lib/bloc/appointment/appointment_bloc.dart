import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/appointment_model.dart';
import '../../repositories/appointment_repository.dart';
import 'appointment_event.dart';
import 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentRepository _appointmentRepository;
  StreamSubscription? _appointmentSubscription;
  List<AppointmentModel> _lastAppointments = const [];

  AppointmentBloc({required AppointmentRepository appointmentRepository})
      : _appointmentRepository = appointmentRepository,
        super(const AppointmentInitial()) {
    // Registrar manejadores de eventos
    on<AppointmentLoadRequested>(_onAppointmentLoadRequested);
    on<AppointmentLoadForDoctorRequested>(_onAppointmentLoadForDoctorRequested);
    on<AppointmentCreateRequested>(_onAppointmentCreateRequested);
    on<AppointmentUpdateRequested>(_onAppointmentUpdateRequested);
    on<AppointmentDeleteRequested>(_onAppointmentDeleteRequested);
    on<_AppointmentUpdated>(_onAppointmentUpdated);
    on<_AppointmentUpdateError>(_onAppointmentUpdateError);
  }

  // Cargar citas del usuario
  Future<void> _onAppointmentLoadRequested(
    AppointmentLoadRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentLoading());

    try {
      // Cancelar suscripción anterior si existe
      await _appointmentSubscription?.cancel();

      // Escuchar cambios en las citas en tiempo real
      _appointmentSubscription = _appointmentRepository
          .getAppointmentsStream(event.userId)
          .listen(
            (appointments) {
              add(_AppointmentUpdated(appointments));
            },
            onError: (error) {
              add(_AppointmentUpdateError(error.toString()));
            },
          );
    } catch (e) {
      emit(AppointmentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Cargar citas del doctor (agenda)
  Future<void> _onAppointmentLoadForDoctorRequested(
    AppointmentLoadForDoctorRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentLoading());

    try {
      await _appointmentSubscription?.cancel();

      _appointmentSubscription = _appointmentRepository
          .getAppointmentsByDoctorStream(event.doctorId)
          .listen(
            (appointments) {
              add(_AppointmentUpdated(appointments));
            },
            onError: (error) {
              add(_AppointmentUpdateError(error.toString()));
            },
          );
    } catch (e) {
      emit(AppointmentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Crear nueva cita
  Future<void> _onAppointmentCreateRequested(
    AppointmentCreateRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      await _appointmentRepository.createAppointment(event.appointment);
      emit(const AppointmentOperationSuccess('Cita creada exitosamente'));
      emit(AppointmentsLoaded(_lastAppointments));
    } catch (e) {
      emit(AppointmentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Actualizar cita
  Future<void> _onAppointmentUpdateRequested(
    AppointmentUpdateRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      await _appointmentRepository.updateAppointment(
        event.appointmentId,
        event.appointment,
      );
      emit(const AppointmentOperationSuccess('Cita actualizada exitosamente'));
      emit(AppointmentsLoaded(_lastAppointments));
    } catch (e) {
      emit(AppointmentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Eliminar cita
  Future<void> _onAppointmentDeleteRequested(
    AppointmentDeleteRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      await _appointmentRepository.deleteAppointment(event.appointmentId);
      emit(const AppointmentOperationSuccess('Cita eliminada exitosamente'));
      emit(AppointmentsLoaded(_lastAppointments));
    } catch (e) {
      emit(AppointmentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Manejar actualizaciones del stream
  void _onAppointmentUpdated(
    _AppointmentUpdated event,
    Emitter<AppointmentState> emit,
  ) {
    _lastAppointments = event.appointments;
    emit(AppointmentsLoaded(event.appointments));
  }

  // Manejar errores del stream
  void _onAppointmentUpdateError(
    _AppointmentUpdateError event,
    Emitter<AppointmentState> emit,
  ) {
    emit(AppointmentError(event.error.replaceAll('Exception: ', '')));
  }

  @override
  Future<void> close() {
    _appointmentSubscription?.cancel();
    return super.close();
  }
}

// Eventos internos para manejar actualizaciones del stream
class _AppointmentUpdated extends AppointmentEvent {
  final List<AppointmentModel> appointments;

  const _AppointmentUpdated(this.appointments);

  @override
  List<Object?> get props => [appointments];
}

class _AppointmentUpdateError extends AppointmentEvent {
  final String error;

  const _AppointmentUpdateError(this.error);

  @override
  List<Object?> get props => [error];
}
