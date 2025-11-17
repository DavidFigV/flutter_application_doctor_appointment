import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

// Evento para cargar estadísticas del dashboard
class DashboardLoadRequested extends DashboardEvent {
  final String doctorId;
  final String especialidad;

  const DashboardLoadRequested({
    required this.doctorId,
    required this.especialidad,
  });

  @override
  List<Object?> get props => [doctorId, especialidad];
}

// Evento para refrescar estadísticas
class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();
}
