import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/logic/incident/incident_cubit.dart';
import 'package:dysch_mobile/presentation/screens/incedent_history/widgets/incedent_history_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IncidentHistoryScreen extends StatefulWidget {
  const IncidentHistoryScreen({super.key});

  @override
  State<IncidentHistoryScreen> createState() => _IncidentHistoryScreenState();
}

class _IncidentHistoryScreenState extends State<IncidentHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<IncidentCubit>().getIncidents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Historial de Incidencias',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.filter_list, color: Color(0xFFFF7043)),
        //     onPressed: () {},
        //   ),
        // ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Pendientes'),
            Tab(text: 'Aprobadas'),
            Tab(text: 'Rechazadas'),
          ],
        ),
      ),
      body: BlocBuilder<IncidentCubit, IncidentState>(
        builder: (context, state) {
          if (state is IncidentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is IncidentsLoaded) {
            final allIncidents = state.incidents;
            final pendingIncidents = allIncidents
                .where((i) => i.status == 'PENDING')
                .toList();
            final approvedIncidents = allIncidents
                .where((i) => i.status == 'APPROVED')
                .toList();
            final rejectedIncidents = allIncidents
                .where((i) => i.status == 'REJECTED')
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildIncidentsList(pendingIncidents),
                _buildIncidentsList(approvedIncidents),
                _buildIncidentsList(rejectedIncidents),
              ],
            );
          }

          if (state is IncidentError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return const Center(child: Text('Sin datos'));
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   backgroundColor: AppColors.primary,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
    );
  }

  Widget _buildIncidentsList(List incidents) {
    if (incidents.isEmpty) {
      return const Center(child: Text('No hay incidencias en esta categoria'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: incidents.length,
      itemBuilder: (context, index) {
        final incident = incidents[index];
        return IncidentHistoryCard(
          title: incident.displayType,
          date: '${incident.startDate} - ${incident.endDate}',
          status: incident.displayStatus,
          description: incident.description,
          icon: _getIncidentIcon(incident.incidentType),
          baseColor: _getIncidentColor(incident.status),
          attachmentName: incident.evidenceFiles.isNotEmpty
              ? incident.evidenceFiles.first.fileType
              : null,
          supervisorResponse: incident.rejectionReason,
        );
      },
    );
  }

  IconData _getIncidentIcon(String incidentType) {
    switch (incidentType) {
      case 'SICK_LEAVE':
        return Icons.medical_services;
      case 'VACATION':
        return Icons.beach_access;
      case 'PERMIT':
        return Icons.calendar_today;
      case 'UNEXCUSED':
        return Icons.close_outlined;
      case 'WORK_ACCIDENT':
        return Icons.warning_outlined;
      default:
        return Icons.info_outlined;
    }
  }

  Color _getIncidentColor(String status) {
    switch (status) {
      case 'PENDING':
        return AppColors.warning;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }
}
