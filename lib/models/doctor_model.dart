import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class DoctorModel extends Equatable {
  final String uid;
  final String especialidad;
  final DateTime fechaInicioActividad;
  final String? cedulaProfesional;
  final String? universidad;
  final int? anosExperiencia;
  final bool activo;

  const DoctorModel({
    required this.uid,
    required this.especialidad,
    required this.fechaInicioActividad,
    this.cedulaProfesional,
    this.universidad,
    this.anosExperiencia,
    this.activo = true,
  });

  // Crear desde Firestore
  factory DoctorModel.fromMap(Map<String, dynamic> map, String uid) {
    return DoctorModel(
      uid: uid,
      especialidad: map['especialidad'] ?? '',
      fechaInicioActividad: (map['fecha_inicio_actividad'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cedulaProfesional: map['cedula_profesional'],
      universidad: map['universidad'],
      anosExperiencia: map['anos_experiencia'],
      activo: map['activo'] ?? true,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'especialidad': especialidad,
      'fecha_inicio_actividad': Timestamp.fromDate(fechaInicioActividad),
      'cedula_profesional': cedulaProfesional,
      'universidad': universidad,
      'anos_experiencia': anosExperiencia,
      'activo': activo,
    };
  }

  // Crear copia con cambios
  DoctorModel copyWith({
    String? uid,
    String? especialidad,
    DateTime? fechaInicioActividad,
    String? cedulaProfesional,
    String? universidad,
    int? anosExperiencia,
    bool? activo,
  }) {
    return DoctorModel(
      uid: uid ?? this.uid,
      especialidad: especialidad ?? this.especialidad,
      fechaInicioActividad: fechaInicioActividad ?? this.fechaInicioActividad,
      cedulaProfesional: cedulaProfesional ?? this.cedulaProfesional,
      universidad: universidad ?? this.universidad,
      anosExperiencia: anosExperiencia ?? this.anosExperiencia,
      activo: activo ?? this.activo,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        especialidad,
        fechaInicioActividad,
        cedulaProfesional,
        universidad,
        anosExperiencia,
        activo,
      ];
}
