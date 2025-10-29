import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String nombre;
  final String? edad;
  final String? lugarNacimiento;
  final String? telefono;
  final String? enfermedades;

  const UserModel({
    required this.uid,
    required this.email,
    required this.nombre,
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
    String? edad,
    String? lugarNacimiento,
    String? telefono,
    String? enfermedades,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      edad: edad ?? this.edad,
      lugarNacimiento: lugarNacimiento ?? this.lugarNacimiento,
      telefono: telefono ?? this.telefono,
      enfermedades: enfermedades ?? this.enfermedades,
    );
  }

  @override
  List<Object?> get props => [uid, email, nombre, edad, lugarNacimiento, telefono, enfermedades];
}
