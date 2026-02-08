import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/presentation/screens/incedent_history/widgets/incedent_history_card.dart';
import 'package:flutter/material.dart';

class IncidentHistoryScreen extends StatelessWidget {
  const IncidentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          title: const Text(
            'Historial de Incidencias',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list, color: Color(0xFFFF7043)),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Pendientes'),
              Tab(text: 'Aprobadas'),
              Tab(text: 'Rechazadas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildListView(), // Contenido para Pendientes
            const Center(child: Text('No hay aprobadas')), // Placeholder
            const Center(child: Text('No hay rechazadas')), // Placeholder
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('OCTUBRE 2023'),
        const IncidentHistoryCard(
          title: 'Permiso Personal',
          date: '12 Oct - 13 Oct',
          status: 'Pendiente',
          description:
              'Solicito permiso para ausentarme por motivos personales familiares.',
          icon: Icons.calendar_today,
          baseColor: AppColors.warning,
        ),
        const IncidentHistoryCard(
          title: 'Incapacidad Médica',
          date: '05 Oct - 08 Oct',
          status: 'En Revisión',
          description: 'Adjunto justificante médico del IMSS.',
          icon: Icons.medical_services,
          baseColor: AppColors.info,
          attachmentName: 'Justificante_IMSS_Oct.pdf',
        ),
        _buildSectionHeader('SEPTIEMBRE 2023'),
        const IncidentHistoryCard(
          title: 'Vacaciones',
          date: '20 Sep - 25 Sep',
          status: 'Rechazada',
          description: 'Viaje familiar planeado con anticipación.',
          icon: Icons.beach_access,
          baseColor: AppColors.error,
          supervisorResponse:
              'Lo siento, necesitamos cobertura completa durante el cierre de mes. Por favor reagenda para Octubre.',
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.2))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.2))),
        ],
      ),
    );
  }
}
