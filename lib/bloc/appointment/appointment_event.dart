import 'package:equatable/equatable.dart';
import '../../models/appointment_model.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object?> get props => [];
}

// Evento para cargar citas del usuario
class AppointmentLoadRequested extends AppointmentEvent {
  final String userId;

  const AppointmentLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Evento para cargar citas de un doctor (agenda)
class AppointmentLoadForDoctorRequested extends AppointmentEvent {
  final String doctorId;

  const AppointmentLoadForDoctorRequested(this.doctorId);

  @override
  List<Object?> get props => [doctorId];
}

// Evento para crear una nueva cita
class AppointmentCreateRequested extends AppointmentEvent {
  final AppointmentModel appointment;

  const AppointmentCreateRequested(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

// Evento para actualizar una cita
class AppointmentUpdateRequested extends AppointmentEvent {
  final String appointmentId;
  final AppointmentModel appointment;

  const AppointmentUpdateRequested(this.appointmentId, this.appointment);

  @override
  List<Object?> get props => [appointmentId, appointment];
}

// Evento para eliminar una cita
class AppointmentDeleteRequested extends AppointmentEvent {
  final String appointmentId;

  const AppointmentDeleteRequested(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}
