import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String nombre;
  final DateTime fechaRegistro;
  final String? edad;
  final String? lugarNacimiento;
  final String? telefono;
  final String? enfermedades;

  const UserModel({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.fechaRegistro,
    this.edad,
    this.lugarNacimiento,
    this.telefono,
    this.enfermedades,
  });

  // Crear desde Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      nombre: map['nombre'] ?? '',
      fechaRegistro: (map['fecha_registro'] as Timestamp?)?.toDate() ?? DateTime.now(),
      edad: map['edad'],
      lugarNacimiento: map['lugar_nacimiento'],
      telefono: map['telefono'],
      enfermedades: map['enfermedades'],
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nombre': nombre,
      'fecha_registro': Timestamp.fromDate(fechaRegistro),
      'edad': edad,
      'lugar_nacimiento': lugarNacimiento,
      'telefono': telefono,
      'enfermedades': enfermedades,
    };
  }

  // Crear copia con cambios
  UserModel copyWith({
    String? uid,
    String? email,
    String? nombre,
    DateTime? fechaRegistro,
    String? edad,
    String? lugarNacimiento,
    String? telefono,
    String? enfermedades,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      edad: edad ?? this.edad,
      lugarNacimiento: lugarNacimiento ?? this.lugarNacimiento,
      telefono: telefono ?? this.telefono,
      enfermedades: enfermedades ?? this.enfermedades,
    );
  }

  @override
  List<Object?> get props => [uid, email, nombre, fechaRegistro, edad, lugarNacimiento, telefono, enfermedades];
}
