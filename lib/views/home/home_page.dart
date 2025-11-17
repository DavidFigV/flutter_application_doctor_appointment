import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para HapticFeedback en gestos
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../routes.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';
import '../../bloc/appointment/appointment_bloc.dart';
import '../../bloc/appointment/appointment_event.dart';
import '../../bloc/appointment/appointment_state.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../../bloc/dashboard/dashboard_event.dart';
import '../../bloc/dashboard/dashboard_state.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/doctor_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _userRole; // Caché del rol del usuario
  bool _isLoadingRole = true; // Estado de carga del rol

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserRole(); // Cargar rol una sola vez
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // Cargar datos del usuario
      context.read<UserBloc>().add(UserLoadRequested(authState.user.uid));
      // Cargar citas del usuario
      context.read<AppointmentBloc>().add(AppointmentLoadRequested(authState.user.uid));
    }
  }

  // Cargar rol del usuario una sola vez y cachear
  void _loadUserRole() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userRepo = context.read<UserRepository>();
      final role = await userRepo.getUserRole(authState.user.uid);
      if (mounted) {
        setState(() {
          _userRole = role;
          _isLoadingRole = false;
        });

        // Si es médico, cargar datos del dashboard
        if (role == 'medico') {
          final doctorRepo = context.read<DoctorRepository>();
          final doctorData = await doctorRepo.getDoctorData(authState.user.uid);

          if (doctorData != null && mounted) {
            context.read<DashboardBloc>().add(
              DashboardLoadRequested(
                doctorId: authState.user.uid,
                especialidad: doctorData.especialidad,
              ),
            );
          }
        }
      }
    } else {
      setState(() {
        _userRole = 'paciente';
        _isLoadingRole = false;
      });
    }
  }

  String _formatearFecha(Timestamp timestamp) {
    final fecha = timestamp.toDate();
    final meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // Navegar a Messages
      Navigator.pushNamed(context, Routes.messages);
    } else if (index == 2) {
      // Navegar a Settings
      Navigator.pushNamed(context, Routes.settings);
    }
  }

  // Construir card según rol del usuario (usa caché)
  Widget _buildRoleBasedCard() {
    if (_isLoadingRole) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF10B981)),
        ),
      );
    }

    if (_userRole == 'medico') {
      // Dashboard para médicos con datos en vivo
      return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          String subtitle = 'Estadísticas y métricas';

          // Si hay datos cargados, mostrar resumen
          if (state is DashboardLoaded) {
            final citasEsteMes = state.stats.citasEsteMes;
            final pendientes = state.stats.citasPendientes;
            subtitle = '$citasEsteMes este mes · $pendientes pendientes';
          }

          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, Routes.dashboard),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF10B981),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.dashboard,
                        color: Color(0xFF10B981),
                        size: 28,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ver Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      // Agendar cita para pacientes
      return GestureDetector(
        onTap: () => Navigator.pushNamed(context, Routes.appointment),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF6366F1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF6366F1),
                    size: 28,
                  ),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agendar Cita',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Reserva tu consulta',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  // ============================================================================
  // GESTO #1: RefreshIndicator - Pull-to-Refresh
  // ============================================================================
  /// Método para refrescar datos (citas y usuario) desde Firebase
  Future<void> _handleRefresh() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // Disparar eventos de carga de datos
      context.read<UserBloc>().add(UserLoadRequested(authState.user.uid));
      context.read<AppointmentBloc>().add(AppointmentLoadRequested(authState.user.uid));

      // Esperar un momento para que BLoC procese los eventos
      await Future.delayed(const Duration(milliseconds: 800));
    }
  }

  // ============================================================================
  // GESTO #2: GestureDetector onLongPress - Menú de Acciones Rápidas
  // ============================================================================
  /// Muestra un BottomSheet con acciones rápidas para una cita
  void _showQuickActions(BuildContext context, String appointmentId) {
    // Haptic feedback cuando se mantiene presionado
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador visual
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Título
              const Text(
                'Acciones Rápidas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Opción: Ver Detalles
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.info_outline, color: Colors.blue),
                ),
                title: const Text('Ver Detalles'),
                subtitle: const Text('Información completa de la cita'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Routes.appointmentsList);
                },
              ),
              // Opción: Editar
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_outlined, color: Colors.green),
                ),
                title: const Text('Editar Cita'),
                subtitle: const Text('Modificar fecha, hora o motivo'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Routes.appointmentsList);
                },
              ),
              // Opción: Cancelar
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.cancel_outlined, color: Colors.red),
                ),
                title: const Text('Cancelar Cita'),
                subtitle: const Text('Eliminar esta cita'),
                onTap: () {
                  Navigator.pop(context);
                  // Mostrar confirmación
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cancelar Cita'),
                      content: const Text('¿Estás seguro de que deseas cancelar esta cita?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Aquí iría la lógica de eliminación
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cita cancelada'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                          child: const Text('Sí', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        // RefreshIndicator: Permite pull-to-refresh para actualizar datos
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: const Color(0xFF6366F1), // Color del indicador
          child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con saludo y avatar
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    String userName = 'Usuario';
                    if (state is UserLoaded) {
                      userName = state.user.nombre;
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¡Hola, $userName!',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _userRole == 'medico'
                                  ? 'Tu agenda del día'
                                  : '¿En qué podemos ayudarte?',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Avatar del usuario
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFF6366F1),
                          child: Text(
                            userName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Dos tarjetas principales
                Row(
                  children: [
                    // Tarjeta condicional según rol (optimizado con caché)
                    Expanded(
                      child: _buildRoleBasedCard(),
                    ),
                    const SizedBox(width: 16),

                    // Tarjeta condicional según rol
                    Expanded(
                      child: _userRole == 'medico'
                        ? _buildQuickActionsCard()
                        : _buildConsejosMedicosCard(),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Quick Stats Row (solo para médicos)
                if (_userRole == 'medico') ...[
                  BlocBuilder<DashboardBloc, DashboardState>(
                    builder: (context, state) {
                      if (state is DashboardLoaded) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                // Pendientes
                                Expanded(
                                  child: _buildQuickStatCard(
                                    icon: Icons.schedule,
                                    label: 'Pendientes',
                                    value: '${state.stats.citasPendientes}',
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Total Pacientes
                                Expanded(
                                  child: _buildQuickStatCard(
                                    icon: Icons.people,
                                    label: 'Pacientes',
                                    value: '${state.stats.totalPacientesUnicos}',
                                    color: const Color(0xFF6366F1),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Nuevos
                                Expanded(
                                  child: _buildQuickStatCard(
                                    icon: Icons.person_add,
                                    label: 'Nuevos',
                                    value: '${state.stats.pacientesNuevos}',
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        );
                      }
                      // No mostrar nada si aún está cargando o hay error
                      return const SizedBox.shrink();
                    },
                  ),
                ],

                // Sección de Especialistas (solo para pacientes)
                if (_userRole != 'medico') ...[
                  const Text(
                    'Especialistas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSpecialistChip('Cardiología', Icons.favorite),
                        _buildSpecialistChip('Dermatología', Icons.face),
                        _buildSpecialistChip('Pediatría', Icons.child_care),
                        _buildSpecialistChip('Traumatología', Icons.healing),
                        _buildSpecialistChip('Oftalmología', Icons.visibility),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Sección de Citas (título condicional según rol)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _userRole == 'medico' ? 'Citas de Hoy' : 'Mis Próximas Citas',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.appointmentsList);
                      },
                      child: const Text(
                        'Ver todas',
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Lista de citas desde BLoC
                BlocBuilder<AppointmentBloc, AppointmentState>(
                  builder: (context, state) {
                    if (state is AppointmentLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      );
                    }

                    if (state is AppointmentError) {
                      return Center(
                        child: Text(
                          'Error al cargar citas',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }

                    if (state is AppointmentsLoaded) {
                      // Filtrar citas según el rol
                      List<dynamic> citasFiltradas;
                      if (_userRole == 'medico') {
                        // Para médicos: solo citas de hoy
                        final hoy = DateTime.now();
                        citasFiltradas = state.appointments.where((cita) {
                          final fechaCita = cita.fecha;
                          return fechaCita.year == hoy.year &&
                                 fechaCita.month == hoy.month &&
                                 fechaCita.day == hoy.day;
                        }).toList();
                      } else {
                        // Para pacientes: próximas citas (todas)
                        citasFiltradas = state.appointments;
                      }

                      if (citasFiltradas.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          width: double.maxFinite,
                          child: Column(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _userRole == 'medico'
                                  ? 'No tienes citas para hoy'
                                  : 'No tienes citas agendadas',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _userRole == 'medico'
                                  ? 'Disfruta tu día libre'
                                  : 'Agenda tu primera cita para comenzar',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Mostrar solo las primeras 3 citas
                      final citasLimitadas = citasFiltradas.take(3).toList();

                      return Column(
                        children: citasLimitadas.asMap().entries.map((entry) {
                          final index = entry.key;
                          final cita = entry.value;

                          return Column(
                            children: [
                              // GestureDetector con onLongPress para acciones rápidas
                              GestureDetector(
                                onLongPress: () {
                                  _showQuickActions(context, cita.id ?? '');
                                },
                                child: _buildAppointmentCard(
                                  cita.nombreDoctor,
                                  cita.especialidadDoctor,
                                  _formatearFecha(Timestamp.fromDate(cita.fecha)),
                                  cita.hora,
                                ),
                              ),
                              if (index < citasLimitadas.length - 1)
                                const SizedBox(height: 12),
                            ],
                          );
                        }).toList(),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No tienes citas agendadas',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
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
    );
  }

  // ============================================================================
  // Tarjeta de Acciones Rápidas (para médicos)
  // ============================================================================
  Widget _buildQuickActionsCard() {
    return GestureDetector(
      onTap: () => _showQuickActionsMenu(),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF8B5CF6),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flash_on,
                  color: Color(0xFF8B5CF6),
                  size: 28,
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acciones Rápidas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Accesos directos',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // Tarjeta de Consejos Médicos (para pacientes)
  // ============================================================================
  Widget _buildConsejosMedicosCard() {
    return GestureDetector(
      onTap: () {
        // Navegar a consejos médicos
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_information_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Consejos Médicos',
                      style: TextStyle(
                        color: const Color(0xFF1A1A1A),
                        fontSize: MediaQuery.of(context).size.width < 360 ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tips para tu salud',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // Menú de Acciones Rápidas (Bottom Sheet para médicos)
  // ============================================================================
  void _showQuickActionsMenu() {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador visual
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Título
              const Text(
                'Acciones Rápidas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Opción: Ver Dashboard
              _buildQuickActionMenuItem(
                icon: Icons.dashboard,
                title: 'Dashboard',
                subtitle: 'Estadísticas completas',
                color: const Color(0xFF10B981),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Routes.dashboard);
                },
              ),
              // Opción: Ver Citas
              _buildQuickActionMenuItem(
                icon: Icons.calendar_today,
                title: 'Mis Citas',
                subtitle: 'Ver todas las citas',
                color: const Color(0xFF6366F1),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Routes.appointmentsList);
                },
              ),
              // Opción: Perfil
              _buildQuickActionMenuItem(
                icon: Icons.person,
                title: 'Mi Perfil',
                subtitle: 'Ver y editar perfil',
                color: const Color(0xFF8B5CF6),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Routes.profile);
                },
              ),
              // Opción: Configuración
              _buildQuickActionMenuItem(
                icon: Icons.settings,
                title: 'Configuración',
                subtitle: 'Ajustes de la cuenta',
                color: Colors.grey[700]!,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Routes.settings);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================================
  // Item de menú para acciones rápidas
  // ============================================================================
  Widget _buildQuickActionMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // ============================================================================
  // Quick Stat Card (para métricas rápidas en HomePage de doctores)
  // ============================================================================
  Widget _buildQuickStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // GESTO #3: GestureDetector onDoubleTap - Chips de Especialistas
  // ============================================================================
  Widget _buildSpecialistChip(String title, IconData icon) {
    // GestureDetector con single tap y double tap
    return GestureDetector(
      // Single tap: Mostrar información del especialista
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Especialidad: $title'),
            duration: const Duration(seconds: 1),
            backgroundColor: const Color(0xFF6366F1),
          ),
        );
      },
      // Double tap: Navegar rápido a crear cita
      onDoubleTap: () {
        Navigator.pushNamed(context, Routes.appointment);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF6366F1)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
    String doctorName,
    String specialty,
    String date,
    String time,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  specialty,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}