import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../lib/firebase_options.dart';

/// Script de utilidad para listar UIDs de doctores y pacientes.
/// Debe ejecutarse con Flutter (no con `dart run`), porque requiere dart:ui.
///
/// Pasos en PowerShell/CMD (no WSL):
///   flutter pub get
///   flutter pub run tool/list_users.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestore = FirebaseFirestore.instance;

  final doctores = await firestore.collection('doctores').get();
  final usuarios = await firestore.collection('usuarios').get();

  print('=== DOCTORES (${doctores.docs.length}) ===');
  for (final doc in doctores.docs) {
    final data = doc.data();
    final nombre = data['nombre'] ?? '';
    final especialidad = data['especialidad'] ?? '';
    print('- ${doc.id} | nombre: $nombre | especialidad: $especialidad');
  }

  print('\n=== PACIENTES (${usuarios.docs.length}) ===');
  for (final doc in usuarios.docs) {
    final data = doc.data();
    final nombre = data['nombre'] ?? '';
    final email = data['email'] ?? '';
    print('- ${doc.id} | nombre: $nombre | email: $email');
  }
}
