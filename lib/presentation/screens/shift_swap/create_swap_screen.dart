import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/data/models/employee_model.dart';
import 'package:dysch_mobile/data/models/schedule_model.dart';
import 'package:dysch_mobile/data/repositories/shift_swap_repository.dart';
import 'package:dysch_mobile/logic/auth/auth_cubit.dart';
import 'package:dysch_mobile/logic/shift_swap/shift_swap_cubit.dart';
import 'package:dysch_mobile/presentation/screens/shift_swap/widgets/employee_search_card.dart';
import 'package:dysch_mobile/presentation/screens/shift_swap/widgets/schedule_selection_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateSwapScreen extends StatefulWidget {
  const CreateSwapScreen({super.key});

  @override
  State<CreateSwapScreen> createState() => _CreateSwapScreenState();
}

class _CreateSwapScreenState extends State<CreateSwapScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  int _currentStep = 0;

  EmployeeModel? _selectedEmployee;
  List<ScheduleModel> _mySchedules = [];
  List<ScheduleModel> _peerSchedules = [];
  Set<String> _selectedMySchedules = {};
  Set<String> _selectedPeerSchedules = {};

  bool _isLoadingMySchedules = false;
  bool _isLoadingPeerSchedules = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _fadeAnimation = CurvedAnimation(parent: _slideController, curve: Curves.easeOut);
    _slideController.forward();
    _loadMySchedules();
  }

  Future<void> _loadMySchedules() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) return;
    setState(() => _isLoadingMySchedules = true);
    try {
      final now = DateTime.now();
      final schedules = await context.read<ShiftSwapRepository>().getEmployeeSchedules(
            employeeId: authState.user.employeeId,
            startDate: now.toIso8601String().split('T')[0],
          );
      if (mounted) setState(() => _mySchedules = schedules);
    } catch (e) {
      if (mounted) {
        _showError('Error al cargar tus horarios: ${e.toString().replaceAll('Exception: ', '')}');
      }
    } finally {
      if (mounted) setState(() => _isLoadingMySchedules = false);
    }
  }

  Future<void> _loadPeerSchedules(String employeeId) async {
    setState(() {
      _isLoadingPeerSchedules = true;
      _peerSchedules = [];
      _selectedPeerSchedules.clear();
    });
    try {
      final now = DateTime.now();
      final schedules = await context.read<ShiftSwapRepository>().getEmployeeSchedules(
            employeeId: employeeId,
            startDate: now.toIso8601String().split('T')[0],
          );
      if (mounted) setState(() => _peerSchedules = schedules);
    } catch (e) {
      if (mounted) {
        _showError('Error al cargar horarios del compañero: ${e.toString().replaceAll('Exception: ', '')}');
      }
    } finally {
      if (mounted) setState(() => _isLoadingPeerSchedules = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _searchEmployees(String query) {
    if (query.length >= 2) {
      context.read<ShiftSwapCubit>().searchEmployees(search: query);
    }
  }

  void _selectEmployee(EmployeeModel employee) {
    setState(() => _selectedEmployee = employee);
    _loadPeerSchedules(employee.id);
    _searchController.clear();
  }

  void _goToStep(int step) {
    _slideController.reset();
    setState(() => _currentStep = step);
    _slideController.forward();
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedEmployee == null) {
      _showError('Selecciona un compañero para continuar');
      return;
    }
    if (_currentStep == 1 && _selectedPeerSchedules.isEmpty) {
      _showError('Selecciona al menos un turno del compañero');
      return;
    }
    if (_currentStep == 2 && _selectedMySchedules.isEmpty) {
      _showError('Selecciona al menos uno de tus turnos');
      return;
    }
    if (_currentStep < 3) _goToStep(_currentStep + 1);
  }

  void _createSwapRequest() {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) return;
    context.read<ShiftSwapCubit>().createShiftSwap(
          targetEmployeeId: _selectedEmployee!.id,
          requestingEmployeeId: authState.user.employeeId,
          companyId: authState.user.companyId,
          requestingEmployeeSchedules: _selectedMySchedules.toList(),
          targetEmployeeSchedules: _selectedPeerSchedules.toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: BlocConsumer<ShiftSwapCubit, ShiftSwapState>(
        listener: (context, state) {
          if (state is ShiftSwapCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Solicitud enviada exitosamente'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            Navigator.pop(context);
          }
          if (state is ShiftSwapError) {
            _showError(state.message);
          }
        },
        builder: (context, state) {
          final isCreating = state is ShiftSwapLoading && _currentStep == 3;
          return Column(
            children: [
              _buildHeader(),
              _buildStepIndicator(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildCurrentStep(state),
                  ),
                ),
              ),
              _buildBottomBar(isCreating),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final titles = [
      'Buscar compañero',
      'Turnos del compañero',
      'Mis turnos',
      'Resumen',
    ];
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 22),
              color: const Color(0xFF1A1A1A),
              onPressed: _currentStep > 0 ? () => _goToStep(_currentStep - 1) : () => Navigator.pop(context),
            ),
            Expanded(
              child: Text(
                titles[_currentStep],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.4,
                ),
              ),
            ),
            Text(
              '${_currentStep + 1} / 4',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9E9E9E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: List.generate(4, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 3 ? 6 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 3,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.primary
                      : isActive
                          ? AppColors.primary
                          : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep(ShiftSwapState state) {
    switch (_currentStep) {
      case 0:
        return _buildSearchStep(state);
      case 1:
        return _buildPeerScheduleStep();
      case 2:
        return _buildMyScheduleStep();
      case 3:
        return _buildSummaryStep();
      default:
        return const SizedBox();
    }
  }


  Widget _buildSearchStep(ShiftSwapState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedEmployee != null) ...[
            _buildSelectedEmployeeTile(),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),
            const Text(
              'Cambiar selección',
              style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
          ] else ...[
            const Text(
              'Encuentra al compañero con quien quieres intercambiar tu turno.',
              style: TextStyle(fontSize: 14, color: Color(0xFF757575), height: 1.5),
            ),
            const SizedBox(height: 20),
          ],
          _buildSearchField(),
          const SizedBox(height: 12),
          if (state is EmployeesLoaded) _buildEmployeeResults(state.employees),
        ],
      ),
    );
  }

  Widget _buildSelectedEmployeeTile() {
    final employee = _selectedEmployee!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          _buildAvatar(employee.firstName, selected: true, size: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.fullName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 2),
                Text('ID: ${employee.employeeCode}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                if (employee.departmentName != null)
                  Text(employee.departmentName!,
                      style: const TextStyle(fontSize: 11, color: Color(0xFFBBBBBB))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: AppColors.primary, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          hintText: 'Nombre o código de empleado…',
          hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onChanged: _searchEmployees,
      ),
    );
  }

  Widget _buildEmployeeResults(List<EmployeeModel> employees) {
    final authState = context.read<AuthCubit>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : null;
    final filtered = currentUserId != null
        ? employees.where((e) => e.userId != currentUserId).toList()
        : employees;

    if (filtered.isEmpty) {
      return _buildEmptyState('Sin resultados', 'Intenta con otro nombre o código');
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 340),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF0F0F0)),
          itemBuilder: (context, index) {
            final employee = filtered[index];
            final isSelected = _selectedEmployee?.id == employee.id;
            return InkWell(
              onTap: () => _selectEmployee(employee),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildAvatar(employee.firstName, selected: isSelected, size: 42),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(employee.fullName,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                          Text('ID: ${employee.employeeCode}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded,
                      color: isSelected ? AppColors.primary : const Color(0xFFCCCCCC),
                      size: isSelected ? 20 : 14,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildPeerScheduleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepSubtitle(
            '¿Qué turno de ${_selectedEmployee?.firstName ?? 'tu compañero'} quieres tomar?',
          ),
          const SizedBox(height: 20),
          _isLoadingPeerSchedules
              ? _buildLoadingBox()
              : ScheduleSelectionSection(
                  schedules: _peerSchedules,
                  selectedSchedules: _selectedPeerSchedules,
                  onScheduleToggle: (id) {
                    setState(() {
                      if (_selectedPeerSchedules.contains(id)) {
                        _selectedPeerSchedules.remove(id);
                      } else {
                        _selectedPeerSchedules.add(id);
                      }
                    });
                  },
                  emptyMessage: '${_selectedEmployee?.firstName ?? 'El compañero'} no tiene turnos asignados',
                ),
        ],
      ),
    );
  }


  Widget _buildMyScheduleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepSubtitle('¿Qué turno tuyo estás dispuesto a intercambiar?'),
          const SizedBox(height: 20),
          _isLoadingMySchedules
              ? _buildLoadingBox()
              : ScheduleSelectionSection(
                  schedules: _mySchedules,
                  selectedSchedules: _selectedMySchedules,
                  onScheduleToggle: (id) {
                    setState(() {
                      if (_selectedMySchedules.contains(id)) {
                        _selectedMySchedules.remove(id);
                      } else {
                        _selectedMySchedules.add(id);
                      }
                    });
                  },
                  emptyMessage: 'No tienes turnos asignados',
                ),
        ],
      ),
    );
  }


  Widget _buildSummaryStep() {
    final employee = _selectedEmployee!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepSubtitle('Revisa los detalles antes de enviar la solicitud.'),
          const SizedBox(height: 24),

          _buildSummarySection(
            label: 'Intercambio entre',
            child: Row(
              children: [
                Expanded(child: _buildParticipantChip('Tú', isMe: true)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 22),
                ),
                Expanded(child: _buildParticipantChip(employee.firstName, isMe: false)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildSummarySection(
            label: 'Tus turnos a ceder',
            child: _buildSummarySchedules(_selectedMySchedules, _mySchedules, AppColors.primary),
          ),
          const SizedBox(height: 16),

          _buildSummarySection(
            label: 'Turnos de ${employee.firstName} que tomarás',
            child: _buildSummarySchedules(_selectedPeerSchedules, _peerSchedules, AppColors.info),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildParticipantChip(String name, {required bool isMe}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary.withValues(alpha: 0.07) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isMe ? AppColors.primary : const Color(0xFF555555),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildSummarySection({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9E9E9E), letterSpacing: 0.4)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildSummarySchedules(Set<String> selectedIds, List<ScheduleModel> allSchedules, Color color) {
    final schedules = allSchedules.where((s) => selectedIds.contains(s.id)).toList();
    return Column(
      children: schedules.map((s) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: color, width: 3)),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_formatDate(s.shiftDate),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                    Text('${_formatTime(s.startTime)} – ${_formatTime(s.endTime)}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar(bool isCreating) {
    final isLast = _currentStep == 3;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isCreating ? null : (isLast ? _createSwapRequest : _nextStep),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: isCreating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLast ? 'Enviar solicitud' : 'Continuar',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      if (!isLast) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }


  Widget _buildAvatar(String firstName, {required bool selected, double size = 46}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          firstName.isNotEmpty ? firstName[0].toUpperCase() : 'E',
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildStepSubtitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, color: Color(0xFF757575), height: 1.5),
    );
  }

  Widget _buildLoadingBox() {
    return Container(
      height: 120,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 40, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
    } catch (_) {
      return dateString;
    }
  }

  String _formatTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
      return timeString;
    } catch (_) {
      return timeString;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}