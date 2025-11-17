import 'package:equatable/equatable.dart';

class EspecialidadModel extends Equatable {
  final String nombre;
  final String descripcion;
  final String icono;
  final String color;
  final bool activa;
  final int totalDoctores;

  const EspecialidadModel({
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.color,
    this.activa = true,
    this.totalDoctores = 0,
  });

  // Crear desde Firestore
  factory EspecialidadModel.fromMap(Map<String, dynamic> map, String id) {
    return EspecialidadModel(
      nombre: map['nombre'] ?? id,
      descripcion: map['descripcion'] ?? '',
      icono: map['icono'] ?? 'medical_services',
      color: map['color'] ?? '#6366F1',
      activa: map['activa'] ?? true,
      totalDoctores: map['total_doctores'] ?? 0,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'color': color,
      'activa': activa,
      'total_doctores': totalDoctores,
    };
  }

  // Crear copia con cambios
  EspecialidadModel copyWith({
    String? nombre,
    String? descripcion,
    String? icono,
    String? color,
    bool? activa,
    int? totalDoctores,
  }) {
    return EspecialidadModel(
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      icono: icono ?? this.icono,
      color: color ?? this.color,
      activa: activa ?? this.activa,
      totalDoctores: totalDoctores ?? this.totalDoctores,
    );
  }

  @override
  List<Object?> get props => [
        nombre,
        descripcion,
        icono,
        color,
        activa,
        totalDoctores,
      ];
}
