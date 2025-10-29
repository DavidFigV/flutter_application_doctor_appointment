import 'package:equatable/equatable.dart';
import '../../models/appointment_model.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object?> get props => [];
}

// Estado inicial
class AppointmentInitial extends AppointmentState {
  const AppointmentInitial();
}

// Estado de carga
class AppointmentLoading extends AppointmentState {
  const AppointmentLoading();
}

// Estado con citas cargadas
class AppointmentsLoaded extends AppointmentState {
  final List<AppointmentModel> appointments;

  const AppointmentsLoaded(this.appointments);

  @override
  List<Object?> get props => [appointments];
}

// Estado de éxito en operación (crear, actualizar, eliminar)
class AppointmentOperationSuccess extends AppointmentState {
  final String message;

  const AppointmentOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Estado de error
class AppointmentError extends AppointmentState {
  final String message;

  const AppointmentError(this.message);

  @override
  List<Object?> get props => [message];
}
