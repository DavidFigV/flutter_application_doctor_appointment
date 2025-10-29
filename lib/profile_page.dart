import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Controladores de los campos del formulario
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  final TextEditingController lugarNacimientoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController enfermedadesController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Cargar datos del usuario desde Firestore
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        nombreController.text = data['nombre'] ?? '';
        edadController.text = data['edad'] ?? '';
        lugarNacimientoController.text = data['lugar_nacimiento'] ?? '';
        telefonoController.text = data['telefono'] ?? '';
        enfermedadesController.text = data['enfermedades'] ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Guardar datos del usuario en Firestore
  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('usuarios').doc(user.uid).set({
        'nombre': nombreController.text.trim(),
        'edad': edadController.text.trim(),
        'lugar_nacimiento': lugarNacimientoController.text.trim(),
        'telefono': telefonoController.text.trim(),
        'enfermedades': enfermedadesController.text.trim(),
        'email': user.email,
        'uid': user.uid,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Información guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header con avatar
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          nombreController.text.isEmpty
                              ? 'Usuario'
                              : nombreController.text,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'No disponible',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // Formulario
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información Personal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Nombre Completo
                          TextFormField(
                            controller: nombreController,
                            decoration: InputDecoration(
                              labelText: 'Nombre Completo',
                              hintText: 'Juan Pérez',
                              prefixIcon: const Icon(Icons.person_outline,
                                  color: Color(0xFF6366F1)),
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
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor ingresa tu nombre';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Edad
                          TextFormField(
                            controller: edadController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Edad',
                              hintText: '25',
                              prefixIcon: const Icon(Icons.cake_outlined,
                                  color: Color(0xFF6366F1)),
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
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final edad = int.tryParse(value);
                                if (edad == null || edad < 1 || edad > 120) {
                                  return 'Ingresa una edad válida';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Lugar de Nacimiento
                          TextFormField(
                            controller: lugarNacimientoController,
                            decoration: InputDecoration(
                              labelText: 'Lugar de Nacimiento',
                              hintText: 'Ciudad de México',
                              prefixIcon: const Icon(Icons.location_on_outlined,
                                  color: Color(0xFF6366F1)),
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
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Teléfono
                          TextFormField(
                            controller: telefonoController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Teléfono',
                              hintText: '+52 123 456 7890',
                              prefixIcon: const Icon(Icons.phone_outlined,
                                  color: Color(0xFF6366F1)),
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
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Sección Información Médica
                          const Text(
                            'Información Médica',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Padecimientos
                          TextFormField(
                            controller: enfermedadesController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Padecimientos o Enfermedades Previas',
                              hintText: 'Describe cualquier condición médica relevante...',
                              alignLabelWithHint: true,
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 60),
                                child: Icon(Icons.medical_information_outlined,
                                    color: Color(0xFF6366F1)),
                              ),
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
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Botón Guardar
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _saveUserData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Guardar Información',
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
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    edadController.dispose();
    lugarNacimientoController.dispose();
    telefonoController.dispose();
    enfermedadesController.dispose();
    super.dispose();
  }
}

