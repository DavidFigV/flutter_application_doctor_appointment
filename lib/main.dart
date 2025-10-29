import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'firebase_options.dart';
import 'routes.dart';
// Importar BLoCs
import 'bloc/auth/auth_bloc.dart';
import 'bloc/user/user_bloc.dart';
import 'bloc/appointment/appointment_bloc.dart';
// Importar Repositorios
import 'repositories/auth_repository.dart';
import 'repositories/user_repository.dart';
import 'repositories/appointment_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Crear instancias de los repositorios
    final authRepository = AuthRepository();
    final userRepository = UserRepository();
    final appointmentRepository = AppointmentRepository();

    return MultiBlocProvider(
      providers: [
        // Proveedor del AuthBloc
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository)
            ..add(const AuthCheckRequested()),
        ),
        // Proveedor del UserBloc
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(userRepository: userRepository),
        ),
        // Proveedor del AppointmentBloc
        BlocProvider<AppointmentBloc>(
          create: (context) => AppointmentBloc(
            appointmentRepository: appointmentRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Doctor Appointment App',
        initialRoute: Routes.login,
        onGenerateRoute: Routes.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}