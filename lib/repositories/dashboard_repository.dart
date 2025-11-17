import '../models/dashboard_stats_model.dart';
import '../models/chart_data_models.dart';
import 'appointment_repository.dart';
import 'doctor_repository.dart';

class DashboardRepository {
  final AppointmentRepository appointmentRepository;
  final DoctorRepository doctorRepository;

  DashboardRepository({
    required this.appointmentRepository,
    required this.doctorRepository,
  });

  // Obtener todas las estadísticas del dashboard
  Future<DashboardStatsModel> getDashboardStats(String doctorId, String especialidad) async {
    try {
      // Obtener métricas principales de citas
      final totalCitas = await appointmentRepository.getTotalCitasByDoctor(doctorId);
      final citasPendientes = await appointmentRepository.getCitasByEstado(doctorId, 'pendiente');
      final citasCompletadas = await appointmentRepository.getCitasByEstado(doctorId, 'completada');
      final citasCanceladas = await appointmentRepository.getCitasByEstado(doctorId, 'cancelada');

      // Obtener promedios
      final promedioCitasPorDia = await appointmentRepository.getPromedioCitasPorDia(doctorId);
      final promedioCitasPorSemana = await appointmentRepository.getPromedioCitasPorSemana(doctorId);
      final promedioCitasPorMes = await appointmentRepository.getPromedioCitasPorMes(doctorId);

      // Obtener métricas comparativas
      final now = DateTime.now();
      final citasEsteMes = await appointmentRepository.getCitasByMonthCount(
        doctorId,
        DateTime(now.year, now.month, 1),
      );
      final citasMesAnterior = await appointmentRepository.getCitasByMonthCount(
        doctorId,
        DateTime(now.year, now.month - 1, 1),
      );

      // Calcular porcentaje de cambio
      double porcentajeCambio = 0.0;
      if (citasMesAnterior > 0) {
        porcentajeCambio = ((citasEsteMes - citasMesAnterior) / citasMesAnterior) * 100;
      }

      // Obtener ranking y total de doctores de la especialidad
      final totalDoctoresEspecialidad = await doctorRepository.getTotalDoctoresByEspecialidad(especialidad);
      final miRanking = await doctorRepository.getRankingByEspecialidad(doctorId, especialidad);

      // Obtener pacientes nuevos
      final misPacientesNuevos = await appointmentRepository.getPacientesNuevos(doctorId, 6);

      // Calcular promedio de la especialidad (simplificado por ahora)
      double promedioEspecialidad = 0.0;
      if (totalDoctoresEspecialidad > 0) {
        promedioEspecialidad = misPacientesNuevos / totalDoctoresEspecialidad.toDouble();
      }

      // Obtener datos para gráficas
      final citasPorMes = await appointmentRepository.getCitasByMonth(doctorId, 6);
      final citasPorSemana = await appointmentRepository.getCitasByWeek(doctorId, 4);

      // Citas por estado para pie chart
      final citasPorEstado = {
        'pendiente': citasPendientes,
        'completada': citasCompletadas,
        'cancelada': citasCanceladas,
      };

      // Obtener datos para comparativa mes actual vs anterior
      ComparativaData? comparativaMesActualVsAnterior;
      if (citasPorMes.length >= 2) {
        comparativaMesActualVsAnterior = ComparativaData(
          datos1: [citasPorMes[citasPorMes.length - 1]], // Mes actual
          datos2: [citasPorMes[citasPorMes.length - 2]], // Mes anterior
          label1: 'Mes Actual',
          label2: 'Mes Anterior',
        );
      }

      // Obtener métricas adicionales
      final totalPacientesUnicos = await appointmentRepository.getTotalPacientesUnicos(doctorId);
      final pacientesNuevos = await appointmentRepository.getPacientesNuevos(doctorId, 3);
      final rankingEspecialidad = await doctorRepository.getRankingByEspecialidad(doctorId, especialidad);

      return DashboardStatsModel(
        totalCitas: totalCitas,
        citasPendientes: citasPendientes,
        citasCompletadas: citasCompletadas,
        citasCanceladas: citasCanceladas,
        promedioCitasPorDia: promedioCitasPorDia,
        promedioCitasPorSemana: promedioCitasPorSemana,
        promedioCitasPorMes: promedioCitasPorMes,
        citasEsteMes: citasEsteMes,
        citasMesAnterior: citasMesAnterior,
        porcentajeCambio: porcentajeCambio,
        miRanking: miRanking,
        totalDoctoresEspecialidad: totalDoctoresEspecialidad,
        misPacientesNuevos: misPacientesNuevos,
        promedioEspecialidad: promedioEspecialidad,
        citasPorMes: citasPorMes,
        citasPorSemana: citasPorSemana,
        citasPorEstado: citasPorEstado,
        comparativaMesActualVsAnterior: comparativaMesActualVsAnterior,
        totalPacientesUnicos: totalPacientesUnicos,
        pacientesNuevos: pacientesNuevos,
        rankingEspecialidad: rankingEspecialidad,
      );
    } catch (e) {
      throw Exception('Error al obtener estadísticas del dashboard: $e');
    }
  }
}
