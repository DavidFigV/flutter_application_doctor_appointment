// ============================================================================
// IMPORTS - Librerías necesarias para widgets Cupertino
// ============================================================================
import 'package:flutter/material.dart';  // Material Design (BottomNavigationBar)
import 'package:flutter/cupertino.dart'; // Widgets Cupertino (iOS-style)
import 'package:flutter_bloc/flutter_bloc.dart'; // Manejo de estado BLoC
import '../../routes.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';

// ============================================================================
// SETTINGS PAGE - Pantalla de configuración con widgets Cupertino
// ============================================================================
/// Pantalla de configuración que implementa 11 widgets Cupertino diferentes:
/// 1. CupertinoPageScaffold
/// 2. CupertinoNavigationBar
/// 3. CupertinoListSection (5 secciones)
/// 4. CupertinoListTile (7 items)
/// 5. CupertinoListTileChevron (3 usos)
/// 6. CupertinoSwitch (2 switches)
/// 7. CupertinoSlidingSegmentedControl (1 control de idioma)
/// 8. CupertinoSlider (1 slider de tamaño de fuente)
/// 9. CupertinoAlertDialog (1 diálogo de logout)
/// 10. CupertinoButton (2 botones en modales)
/// 11. CupertinoDialogAction (2 acciones en diálogo)
/// Adicionalmente: CupertinoModalPopup (2 modales full-screen)
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ============================================================================
  // ESTADO - Variables reactivas para controles interactivos
  // ============================================================================
  /// Control del switch de notificaciones (CupertinoSwitch #1)
  bool _notificationsEnabled = true;

  /// Control del switch de modo oscuro (CupertinoSwitch #2)
  bool _darkModeEnabled = false;

  /// Selección de idioma: 0 = Español, 1 = English (CupertinoSlidingSegmentedControl)
  int _selectedLanguage = 0;

  /// Valor del tamaño de fuente en puntos (CupertinoSlider)
  double _fontSize = 16.0;

  // ============================================================================
  // FRAGMENTO 7 (CodeSnap-plus): CupertinoModalPopup - Modal de Privacidad
  // ============================================================================
  // Muestra un modal full-screen con información de privacidad
  // Utiliza: CupertinoModalPopup, CupertinoPageScaffold, CupertinoNavigationBar, CupertinoButton
  void _showPrivacySheet() {
    // showCupertinoModalPopup: Presenta contenido en modal full-screen iOS-style
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        // Material wrapper: Soluciona renderizado en Flutter Web
        return Material(
          type: MaterialType.transparency,
          child: CupertinoPageScaffold(
            // CupertinoNavigationBar: Barra de navegación del modal
            navigationBar: CupertinoNavigationBar(
              automaticallyImplyLeading: false, // Oculta botón "< Back"
              middle: const Text('Privacidad'),
              // CupertinoButton: Botón de cierre estilo iOS
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ),
            child: SafeArea(
              // DefaultTextStyle: Evita subrayados amarillos en Flutter Web
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontFamily: '.SF Pro Text', // Fuente del sistema iOS
                  color: CupertinoColors.black,
                  fontSize: 15,
                  decoration: TextDecoration.none,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Política de Privacidad'),
                      const SizedBox(height: 8),
                      _buildParagraph(
                        'En nuestra aplicación de citas médicas, nos comprometemos a proteger tu privacidad y datos personales. Esta política describe cómo recopilamos, usamos y protegemos tu información.',
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Recopilación de Datos'),
                      const SizedBox(height: 8),
                      _buildParagraph(
                        'Recopilamos información personal como nombre, correo electrónico, número de teléfono y datos médicos relevantes únicamente para proporcionar nuestros servicios de manera efectiva.',
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Uso de la Información'),
                      const SizedBox(height: 8),
                      _buildParagraph(
                        'Utilizamos tu información para:\n• Gestionar tus citas médicas\n• Comunicarnos contigo sobre tus consultas\n• Mejorar nuestros servicios\n• Cumplir con requisitos legales',
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Seguridad'),
                      const SizedBox(height: 8),
                      _buildParagraph(
                        'Implementamos medidas de seguridad técnicas y organizativas para proteger tus datos contra acceso no autorizado, pérdida o alteración.',
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Tus Derechos'),
                      const SizedBox(height: 8),
                      _buildParagraph(
                        'Tienes derecho a acceder, corregir o eliminar tu información personal en cualquier momento. Contacta con nuestro equipo de soporte para ejercer estos derechos.',
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAboutSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Material(
          type: MaterialType.transparency,
          child: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              automaticallyImplyLeading: false,
              middle: const Text('Sobre Nosotros'),
              // CupertinoButton: Botón de cierre estilo iOS
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ),
            child: SafeArea(
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontFamily: '.SF Pro Text',
                  color: CupertinoColors.black,
                  fontSize: 15,
                  decoration: TextDecoration.none,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Icon(
                          Icons.local_hospital,
                          size: 80,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Doctor Appointment App'),
                      const SizedBox(height: 8),
                      _buildParagraph(
                        'Nuestra aplicación facilita la gestión de citas médicas, conectando pacientes con profesionales de la salud de manera rápida y segura.',
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Nuestra Misión'),
                      const SizedBox(height: 8),
                      _buildParagraph(
                        'Mejorar el acceso a servicios de salud mediante tecnología innovadora, ofreciendo una plataforma intuitiva que simplifica la comunicación entre pacientes y médicos.',
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Características'),
                      const SizedBox(height: 8),
                      _buildParagraph(
                        '• Agendamiento fácil de citas\n• Especialistas calificados\n• Mensajería con doctores\n• Historial médico seguro\n• Recordatorios de citas',
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Versión'),
                      const SizedBox(height: 8),
                      _buildParagraph('1.0.0'),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Contacto'),
                      const SizedBox(height: 8),
                      _buildParagraph(
                        'Email: support@doctorapp.com\nTeléfono: +52 123 456 7890',
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================================
  // FRAGMENTO 6 (CodeSnap-plus): CupertinoAlertDialog - Confirmación de Logout
  // ============================================================================
  // Muestra un diálogo de confirmación estilo iOS para cerrar sesión
  // Utiliza: CupertinoAlertDialog, CupertinoDialogAction con acción destructiva
  void _showLogoutDialog() {
    // showCupertinoDialog: Presenta un diálogo estilo iOS
    showCupertinoDialog(
      context: context,
      builder: (context) {
        // CupertinoAlertDialog: Diálogo con bordes redondeados iOS
        return CupertinoAlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: [
            // CupertinoDialogAction #1: Botón normal (Cancelar)
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            // CupertinoDialogAction #2: Botón destructivo (rojo)
            CupertinoDialogAction(
              isDestructiveAction: true, // Hace el texto rojo
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
                // Dispara evento de logout al BLoC
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
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

  // ============================================================================
  // FRAGMENTO 1 (CodeSnap-plus): CupertinoPageScaffold + CupertinoNavigationBar
  // ============================================================================
  /// Método principal que construye la interfaz de la pantalla de configuración
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      // Escucha cambios en el estado de autenticación
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Redirige a login si el usuario cierra sesión
          Navigator.pushReplacementNamed(context, Routes.login);
        }
      },
      child: Scaffold(
        // Scaffold de Material envuelve CupertinoPageScaffold para mantener BottomNavigationBar
        body: CupertinoPageScaffold(
          // CupertinoPageScaffold: Estructura de página estilo iOS
          backgroundColor: CupertinoColors.systemGroupedBackground, // Fondo agrupado iOS
          // CupertinoNavigationBar: Barra de navegación estilo iOS
          navigationBar: const CupertinoNavigationBar(
            middle: Text(
              'Configuración', // Título centrado
              style: TextStyle(
                fontWeight: FontWeight.w600, // Semi-bold
              ),
            ),
            backgroundColor: CupertinoColors.white,
            border: null, // Sin borde inferior
          ),
          child: SafeArea(
            child: SingleChildScrollView(
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
                        color: Colors.white,
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
              const SizedBox(height: 20),
              // CupertinoListSection: Sección agrupada estilo iOS
              CupertinoListSection.insetGrouped(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                header: const Text(
                  'PREFERENCIAS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                children: [
                  // CupertinoListTile + CupertinoSwitch #1: Notificaciones
                  CupertinoListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemOrange, // Color del sistema iOS
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: const Text('Notificaciones'),
                    // CupertinoSwitch: Toggle estilo iOS (verde cuando activado)
                    trailing: CupertinoSwitch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value; // Actualiza estado
                        });
                      },
                    ),
                  ),
                  // CupertinoListTile + CupertinoSwitch #2: Modo Oscuro
                  CupertinoListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemIndigo,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.dark_mode_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: const Text('Modo Oscuro'),
                    trailing: CupertinoSwitch(
                      value: _darkModeEnabled,
                      onChanged: (value) {
                        setState(() {
                          _darkModeEnabled = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CupertinoListSection.insetGrouped(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                header: const Text(
                  'IDIOMA',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    // CupertinoSlidingSegmentedControl: Control segmentado iOS 13+
                    // Animación deslizante suave al cambiar de opción
                    child: CupertinoSlidingSegmentedControl<int>(
                      groupValue: _selectedLanguage, // Valor actual seleccionado
                      children: const {
                        0: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Español'),
                        ),
                        1: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('English'),
                        ),
                      },
                      onValueChanged: (value) {
                        setState(() {
                          _selectedLanguage = value!; // Actualiza idioma seleccionado
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CupertinoListSection.insetGrouped(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                header: const Text(
                  'TAMAÑO DE FUENTE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Indicador visual del rango del slider
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'A', // "A" pequeña = tamaño mínimo
                              style: TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                            Text(
                              '${_fontSize.toInt()} pt', // Valor actual en puntos
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              'A', // "A" grande = tamaño máximo
                              style: TextStyle(
                                fontSize: 20,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // CupertinoSlider: Slider delgado estilo iOS
                        CupertinoSlider(
                          value: _fontSize,
                          min: 12.0, // Tamaño mínimo
                          max: 24.0, // Tamaño máximo
                          divisions: 12, // 12 pasos discretos
                          onChanged: (value) {
                            setState(() {
                              _fontSize = value; // Actualiza tamaño de fuente
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Sección de Cuenta con múltiples CupertinoListTile
              CupertinoListSection.insetGrouped(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                header: const Text(
                  'CUENTA',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                children: [
                  // CupertinoListTile #1: Perfil con navegación
                  CupertinoListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1), // Color índigo personalizado
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: const Text('Perfil'),
                    trailing: const CupertinoListTileChevron(), // Flecha ">" iOS
                    onTap: () {
                      Navigator.pushNamed(context, Routes.profile);
                    },
                  ),
                  // CupertinoListTile #2: Privacidad con modal
                  CupertinoListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6), // Color morado
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: const Text('Privacidad'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: _showPrivacySheet, // Abre CupertinoModalPopup
                  ),
                  // CupertinoListTile #3: Acerca de con modal
                  CupertinoListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B), // Color naranja
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: const Text('Acerca de nosotros'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: _showAboutSheet, // Abre CupertinoModalPopup
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Log Out con CupertinoListSection
              CupertinoListSection.insetGrouped(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  CupertinoListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: CupertinoColors.systemRed),
                    ),
                    onTap: _showLogoutDialog,
                  ),
                ],
              ),
            ],
          ),
        ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2,
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
}