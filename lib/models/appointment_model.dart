import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel extends Equatable {
  final String? id;
  final String idPaciente;
  final String nombrePaciente;
  final String emailPaciente;
  final String telefonoPaciente;
  final String nombreDoctor;
  final String especialidadDoctor;
  final DateTime fecha;
  final String hora;
  final String motivoConsulta;

  const AppointmentModel({
    this.id,
    required this.idPaciente,
    required this.nombrePaciente,
    required this.emailPaciente,
    required this.telefonoPaciente,
    required this.nombreDoctor,
    required this.especialidadDoctor,
    required this.fecha,
    required this.hora,
    required this.motivoConsulta,
  });

  // Crear desde Firestore
  factory AppointmentModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return AppointmentModel(
      id: docId ?? map['id'],
      idPaciente: map['id_paciente'] ?? '',
      nombrePaciente: map['nombre_paciente'] ?? '',
      emailPaciente: map['email_paciente'] ?? '',
      telefonoPaciente: map['telefono_paciente'] ?? '',
      nombreDoctor: map['nombre_doctor'] ?? '',
      especialidadDoctor: map['especialidad_doctor'] ?? '',
      fecha: (map['fecha'] as Timestamp).toDate(),
      hora: map['hora'] ?? '',
      motivoConsulta: map['motivo_consulta'] ?? '',
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id_paciente': idPaciente,
      'nombre_paciente': nombrePaciente,
      'email_paciente': emailPaciente,
      'telefono_paciente': telefonoPaciente,
      'nombre_doctor': nombreDoctor,
      'especialidad_doctor': especialidadDoctor,
      'fecha': Timestamp.fromDate(fecha),
      'hora': hora,
      'motivo_consulta': motivoConsulta,
    };
  }

  // Crear copia con cambios
  AppointmentModel copyWith({
    String? id,
    String? idPaciente,
    String? nombrePaciente,
    String? emailPaciente,
    String? telefonoPaciente,
    String? nombreDoctor,
    String? especialidadDoctor,
    DateTime? fecha,
    String? hora,
    String? motivoConsulta,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      idPaciente: idPaciente ?? this.idPaciente,
      nombrePaciente: nombrePaciente ?? this.nombrePaciente,
      emailPaciente: emailPaciente ?? this.emailPaciente,
      telefonoPaciente: telefonoPaciente ?? this.telefonoPaciente,
      nombreDoctor: nombreDoctor ?? this.nombreDoctor,
      especialidadDoctor: especialidadDoctor ?? this.especialidadDoctor,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      motivoConsulta: motivoConsulta ?? this.motivoConsulta,
    );
  }

  @override
  List<Object?> get props => [
        id,
        idPaciente,
        nombrePaciente,
        emailPaciente,
        telefonoPaciente,
        nombreDoctor,
        especialidadDoctor,
        fecha,
        hora,
        motivoConsulta,
      ];
}
