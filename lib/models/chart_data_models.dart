import 'package:equatable/equatable.dart';

/// Modelo para datos de gráficas simples (barras, líneas)
class ChartData extends Equatable {
  final String label;
  final double value;
  final DateTime? date;

  const ChartData({
    required this.label,
    required this.value,
    this.date,
  });

  @override
  List<Object?> get props => [label, value, date];
}

/// Modelo para datos comparativos (gráfica dual)
class ComparativaData extends Equatable {
  final List<ChartData> datos1;
  final List<ChartData> datos2;
  final String label1;
  final String label2;

  const ComparativaData({
    required this.datos1,
    required this.datos2,
    required this.label1,
    required this.label2,
  });

  @override
  List<Object?> get props => [datos1, datos2, label1, label2];
}
