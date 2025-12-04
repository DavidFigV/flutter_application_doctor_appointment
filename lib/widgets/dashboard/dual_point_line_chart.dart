import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Gráfico de línea para comparar dos puntos (mes anterior vs mes actual).
/// Cada serie se dibuja con dos puntos fijos en X (0 y 1) para forzar un eje temporal corto.
class DualPointLineChart extends StatelessWidget {
  final String title;
  final double valorMesAnterior;
  final double valorMesActual;
  final Color lineColorAnterior;
  final Color lineColorActual;
  final String labelMesAnterior;
  final String labelMesActual;

  const DualPointLineChart({
    super.key,
    required this.title,
    required this.valorMesAnterior,
    required this.valorMesActual,
    required this.labelMesAnterior,
    required this.labelMesActual,
    this.lineColorAnterior = const Color(0xFF6366F1),
    this.lineColorActual = const Color(0xFF10B981),
  });

  @override
  Widget build(BuildContext context) {
    final maxY = _maxY();
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 1,
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[200],
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labelMesAnterior,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        if (value == 1) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labelMesActual,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                // Una sola línea conectando los dos puntos, con degradado para distinguir mes anterior/actual.
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, valorMesAnterior),
                      FlSpot(1, valorMesActual),
                    ],
                    isCurved: false,
                    gradient: LinearGradient(
                      colors: [lineColorAnterior, lineColorActual],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final color = spot.x == 0 ? lineColorAnterior : lineColorActual;
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: color,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toInt()}',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            backgroundColor:
                                spot.x == 1 ? lineColorActual : lineColorAnterior,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: lineColorAnterior,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          labelMesAnterior,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 20),
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: lineColorActual,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          labelMesActual,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  double _maxY() {
    final maxVal = valorMesAnterior > valorMesActual ? valorMesAnterior : valorMesActual;
    return (maxVal * 1.2).ceilToDouble().clamp(5, double.infinity);
  }
}
