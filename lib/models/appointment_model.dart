import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel extends Equatable {
  final String? id;
  final String idPaciente;
  final String idDoctor;
  final String nombrePaciente;
  final String emailPaciente;
  final String telefonoPaciente;
  final String nombreDoctor;
  final String especialidadDoctor;
  final DateTime fecha;
  final String hora;
  final String motivoConsulta;
  final String estado;
  final DateTime fechaCreacion;
  final bool esPrimeraCita;

  const AppointmentModel({
    this.id,
    required this.idPaciente,
    required this.idDoctor,
    required this.nombrePaciente,
    required this.emailPaciente,
    required this.telefonoPaciente,
    required this.nombreDoctor,
    required this.especialidadDoctor,
    required this.fecha,
    required this.hora,
    required this.motivoConsulta,
    this.estado = 'pendiente',
    required this.fechaCreacion,
    this.esPrimeraCita = false,
  });

  // Crear desde Firestore
  factory AppointmentModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return AppointmentModel(
      id: docId ?? map['id'],
      idPaciente: map['id_paciente'] ?? '',
      idDoctor: map['id_doctor'] ?? '',
      nombrePaciente: map['nombre_paciente'] ?? '',
      emailPaciente: map['email_paciente'] ?? '',
      telefonoPaciente: map['telefono_paciente'] ?? '',
      nombreDoctor: map['nombre_doctor'] ?? '',
      especialidadDoctor: map['especialidad_doctor'] ?? '',
      fecha: (map['fecha'] as Timestamp).toDate(),
      hora: map['hora'] ?? '',
      motivoConsulta: map['motivo_consulta'] ?? '',
      estado: map['estado'] ?? 'pendiente',
      fechaCreacion: (map['fecha_creacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      esPrimeraCita: map['es_primera_cita'] ?? false,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id_paciente': idPaciente,
      'id_doctor': idDoctor,
      'nombre_paciente': nombrePaciente,
      'email_paciente': emailPaciente,
      'telefono_paciente': telefonoPaciente,
      'nombre_doctor': nombreDoctor,
      'especialidad_doctor': especialidadDoctor,
      'fecha': Timestamp.fromDate(fecha),
      'hora': hora,
      'motivo_consulta': motivoConsulta,
      'estado': estado,
      'fecha_creacion': Timestamp.fromDate(fechaCreacion),
      'es_primera_cita': esPrimeraCita,
    };
  }

  // Crear copia con cambios
  AppointmentModel copyWith({
    String? id,
    String? idPaciente,
    String? idDoctor,
    String? nombrePaciente,
    String? emailPaciente,
    String? telefonoPaciente,
    String? nombreDoctor,
    String? especialidadDoctor,
    DateTime? fecha,
    String? hora,
    String? motivoConsulta,
    String? estado,
    DateTime? fechaCreacion,
    bool? esPrimeraCita,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      idPaciente: idPaciente ?? this.idPaciente,
      idDoctor: idDoctor ?? this.idDoctor,
      nombrePaciente: nombrePaciente ?? this.nombrePaciente,
      emailPaciente: emailPaciente ?? this.emailPaciente,
      telefonoPaciente: telefonoPaciente ?? this.telefonoPaciente,
      nombreDoctor: nombreDoctor ?? this.nombreDoctor,
      especialidadDoctor: especialidadDoctor ?? this.especialidadDoctor,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      motivoConsulta: motivoConsulta ?? this.motivoConsulta,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      esPrimeraCita: esPrimeraCita ?? this.esPrimeraCita,
    );
  }

  @override
  List<Object?> get props => [
        id,
        idPaciente,
        idDoctor,
        nombrePaciente,
        emailPaciente,
        telefonoPaciente,
        nombreDoctor,
        especialidadDoctor,
        fecha,
        hora,
        motivoConsulta,
        estado,
        fechaCreacion,
        esPrimeraCita,
      ];
}
