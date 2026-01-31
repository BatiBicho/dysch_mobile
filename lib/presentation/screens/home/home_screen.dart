import 'package:dysch_mobile/presentation/screens/home/widgets/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../logic/auth/auth_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6), // Fondo grisáceo suave
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. Header: Perfil y Notificaciones
            const SliverToBoxAdapter(child: HomeHeader()),

            // 2. Tarjeta de Registro de Entrada (Reloj)
            const SliverToBoxAdapter(child: AttendanceCard()),

            // 3. Resumen Semanal
            const SliverToBoxAdapter(
              child: SectionTitle(title: 'Resumen Semanal'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Expanded(
                      child: SummaryCard(
                        icon: Icons.access_time_filled,
                        label: '38.5h',
                        subLabel: 'Trabajadas',
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: SummaryCard(
                        icon: Icons.calendar_month,
                        label: '4/5',
                        subLabel: 'Asistidos',
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Menú Rápido (Grid)
            const SliverToBoxAdapter(child: SectionTitle(title: 'Menú Rápido')),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  QuickMenuCard(
                    icon: Icons.edit_calendar,
                    label: 'Solicitar Permiso',
                    color: Colors.orange.shade100,
                    iconColor: Colors.orange,
                  ),
                  QuickMenuCard(
                    icon: Icons.schedule,
                    label: 'Mis Horarios',
                    color: Colors.orange.shade100,
                    iconColor: Colors.orange,
                    onTap: () => context.go('/horarios'),
                  ),
                  QuickMenuCard(
                    icon: Icons.payments_outlined,
                    label: 'Nómina',
                    color: Colors.orange.shade100,
                    iconColor: Colors.orange,
                  ),
                  QuickMenuCard(
                    icon: Icons.beach_access,
                    label: 'Vacaciones',
                    color: Colors.orange.shade100,
                    iconColor: Colors.orange,
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ), // Espacio final
          ],
        ),
      ),
    );
  }
}
