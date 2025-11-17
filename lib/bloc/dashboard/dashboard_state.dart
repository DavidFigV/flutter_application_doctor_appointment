import 'package:equatable/equatable.dart';
import '../../models/dashboard_stats_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

// Estado inicial
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

// Estado de carga
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

// Estado con estadísticas cargadas
class DashboardLoaded extends DashboardState {
  final DashboardStatsModel stats;

  const DashboardLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

// Estado de error
class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
