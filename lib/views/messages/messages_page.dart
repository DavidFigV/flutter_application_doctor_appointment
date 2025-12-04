import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _searchController = TextEditingController();

  // Lista estática de doctores (mismos que en appointment_page)
  final List<Map<String, dynamic>> _doctores = [
    {
      'nombre': 'Dr. Carlos Méndez',
      'especialidad': 'Cardiología',
      'online': true
    },
    {
      'nombre': 'Dra. María López',
      'especialidad': 'Dermatología',
      'online': true
    },
    {
      'nombre': 'Dr. Juan Pérez',
      'especialidad': 'Pediatría',
      'online': false
    },
    {
      'nombre': 'Dra. Ana García',
      'especialidad': 'Traumatología',
      'online': true
    },
    {
      'nombre': 'Dr. Luis Rodríguez',
      'especialidad': 'Oftalmología',
      'online': true
    },
  ];

  // Conversaciones de ejemplo con los doctores
  List<Map<String, dynamic>> _getConversaciones() {
    return [
      {
        'doctor': _doctores[0],
        'mensaje': '¿Cómo te sientes hoy? Recuerda tomar tus medicamentos.',
        'hora': '12:30',
      },
      {
        'doctor': _doctores[1],
        'mensaje': 'Los resultados de tu análisis están listos.',
        'hora': '11:45',
      },
      {
        'doctor': _doctores[2],
        'mensaje': 'Perfecto, nos vemos en la consulta del viernes.',
        'hora': '10:20',
      },
      {
        'doctor': _doctores[3],
        'mensaje': 'Recuerda hacer los ejercicios que te recomendé.',
        'hora': '09:15',
      },
      {
        'doctor': _doctores[4],
        'mensaje': 'Tu receta está lista para recoger.',
        'hora': 'Ayer',
      },
    ];
  }

  Future<void> _handleRefresh() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final conversaciones = _getConversaciones();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Messages',
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
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF6366F1),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _doctores.length,
                  itemBuilder: (context, index) {
                    final doctor = _doctores[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: const Color(0xFF6366F1),
                                child: const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                              if (doctor['online'])
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Divider(height: 1)),
            SliverList.separated(
              itemCount: conversaciones.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 80,
              ),
              itemBuilder: (context, index) {
                final conversacion = conversaciones[index];
                final doctor = conversacion['doctor'] as Map<String, dynamic>;

                return Container(
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFF6366F1),
                          child: const Icon(
                            Icons.person,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                        if (doctor['online'])
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      doctor['nombre'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        conversacion['mensaje'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: Text(
                      conversacion['hora'],
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Chat con ${doctor['nombre']} - Próximamente'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
