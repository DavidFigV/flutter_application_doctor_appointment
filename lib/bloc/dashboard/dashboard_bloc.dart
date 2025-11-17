import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _dashboardRepository;
  String? _currentDoctorId;
  String? _currentEspecialidad;

  DashboardBloc({required DashboardRepository dashboardRepository})
      : _dashboardRepository = dashboardRepository,
        super(const DashboardInitial()) {
    // Registrar manejadores de eventos
    on<DashboardLoadRequested>(_onDashboardLoadRequested);
    on<DashboardRefreshRequested>(_onDashboardRefreshRequested);
  }

  // Cargar estadísticas del dashboard
  Future<void> _onDashboardLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    try {
      // Guardar para refresh posterior
      _currentDoctorId = event.doctorId;
      _currentEspecialidad = event.especialidad;

      final stats = await _dashboardRepository.getDashboardStats(
        event.doctorId,
        event.especialidad,
      );

      emit(DashboardLoaded(stats));
    } catch (e) {
      emit(DashboardError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Refrescar estadísticas (usa los valores guardados)
  Future<void> _onDashboardRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (_currentDoctorId == null || _currentEspecialidad == null) {
      emit(const DashboardError('No hay datos previos para refrescar'));
      return;
    }

    emit(const DashboardLoading());

    try {
      final stats = await _dashboardRepository.getDashboardStats(
        _currentDoctorId!,
        _currentEspecialidad!,
      );

      emit(DashboardLoaded(stats));
    } catch (e) {
      emit(DashboardError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
