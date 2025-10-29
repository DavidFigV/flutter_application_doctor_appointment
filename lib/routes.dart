import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'appointment_page.dart';
import 'messages_page.dart';
import 'settings_page.dart';
import 'appointments_list_page.dart';
import 'edit_appointment_page.dart';


class Routes {
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String appointment = '/appointment';
  static const String messages = '/messages';
  static const String settings = '/settings';
  static const String appointmentsList = '/appointments_list';
  static const String editAppointment = '/edit_appointment';

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