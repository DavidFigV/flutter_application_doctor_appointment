import 'package:equatable/equatable.dart';
import 'package:flutter_application_doctor_appointment/models/chart_data_models.dart';

class DashboardStatsModel extends Equatable {
  // Métricas principales
  final int totalCitas;
  final int citasPendientes;
  final int citasCompletadas;
  final int citasCanceladas;
  final double promedioCitasPorDia;
  final double promedioCitasPorSemana;
  final double promedioCitasPorMes;

  // Métricas comparativas
  final int citasEsteMes;
  final int citasMesAnterior;
  final double porcentajeCambio;
  final int miRanking;
  final int totalDoctoresEspecialidad;
  final int misPacientesNuevos;
  final double promedioEspecialidad;

  // Datos para gráficas
  final List<ChartData> citasPorMes;
  final List<ChartData> citasPorSemana;
  final Map<String, int> citasPorEstado;
  final ComparativaData? comparativaMesActualVsAnterior;

  // Métricas adicionales
  final int totalPacientesUnicos;
  final int pacientesNuevos;
  final int? rankingEspecialidad;

  const DashboardStatsModel({
    this.totalCitas = 0,
    this.citasPendientes = 0,
    this.citasCompletadas = 0,
    this.citasCanceladas = 0,
    this.promedioCitasPorDia = 0.0,
    this.promedioCitasPorSemana = 0.0,
    this.promedioCitasPorMes = 0.0,
    this.citasEsteMes = 0,
    this.citasMesAnterior = 0,
    this.porcentajeCambio = 0.0,
    this.miRanking = 0,
    this.totalDoctoresEspecialidad = 0,
    this.misPacientesNuevos = 0,
    this.promedioEspecialidad = 0.0,
    this.citasPorMes = const [],
    this.citasPorSemana = const [],
    this.citasPorEstado = const {},
    this.comparativaMesActualVsAnterior,
    this.totalPacientesUnicos = 0,
    this.pacientesNuevos = 0,
    this.rankingEspecialidad,
  });

  // Crear copia con cambios
  DashboardStatsModel copyWith({
    int? totalCitas,
    int? citasPendientes,
    int? citasCompletadas,
    int? citasCanceladas,
    double? promedioCitasPorDia,
    double? promedioCitasPorSemana,
    double? promedioCitasPorMes,
    int? citasEsteMes,
    int? citasMesAnterior,
    double? porcentajeCambio,
    int? miRanking,
    int? totalDoctoresEspecialidad,
    int? misPacientesNuevos,
    double? promedioEspecialidad,
    List<ChartData>? citasPorMes,
    List<ChartData>? citasPorSemana,
    Map<String, int>? citasPorEstado,
    ComparativaData? comparativaMesActualVsAnterior,
    int? totalPacientesUnicos,
    int? pacientesNuevos,
    int? rankingEspecialidad,
  }) {
    return DashboardStatsModel(
      totalCitas: totalCitas ?? this.totalCitas,
      citasPendientes: citasPendientes ?? this.citasPendientes,
      citasCompletadas: citasCompletadas ?? this.citasCompletadas,
      citasCanceladas: citasCanceladas ?? this.citasCanceladas,
      promedioCitasPorDia: promedioCitasPorDia ?? this.promedioCitasPorDia,
      promedioCitasPorSemana: promedioCitasPorSemana ?? this.promedioCitasPorSemana,
      promedioCitasPorMes: promedioCitasPorMes ?? this.promedioCitasPorMes,
      citasEsteMes: citasEsteMes ?? this.citasEsteMes,
      citasMesAnterior: citasMesAnterior ?? this.citasMesAnterior,
      porcentajeCambio: porcentajeCambio ?? this.porcentajeCambio,
      miRanking: miRanking ?? this.miRanking,
      totalDoctoresEspecialidad: totalDoctoresEspecialidad ?? this.totalDoctoresEspecialidad,
      misPacientesNuevos: misPacientesNuevos ?? this.misPacientesNuevos,
      promedioEspecialidad: promedioEspecialidad ?? this.promedioEspecialidad,
      citasPorMes: citasPorMes ?? this.citasPorMes,
      citasPorSemana: citasPorSemana ?? this.citasPorSemana,
      citasPorEstado: citasPorEstado ?? this.citasPorEstado,
      comparativaMesActualVsAnterior: comparativaMesActualVsAnterior ?? this.comparativaMesActualVsAnterior,
      totalPacientesUnicos: totalPacientesUnicos ?? this.totalPacientesUnicos,
      pacientesNuevos: pacientesNuevos ?? this.pacientesNuevos,
      rankingEspecialidad: rankingEspecialidad ?? this.rankingEspecialidad,
    );
  }

  @override
  List<Object?> get props => [
        totalCitas,
        citasPendientes,
        citasCompletadas,
        citasCanceladas,
        promedioCitasPorDia,
        promedioCitasPorSemana,
        promedioCitasPorMes,
        citasEsteMes,
        citasMesAnterior,
        porcentajeCambio,
        miRanking,
        totalDoctoresEspecialidad,
        misPacientesNuevos,
        promedioEspecialidad,
        citasPorMes,
        citasPorSemana,
        citasPorEstado,
        comparativaMesActualVsAnterior,
        totalPacientesUnicos,
        pacientesNuevos,
        rankingEspecialidad,
      ];
}
