import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/appointment/appointment_bloc.dart';
import '../../bloc/appointment/appointment_event.dart';
import '../../bloc/appointment/appointment_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../models/appointment_model.dart';
import '../../routes.dart';
import '../../repositories/user_repository.dart';

class AppointmentsListPage extends StatefulWidget {
  const AppointmentsListPage({super.key});

  @override
  State<AppointmentsListPage> createState() => _AppointmentsListPageState();
}

class _AppointmentsListPageState extends State<AppointmentsListPage> {
  String? _currentUserId;
  String? _currentUserRole;

  static const _months = [
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
    'Dic',
  ];

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  void _initLoad() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.uid;
      _loadByRole();
    }
  }

  Future<void> _loadByRole() async {
    if (_currentUserId == null) return;
    if (!mounted) return;

    // Intentar obtener rol si no está cacheado
    if (_currentUserRole == null) {
      try {
        final userRepo = context.read<UserRepository>();
        _currentUserRole = await userRepo.getUserRole(_currentUserId!);
      } catch (_) {
        _currentUserRole = 'paciente';
      }
    }

    if (_currentUserRole == 'medico') {
      context.read<AppointmentBloc>().add(AppointmentLoadForDoctorRequested(_currentUserId!));
    } else {
      context.read<AppointmentBloc>().add(AppointmentLoadRequested(_currentUserId!));
    }
  }

  // ============================================================================
  // GESTO #4: RefreshIndicator - Pull-to-Refresh (método auxiliar)
  // ============================================================================
  Future<void> _handleRefresh() async {
    await _loadByRole();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day} ${_months[fecha.month - 1]} ${fecha.year}';
  }

  Map<String, dynamic> _buildCitaDataMap(AppointmentModel cita) {
    final data = cita.toMap();
    data['fecha'] = Timestamp.fromDate(cita.fecha);
    return data;
  }

  Widget _buildEstadoChip(String estado) {
    Color color;
    String label;

    switch (estado) {
      case 'completada':
        color = const Color(0xFF10B981);
        label = 'Completada';
        break;
      case 'cancelada':
        color = const Color(0xFFEF4444);
        label = 'Cancelada';
        break;
      default:
        color = const Color(0xFFF59E0B);
        label = 'Pendiente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<bool> _confirmAndDeleteCita(AppointmentModel cita) async {
    if (cita.id == null) return false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Cita'),
          content: Text('¿Estás seguro que deseas eliminar la cita con ${cita.nombreDoctor}?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _deleteCitaById(cita.id!);
      return true;
    }

    return false;
  }

  void _deleteCitaById(String citaId) {
    context.read<AppointmentBloc>().add(AppointmentDeleteRequested(citaId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mis Citas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AppointmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: const Color(0xFF6366F1),
          child: BlocBuilder<AppointmentBloc, AppointmentState>(
            builder: (context, state) {
              if (state is AppointmentLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6366F1),
                  ),
                );
              }

              if (state is AppointmentError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar citas',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is! AppointmentsLoaded || state.appointments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No tienes citas agendadas',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Presiona el botón + para agendar una',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }

              final citas = [...state.appointments]
                ..sort((a, b) => a.fecha.compareTo(b.fecha));

                      return RefreshIndicator(
                        onRefresh: _handleRefresh,
                        color: const Color(0xFF6366F1),
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: citas.length,
                          itemBuilder: (context, index) {
                            final cita = citas[index];
                  final citaId = cita.id ?? '';
                  final isDoctor = _currentUserRole == 'medico';

                  return Dismissible(
                    key: Key(citaId),
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, color: Colors.white, size: 32),
                          SizedBox(height: 4),
                          Text(
                            'Editar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    secondaryBackground: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete, color: Colors.white, size: 32),
                          SizedBox(height: 4),
                          Text(
                            'Eliminar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        return _confirmAndDeleteCita(cita);
                      } else {
                        Navigator.pushNamed(
                          context,
                          Routes.appointment,
                          arguments: {
                            'citaId': citaId,
                            'citaData': _buildCitaDataMap(cita),
                          },
                        );
                        return false;
                      }
                    },
                    onDismissed: (_) {},
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isDoctor ? cita.nombrePaciente : cita.nombreDoctor,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isDoctor ? cita.motivoConsulta : cita.especialidadDoctor,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildEstadoChip(cita.estado),
                                if (!isDoctor)
                                  IconButton(
                                    onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.appointment,
                                  arguments: {
                                    'citaId': citaId,
                                    'citaData': _buildCitaDataMap(cita),
                                  },
                                );
                                    },
                                    icon: const Icon(Icons.edit_outlined),
                                    color: const Color(0xFF6366F1),
                                    tooltip: 'Editar',
                                  ),
                                IconButton(
                                  onPressed: () => _confirmAndDeleteCita(cita),
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red,
                                  tooltip: 'Eliminar',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatearFecha(cita.fecha),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Icon(
                                  Icons.access_time,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  cita.hora,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    cita.motivoConsulta,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                        ),
                      );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, Routes.appointment);
        },
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nueva Cita',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
