import 'package:flutter/material.dart';
import 'views/home/home_page.dart';
import 'views/auth/login_page.dart';
import 'views/auth/register_page.dart';
import 'views/auth/role_selection_page.dart';
import 'views/profile/profile_page.dart';
import 'views/appointments/appointment_page.dart';
import 'views/appointments/appointments_list_page.dart';
import 'views/appointments/edit_appointment_page.dart';
import 'views/messages/messages_page.dart';
import 'views/settings/settings_page.dart';
import 'views/dashboard/dashboard_page.dart';


class Routes {
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String appointment = '/appointment';
  static const String messages = '/messages';
  static const String settings = '/settings';
  static const String appointmentsList = '/appointments_list';
  static const String editAppointment = '/edit_appointment';
  static const String roleSelection = '/role_selection';
  static const String register = '/register';
  static const String dashboard = '/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings){
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case appointment:
        return MaterialPageRoute(builder: (_) => const AppointmentPage());
      case messages:
        return MaterialPageRoute(builder: (_) => const MessagesPage());
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case Routes.appointmentsList:
        return MaterialPageRoute(builder: (_) => const AppointmentsListPage());
      case Routes.editAppointment:
        return MaterialPageRoute(
          builder: (_) => const EditAppointmentPage(),
          settings: settings,
        );
      case Routes.roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionPage());
      case Routes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );
      case Routes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}