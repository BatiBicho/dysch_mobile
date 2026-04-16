import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/data/models/shift_swap_model.dart';
import 'package:dysch_mobile/logic/auth/auth_cubit.dart';
import 'package:dysch_mobile/logic/shift_swap/shift_swap_cubit.dart';
import 'package:dysch_mobile/presentation/screens/shift_swap/create_swap_screen.dart';
import 'package:dysch_mobile/presentation/screens/shift_swap/widgets/shift_swap_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShiftSwapScreen extends StatefulWidget {
  const ShiftSwapScreen({super.key});

  @override
  State<ShiftSwapScreen> createState() => _ShiftSwapScreenState();
}

class _ShiftSwapScreenState extends State<ShiftSwapScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
    context.read<ShiftSwapCubit>().getShiftSwaps();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshSwaps() => context.read<ShiftSwapCubit>().getShiftSwaps();

  // Retorna TRUE en caso de que el usuario tenga una petición pendiente.
  bool _hasActiveSwap(List<ShiftSwapModel> swaps) {
    final authState = context.read<AuthCubit>().state;
    final currentCode = authState is AuthSuccess ? authState.user.employeeCode : '';
    return swaps.any((s) =>
        (s.status == 'PENDING_PEER' || s.status == 'PENDING_SUPERVISOR') &&
        s.requestingEmployeeCode == currentCode);
  }

  void _onFabTapped(List<ShiftSwapModel> swaps) {
    if (_hasActiveSwap(swaps)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Ya tienes una solicitud en progreso. Espera a que se resuelva antes de crear una nueva.',
          ),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateSwapScreen()),
    ).then((_) => _refreshSwaps());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: BlocConsumer<ShiftSwapCubit, ShiftSwapState>(
              listener: (context, state) {
                if (state is ShiftSwapResponseSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                  _refreshSwaps();
                }
              },
              builder: (context, state) {
                if (state is ShiftSwapLoading) {
                  return Center(
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  );
                }

                if (state is ShiftSwapsLoaded) {
                  final all = state.swaps;
                  final pending = all.where((s) => s.status == 'PENDING_PEER' || s.status == 'PENDING_SUPERVISOR').toList();
                  final approved = all.where((s) => s.status == 'APPROVED').toList();
                  final rejected = all.where((s) => s.status == 'REJECTED').toList();
                  final hasActive = _hasActiveSwap(all);


                  return Stack(
                    children: [
                      TabBarView(
                        controller: _tabController,
                        children: [
                          _buildList(pending),
                          _buildList(approved),
                          _buildList(rejected),
                          _buildList(all),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _buildFAB(all, hasActive),
                      ),
                    ],
                  );
                }

                if (state is ShiftSwapError) {
                  return _buildError(state.message);
                }

                return const Center(child: Text('Sin datos'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 22, color: Color(0xFF1A1A1A)),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(
              child: Text(
                'Intercambios',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.4,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh_rounded, size: 22, color: AppColors.primary),
              onPressed: _refreshSwaps,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final labels = [ 'Pendientes', 'Aprobadas', 'Rechazadas', 'Todas' ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(labels.length, (i) {
            final isSelected = _selectedTab == i;
            return GestureDetector(
              onTap: () {
                _tabController.animateTo(i);
                setState(() => _selectedTab = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                      : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF757575),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildList(List<ShiftSwapModel> swaps) {
    if (swaps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz_rounded, size: 52, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text(
              'Sin solicitudes aquí',
              style: TextStyle(color: Colors.grey[500], fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Las nuevas solicitudes aparecerán aquí.',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _refreshSwaps(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        itemCount: swaps.length,
        itemBuilder: (context, index) => ShiftSwapCard(swap: swaps[index]),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: 36, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF555555), fontSize: 14)),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _refreshSwaps,
              child: Text('Reintentar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(List<ShiftSwapModel> swaps, bool hasActive) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasActive)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tienes una solicitud en progreso.',
                      style: TextStyle(fontSize: 12, color: Color(0xFFB45309), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _onFabTapped(swaps),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasActive ? const Color(0xFFD1D5DB) : AppColors.primary,
                elevation: hasActive ? 0 : 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: Icon(
                hasActive ? Icons.block_rounded : Icons.add_rounded,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                hasActive ? 'Solicitud en progreso' : 'Solicitar intercambio',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}