import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/data/models/schedule_model.dart';
import 'package:dysch_mobile/logic/auth/auth_cubit.dart';
import 'package:dysch_mobile/logic/schedule/schedule_cubit.dart';
import 'package:dysch_mobile/presentation/screens/schedule/widgets/upcoming_shift_item.dart';
import 'package:dysch_mobile/presentation/screens/schedule/widgets/weekly_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSchedules();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSchedules() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      context.read<ScheduleCubit>().getWeekSchedule(
            employeeId: authState.user.employeeId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildHeader(),
              if (state is WeekScheduleSuccess) _buildTabBar(),
              Expanded(child: _buildBody(state)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/shift-swap'),
        backgroundColor: AppColors.primary,
        elevation: 2,
        icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 20),
        label: const Text(
          'Intercambios',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Mis horarios',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: AppColors.primary, size: 22),
              onPressed: _loadSchedules,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: const Color(0xFF1A1A1A),
          unselectedLabelColor: const Color(0xFF9E9E9E),
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Esta semana'),
            Tab(text: 'Próxima semana'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ScheduleState state) {
    if (state is ScheduleLoading) {
      return Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
      );
    }

    if (state is WeekScheduleSuccess) {
      return TabBarView(
        controller: _tabController,
        children: [
          _buildWeekView(state.currentWeek.schedules, isCurrentWeek: true),
          _buildWeekView(state.nextWeek.schedules, isCurrentWeek: false),
        ],
      );
    }

    if (state is WeekScheduleEmpty) {
      return _buildEmptyState();
    }

    if (state is ScheduleError) {
      return _buildErrorState(state.message);
    }

    return const SizedBox();
  }

  Widget _buildWeekView(List<ScheduleModel> schedules, {required bool isCurrentWeek}) {
    if (schedules.isEmpty) {
      return _buildEmptyWeek(isCurrentWeek);
    }

    return RefreshIndicator(
      onRefresh: () async => _loadSchedules(),
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: WeeklyCalendarStrip(
              schedules: schedules,
              isCurrentWeek: isCurrentWeek,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  const Text(
                    'Turnos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${schedules.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == schedules.length) return const SizedBox(height: 120);
                final schedule = schedules[index];
                final dateTime = DateTime.parse(schedule.shiftDate);
                return UpcomingShiftItem(
                  schedule: schedule,
                  dateTime: dateTime,
                  isToday: _isToday(dateTime),
                );
              },
              childCount: schedules.length + 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWeek(bool isCurrentWeek) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_outlined, size: 52, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            isCurrentWeek ? 'Sin turnos esta semana' : 'Sin turnos la próxima semana',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
          ),
          const SizedBox(height: 4),
          const Text(
            'No tienes turnos asignados en este período.',
            style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 52, color: Colors.grey[200]),
            const SizedBox(height: 16),
            const Text(
              'Sin horarios asignados',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF555555)),
            ),
            const SizedBox(height: 6),
            const Text(
              'No tienes turnos para esta semana ni la siguiente.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E), height: 1.5),
            ),
            const SizedBox(height: 28),
            TextButton.icon(
              onPressed: _loadSchedules,
              icon: Icon(Icons.refresh_rounded, color: AppColors.primary, size: 18),
              label: Text('Actualizar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: 32, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _loadSchedules,
              child: Text('Reintentar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}