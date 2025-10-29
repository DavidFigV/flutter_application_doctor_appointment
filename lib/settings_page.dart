import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'routes.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'bloc/auth/auth_state.dart';
import 'bloc/user/user_bloc.dart';
import 'bloc/user/user_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _showPrivacySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicador de arrastre
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Título
                  const Text(
                    'Privacidad',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Contenido
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Política de Privacidad'),
                          _buildParagraph(
                            'En nuestra aplicación de citas médicas, nos comprometemos a proteger tu privacidad y datos personales. Esta política describe cómo recopilamos, usamos y protegemos tu información.',
                          ),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Recopilación de Datos'),
                          _buildParagraph(
                            'Recopilamos información personal como nombre, correo electrónico, número de teléfono y datos médicos relevantes únicamente para proporcionar nuestros servicios de manera efectiva.',
                          ),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Uso de la Información'),
                          _buildParagraph(
                            'Utilizamos tu información para:\n• Gestionar tus citas médicas\n• Comunicarnos contigo sobre tus consultas\n• Mejorar nuestros servicios\n• Cumplir con requisitos legales',
                          ),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Seguridad'),
                          _buildParagraph(
                            'Implementamos medidas de seguridad técnicas y organizativas para proteger tus datos contra acceso no autorizado, pérdida o alteración.',
                          ),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Tus Derechos'),
                          _buildParagraph(
                            'Tienes derecho a acceder, corregir o eliminar tu información personal en cualquier momento. Contacta con nuestro equipo de soporte para ejercer estos derechos.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Botón cerrar
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAboutSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicador de arrastre
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Título
                  const Text(
                    'Sobre Nosotros',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Contenido
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Icon(
                              Icons.local_hospital,
                              size: 80,
                              color: const Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Doctor Appointment App'),
                          _buildParagraph(
                            'Nuestra aplicación facilita la gestión de citas médicas, conectando pacientes con profesionales de la salud de manera rápida y segura.',
                          ),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Nuestra Misión'),
                          _buildParagraph(
                            'Mejorar el acceso a servicios de salud mediante tecnología innovadora, ofreciendo una plataforma intuitiva que simplifica la comunicación entre pacientes y médicos.',
                          ),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Características'),
                          _buildParagraph(
                            '• Agendamiento fácil de citas\n• Especialistas calificados\n• Mensajería con doctores\n• Historial médico seguro\n• Recordatorios de citas',
                          ),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Versión'),
                          _buildParagraph('1.0.0'),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Contacto'),
                          _buildParagraph(
                            'Email: support@doctorapp.com\nTeléfono: +52 123 456 7890',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Botón cerrar
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, Routes.login);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Configuración',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header con avatar y nombre
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFF6366F1),
                      child: const Icon(
                        Icons.person,
                        size: 35,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(width: 16),
                    BlocBuilder<UserBloc, UserState>(
                      builder: (context, state) {
                        String userName = 'Usuario';
                        if (state is UserLoaded) {
                          userName = state.user.nombre;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Perfil',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Opciones de menú
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      iconColor: const Color(0xFF6366F1),
                      iconBgColor: const Color(0xFF6366F1),
                      title: 'Perfil',
                      onTap: () {
                        Navigator.pushNamed(context, Routes.profile);
                      },
                    ),
                    const Divider(height: 1, indent: 80),
                    _buildMenuItem(
                      icon: Icons.lock_outline,
                      iconColor: const Color(0xFF8B5CF6),
                      iconBgColor: const Color(0xFF8B5CF6),
                      title: 'Privacidad',
                      onTap: _showPrivacySheet,
                    ),
                    const Divider(height: 1, indent: 80),
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      iconColor: const Color(0xFFF59E0B),
                      iconBgColor: const Color(0xFFF59E0B),
                      title: 'Acerca de nosotros',
                      onTap: _showAboutSheet,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Log Out
              Container(
                color: Colors.white,
                child: _buildMenuItem(
                  icon: Icons.logout,
                  iconColor: Colors.red,
                  iconBgColor: Colors.red,
                  title: 'Cerrar Sesión',
                  onTap: _showLogoutDialog,
                  showArrow: false,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2, // Settings está en index 2
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacementNamed(context, Routes.home);
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, Routes.messages);
            }
          },
          selectedItemColor: const Color(0xFF6366F1),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Mensajes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Configuración',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A1A1A),
        ),
      ),
      trailing: showArrow
          ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }
}
