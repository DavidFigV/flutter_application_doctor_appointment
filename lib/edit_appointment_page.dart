import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditAppointmentPage extends StatefulWidget {
  const EditAppointmentPage({super.key});

  @override
  State<EditAppointmentPage> createState() => _EditAppointmentPageState();
}

class _EditAppointmentPageState extends State<EditAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lista estática de doctores
  final List<Map<String, String>> _doctores = [
    {'nombre': 'Dr. Carlos Méndez', 'especialidad': 'Cardiología'},
    {'nombre': 'Dra. María López', 'especialidad': 'Dermatología'},
    {'nombre': 'Dr. Juan Pérez', 'especialidad': 'Pediatría'},
    {'nombre': 'Dra. Ana García', 'especialidad': 'Traumatología'},
    {'nombre': 'Dr. Luis Rodríguez', 'especialidad': 'Oftalmología'},
  ];

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

  String? _citaId;
  Map<String, String>? _doctorSeleccionado;
  DateTime? _fechaSeleccionada;
  String? _horaSeleccionada;
  final TextEditingController _motivoController = TextEditingController();

  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _citaId = args['citaId'] as String;
      final citaData = args['citaData'] as Map<String, dynamic>;

      // Precargar datos
      _cargarDatos(citaData);
      _isInitialized = true;
    }
  }

  void _cargarDatos(Map<String, dynamic> citaData) {
    // Cargar doctor
    final nombreDoctor = citaData['nombre_doctor'];
    _doctorSeleccionado = _doctores.firstWhere(
      (doc) => doc['nombre'] == nombreDoctor,
      orElse: () => _doctores[0],
    );

    // Cargar fecha
    _fechaSeleccionada = (citaData['fecha'] as Timestamp).toDate();

    // Cargar hora
    _horaSeleccionada = citaData['hora'];

    // Cargar motivo
    _motivoController.text = citaData['motivo_consulta'] ?? '';

    setState(() {});
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
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

  Future<void> _actualizarCita() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_doctorSeleccionado == null) {
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

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('citas').doc(_citaId).update({
        'nombre_doctor': _doctorSeleccionado!['nombre'],
        'especialidad_doctor': _doctorSeleccionado!['especialidad'],
        'fecha': Timestamp.fromDate(_fechaSeleccionada!),
        'hora': _horaSeleccionada,
        'motivo_consulta': _motivoController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cita actualizada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar cita: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Editar Cita'),
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonFormField<Map<String, String>>(
                    initialValue: _doctorSeleccionado,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.person, color: Color(0xFF6366F1)),
                    ),
                    hint: const Text('Selecciona un doctor'),
                    items: _doctores.map((doctor) {
                      return DropdownMenuItem<Map<String, String>>(
                        value: doctor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              doctor['nombre']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              doctor['especialidad']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _doctorSeleccionado = value;
                      });
                    },
                  ),
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

                // Botón Actualizar
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _actualizarCita,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey[400],
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Actualizar Cita',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
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
