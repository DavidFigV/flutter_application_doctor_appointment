import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/appointment/appointment_bloc.dart';
import '../../bloc/appointment/appointment_event.dart';
import '../../bloc/appointment/appointment_state.dart';
import '../../repositories/especialidad_repository.dart';
import '../../repositories/doctor_repository.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/appointment_repository.dart';
import '../../models/especialidad_model.dart';
import '../../models/appointment_model.dart';
import '../../models/doctor_model.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  // Lista de horarios disponibles
  final List<String> _horarios = [
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  String? _especialidadSeleccionada;
  String? _doctorSeleccionadoUid;
  String? _doctorSeleccionadoNombre;
  DateTime? _fechaSeleccionada;
  String? _horaSeleccionada;
  final TextEditingController _motivoController = TextEditingController();

  String? _userUid;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _userUid = authState.user.uid;
    }
  }

  Future<Map<String, String>> _loadDoctorNames(
    List<DoctorModel> doctores,
    UserRepository userRepo,
  ) async {
    final Map<String, String> names = {};
    for (var doctor in doctores) {
      try {
        final userData = await userRepo.getUserData(doctor.uid);
        names[doctor.uid] = userData.nombre;
      } catch (e) {
        names[doctor.uid] = 'Doctor';
      }
    }
    return names;
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  String _formatearFecha(DateTime fecha) {
    final meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  Future<void> _agendarCita() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_especialidadSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una especialidad')),
      );
      return;
    }

    if (_doctorSeleccionadoUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un doctor')),
      );
      return;
    }

    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una fecha')),
      );
      return;
    }

    if (_horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una hora')),
      );
      return;
    }

    if (_userUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no autenticado')),
      );
      return;
    }

    try {
      // Obtener repositorios
      final userRepo = context.read<UserRepository>();
      final appointmentRepo = context.read<AppointmentRepository>();

      // Obtener datos del usuario
      final userData = await userRepo.getUserData(_userUid!);

      // Calcular si es primera cita con este doctor
      final citasPrevias = await appointmentRepo.getTotalCitasByDoctorAndPaciente(
        _doctorSeleccionadoUid!,
        _userUid!,
      );
      final esPrimeraCita = citasPrevias == 0;

      // Crear modelo de cita
      final cita = AppointmentModel(
        idPaciente: _userUid!,
        nombrePaciente: userData.nombre,
        emailPaciente: userData.email,
        telefonoPaciente: userData.telefono ?? '',
        nombreDoctor: _doctorSeleccionadoNombre!,
        especialidadDoctor: _especialidadSeleccionada!,
        fecha: _fechaSeleccionada!,
        hora: _horaSeleccionada!,
        motivoConsulta: _motivoController.text.trim(),
        idDoctor: _doctorSeleccionadoUid!,
        estado: 'pendiente',
        fechaCreacion: DateTime.now(),
        esPrimeraCita: esPrimeraCita,
      );

      // Usar BLoC para crear la cita
      context.read<AppointmentBloc>().add(AppointmentCreateRequested(cita));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar la cita: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final especialidadRepo = context.read<EspecialidadRepository>();
    final doctorRepo = context.read<DoctorRepository>();
    final userRepo = context.read<UserRepository>();

    return BlocListener<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state is AppointmentOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is AppointmentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Agendar Cita'),
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de Especialidad
                  const Text(
                    'Especialidad Médica',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<EspecialidadModel>>(
                    stream: especialidadRepo.getEspecialidadesActivas(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[300]!),
                          ),
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      final especialidades = snapshot.data ?? [];

                      // Filtrar duplicados por nombre
                      final nombresUnicos = <String>{};
                      final especialidadesUnicas = <EspecialidadModel>[];
                      for (var especialidad in especialidades) {
                        if (!nombresUnicos.contains(especialidad.nombre)) {
                          nombresUnicos.add(especialidad.nombre);
                          especialidadesUnicas.add(especialidad);
                        }
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonFormField<String>(
                          initialValue: _especialidadSeleccionada,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.medical_services,
                                color: Color(0xFF6366F1)),
                            hintText: 'Selecciona una especialidad',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ),
                          items: especialidadesUnicas.map((especialidad) {
                            return DropdownMenuItem<String>(
                              value: especialidad.nombre,
                              child: Text(especialidad.nombre),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _especialidadSeleccionada = value;
                              // Reset doctor selection when specialty changes
                              _doctorSeleccionadoUid = null;
                              _doctorSeleccionadoNombre = null;
                            });
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Selector de Doctor
                  const Text(
                    'Selecciona un Doctor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _especialidadSeleccionada == null
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.grey[600]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Primero selecciona una especialidad',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                        )
                      : StreamBuilder<List<DoctorModel>>(
                          stream: doctorRepo
                              .getDoctoresByEspecialidad(_especialidadSeleccionada!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red[300]!),
                                ),
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }

                            final doctores = snapshot.data ?? [];

                            if (doctores.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: Colors.grey[600]),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'No hay doctores disponibles para esta especialidad',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return FutureBuilder<Map<String, String>>(
                              future: _loadDoctorNames(doctores, userRepo),
                              builder: (context, namesSnapshot) {
                                if (!namesSnapshot.hasData) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF6366F1),
                                      ),
                                    ),
                                  );
                                }

                                final doctorNames = namesSnapshot.data!;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _doctorSeleccionadoUid,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.person,
                                          color: Color(0xFF6366F1)),
                                      hintText: 'Selecciona un doctor',
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF6366F1),
                                        ),
                                      ),
                                    ),
                                    items: doctores.map((doctor) {
                                      return DropdownMenuItem<String>(
                                        value: doctor.uid,
                                        child: Text(
                                          doctorNames[doctor.uid] ?? 'Doctor',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _doctorSeleccionadoUid = value;
                                        _doctorSeleccionadoNombre =
                                            doctorNames[value] ?? 'Doctor';
                                      });
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                  const SizedBox(height: 24),

                // Selector de Fecha
                const Text(
                  'Fecha de la Cita',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _seleccionarFecha,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _fechaSeleccionada == null
                              ? 'Seleccionar fecha'
                              : _formatearFecha(_fechaSeleccionada!),
                          style: TextStyle(
                            fontSize: 16,
                            color: _fechaSeleccionada == null
                                ? Colors.grey[600]
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Selector de Hora
                const Text(
                  'Hora de la Cita',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: _horaSeleccionada,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.access_time, color: Color(0xFF6366F1)),
                    ),
                    hint: const Text('Selecciona una hora'),
                    items: _horarios.map((hora) {
                      return DropdownMenuItem<String>(
                        value: hora,
                        child: Text(hora),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _horaSeleccionada = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Motivo de Consulta
                const Text(
                  'Motivo de Consulta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _motivoController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe el motivo de tu consulta...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF6366F1),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa el motivo de la consulta';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Botón Agendar
                BlocBuilder<AppointmentBloc, AppointmentState>(
                  builder: (context, state) {
                    final isLoading = state is AppointmentLoading;

                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _agendarCita,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey[400],
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Agendar Cita',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }
}
