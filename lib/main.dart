import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'bloc/auth/auth_event.dart';
import 'firebase_options.dart';
import 'routes.dart';
// Importar BLoCs
import 'bloc/auth/auth_bloc.dart';
import 'bloc/user/user_bloc.dart';
import 'bloc/appointment/appointment_bloc.dart';
import 'bloc/dashboard/dashboard_bloc.dart';
// Importar Repositorios
import 'repositories/auth_repository.dart';
import 'repositories/user_repository.dart';
import 'repositories/appointment_repository.dart';
import 'repositories/doctor_repository.dart';
import 'repositories/especialidad_repository.dart';
import 'repositories/dashboard_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Inicializar formato de fechas en español
  await initializeDateFormatting('es', null);

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
    final doctorRepository = DoctorRepository();
    final especialidadRepository = EspecialidadRepository();
    final dashboardRepository = DashboardRepository(
      appointmentRepository: appointmentRepository,
      doctorRepository: doctorRepository,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => authRepository),
        RepositoryProvider<UserRepository>(create: (_) => userRepository),
        RepositoryProvider<AppointmentRepository>(create: (_) => appointmentRepository),
        RepositoryProvider<DoctorRepository>(create: (_) => doctorRepository),
        RepositoryProvider<EspecialidadRepository>(create: (_) => especialidadRepository),
        RepositoryProvider<DashboardRepository>(create: (_) => dashboardRepository),
      ],
      child: MultiBlocProvider(
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
          // Proveedor del DashboardBloc
          BlocProvider<DashboardBloc>(
            create: (context) => DashboardBloc(
              dashboardRepository: dashboardRepository,
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Doctor Appointment App',
          initialRoute: Routes.login,
          onGenerateRoute: Routes.generateRoute,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}