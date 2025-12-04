import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../../bloc/dashboard/dashboard_event.dart';
import '../../bloc/dashboard/dashboard_state.dart';
import '../../models/dashboard_stats_model.dart';
import '../../repositories/doctor_repository.dart';
import '../../widgets/dashboard/pie_chart_widget.dart';
import '../../widgets/dashboard/bar_chart_widget.dart';
import '../../widgets/dashboard/line_chart_widget.dart';
import '../../widgets/dashboard/dual_line_chart_widget.dart';
import '../../widgets/dashboard/dual_point_line_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _primaryGreen = Color(0xFF10B981);
  static const _secondaryGreen = Color(0xFF059669);
  static const _primaryPurple = Color(0xFF6366F1);
  static const _secondaryPurple = Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      try {
        final doctorRepo = context.read<DoctorRepository>();
        final doctorData = await doctorRepo.getDoctorData(authState.user.uid);

        if (doctorData == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se encontraron datos del doctor')),
            );
          }
          return;
        }

        if (mounted) {
          context.read<DashboardBloc>().add(
                DashboardLoadRequested(
                  doctorId: authState.user.uid,
                  especialidad: doctorData.especialidad,
                ),
              );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar dashboard: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Dashboard Médico',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: _primaryGreen,
              ),
            );
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar el dashboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadDashboard,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            final stats = state.stats;

            return RefreshIndicator(
              onRefresh: () async {
                _loadDashboard();
                await Future.delayed(const Duration(seconds: 1));
              },
              color: _primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con resumen
                    _buildHeader(stats.totalCitas),
                    const SizedBox(height: 24),

                    // Estados de Citas
                    _buildSectionTitle('Estados de Citas'),
                    const SizedBox(height: 16),
                    _buildEstadosCitasSection(stats),
                    const SizedBox(height: 24),

                    // Promedios de Atención
                    _buildSectionTitle('Promedios de Atención'),
                    const SizedBox(height: 16),
                    _buildPromediosSection(stats),
                    const SizedBox(height: 32),

                    // Distribución de Estados
                    _buildSectionTitle('Distribución de Citas'),
                    const SizedBox(height: 16),
                    PieChartWidget(
                      title: 'Estados de Citas',
                      data: stats.citasPorEstado,
                    ),
                    const SizedBox(height: 32),

                    // Gráficas de tendencias
                    _buildSectionTitle('Tendencias'),
                    const SizedBox(height: 16),
                  BarChartWidget(
                    title: 'Citas por Mes (Últimos 6 meses)',
                    data: stats.citasPorMes,
                    barColor: _primaryPurple,
                  ),
                    const SizedBox(height: 24),
                  LineChartWidget(
                    title: 'Citas por Semana (Últimas 4 semanas)',
                    data: stats.citasPorSemana,
                    lineColor: _primaryGreen,
                  ),
                    const SizedBox(height: 32),

                    // Métricas comparativas
                    if (stats.comparativaMesActualVsAnterior != null) ...[
                      _buildSectionTitle('Análisis Comparativo'),
                      const SizedBox(height: 16),
                      DualPointLineChart(
                        title: 'Mes Actual vs Mes Anterior',
                        valorMesAnterior:
                            stats.comparativaMesActualVsAnterior!.datos1.first.value,
                        valorMesActual:
                            stats.comparativaMesActualVsAnterior!.datos1.last.value,
                        labelMesAnterior:
                            stats.comparativaMesActualVsAnterior!.datos1.first.label,
                        labelMesActual:
                            stats.comparativaMesActualVsAnterior!.datos1.last.label,
                        lineColorAnterior: _primaryPurple,
                        lineColorActual: _secondaryPurple,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Información adicional
                    _buildSectionTitle('Información Adicional'),
                    const SizedBox(height: 16),
                    _buildAdditionalInfo(stats),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }

          // Estado inicial
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.dashboard_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Cargando dashboard...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(int totalCitas) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryGreen, _secondaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryGreen.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.show_chart,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total de Citas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalCitas',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  // Sección de Estados de Citas (estilo lista compacta)
  Widget _buildEstadosCitasSection(DashboardStatsModel stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCompactMetricItem(
            Icons.schedule,
            'Pendientes',
            '${stats.citasPendientes}',
            const Color(0xFFF59E0B),
          ),
          const Divider(height: 24),
          _buildCompactMetricItem(
            Icons.check_circle,
            'Completadas',
            '${stats.citasCompletadas}',
            _primaryGreen,
          ),
          const Divider(height: 24),
          _buildCompactMetricItem(
            Icons.cancel,
            'Canceladas',
            '${stats.citasCanceladas}',
            const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  // Sección de Promedios (estilo lista compacta)
  Widget _buildPromediosSection(DashboardStatsModel stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCompactMetricItem(
            Icons.today,
            'Por Día',
            stats.promedioCitasPorDia.toStringAsFixed(1),
            _primaryPurple,
          ),
          const Divider(height: 24),
          _buildCompactMetricItem(
            Icons.date_range,
            'Por Semana',
            stats.promedioCitasPorSemana.toStringAsFixed(1),
            _secondaryPurple,
          ),
          const Divider(height: 24),
          _buildCompactMetricItem(
            Icons.calendar_month,
            'Por Mes',
            stats.promedioCitasPorMes.toStringAsFixed(1),
            const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  // Widget compacto reutilizable para items de métrica
  Widget _buildCompactMetricItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo(DashboardStatsModel stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.people,
            'Total Pacientes Únicos',
            '${stats.totalPacientesUnicos}',
            _primaryPurple,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.person_add,
            'Pacientes Nuevos (3 meses)',
            '${stats.pacientesNuevos}',
            _primaryGreen,
          ),
          if (stats.rankingEspecialidad != null) ...[
            const Divider(height: 24),
            _buildInfoRow(
              Icons.emoji_events,
              'Ranking en Especialidad',
              '#${stats.rankingEspecialidad}',
              const Color(0xFFF59E0B),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}
