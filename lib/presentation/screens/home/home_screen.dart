import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/data/repositories/attendance_repository.dart';
import 'package:dysch_mobile/data/repositories/schedule_repository.dart';
import 'package:dysch_mobile/logic/auth/auth_cubit.dart';
import 'package:dysch_mobile/logic/schedule/schedule_cubit.dart';
import 'package:dysch_mobile/logic/schedule/weekly_summary_cubit.dart';
import 'package:dysch_mobile/presentation/screens/home/widgets/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit cubit) {
      if (cubit.state is AuthSuccess) {
        return (cubit.state as AuthSuccess).user;
      }
      return null;
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. Header: Perfil y Notificaciones
            SliverToBoxAdapter(
              child: HomeHeader(name: user?.firstName ?? 'Usuario'),
            ),

            // 2. Tarjeta de Registro de Entrada (Reloj)
            SliverToBoxAdapter(
              child: BlocProvider<ScheduleCubit>(
                create: (context) => ScheduleCubit(
                  RepositoryProvider.of<ScheduleRepository>(context),
                )..getSchedule, // 👈 IMPORTANTE: Llama al método inmediatamente
                child: const AttendanceCard(),
              ),
            ),

            // 3. Resumen Semanal
            const SliverToBoxAdapter(
              child: SectionTitle(title: 'Resumen Semanal'),
            ),
            SliverToBoxAdapter(
              child: BlocProvider<WeeklySummaryCubit>(
                create: (context) => WeeklySummaryCubit(
                  RepositoryProvider.of<AttendanceRepository>(context),
                )..getWeeklySummary(),
                child: BlocBuilder<WeeklySummaryCubit, WeeklySummaryState>(
                  builder: (context, state) {
                    if (state is WeeklySummarySuccess) {
                      final summary = state.summary;
                      final hoursBreakdown = summary.hoursBreakdown;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: hoursBreakdown != null
                            ? Column(
                                children: [
                                  // Horas desglosadas
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SummaryCard(
                                          icon: Icons.work_outline,
                                          label:
                                              hoursBreakdown.ordinary.formatted,
                                          subLabel: 'Ordinarias',
                                          color: AppColors.info,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: SummaryCard(
                                          icon: Icons.trending_up,
                                          label:
                                              hoursBreakdown.extras.formatted,
                                          subLabel: 'Extras',
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SummaryCard(
                                          icon: Icons.calendar_month,
                                          label: summary.summary.daysProgress,
                                          subLabel: 'Asistidos',
                                          color: Colors.purple,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: SummaryCard(
                                          icon: Icons.warning_outlined,
                                          label: hoursBreakdown
                                              .sobreExtras
                                              .formatted,
                                          subLabel: 'Sobre Extras',
                                          color: Colors.red.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: SummaryCard(
                                      icon: Icons.access_time_filled,
                                      label: summary.completed.hours.formatted,
                                      subLabel: 'Trabajadas',
                                      color: AppColors.info,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: SummaryCard(
                                      icon: Icons.calendar_month,
                                      label: summary.summary.daysProgress,
                                      subLabel: 'Asistidos',
                                      color: Colors.purple,
                                    ),
                                  ),
                                ],
                              ),
                      );
                    } else if (state is WeeklySummaryLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 100,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                height: 100,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Error o estado inicial - mostrar valores por defecto
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: SummaryCard(
                                icon: Icons.access_time_filled,
                                label: '0h 0m',
                                subLabel: 'Trabajadas',
                                color: AppColors.info,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: SummaryCard(
                                icon: Icons.calendar_month,
                                label: '0/0',
                                subLabel: 'Asistidos',
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
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
                    color: AppColors.warning.withValues(alpha: 0.1),
                    iconColor: AppColors.warning,
                    onTap: () => context.push('/request-absence'),
                  ),
                  // QuickMenuCard(
                  //   icon: Icons.schedule,
                  //   label: 'Mis Horarios',
                  //   color: AppColors.warning.withValues(alpha: 0.1),
                  //   iconColor: AppColors.warning,
                  //   onTap: () => context.go('/horarios'),
                  // ),
                  QuickMenuCard(
                    icon: Icons.history,
                    label: 'Historial de Incidentes',
                    color: AppColors.warning.withValues(alpha: 0.1),
                    iconColor: AppColors.warning,
                    onTap: () => context.push('/history'),
                  ),
                  // QuickMenuCard(
                  //   icon: Icons.beach_access,
                  //   label: 'Vacaciones',
                  //   color: AppColors.warning.withValues(alpha: 0.1),
                  //   iconColor: AppColors.warning,
                  //   onTap: () => context.push('/vacations'),
                  // ),
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
