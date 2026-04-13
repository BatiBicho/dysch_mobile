import 'package:flutter/material.dart';
import 'package:dysch_mobile/core/theme/app_colors.dart';

class PeriodSelector extends StatefulWidget {
  final Function(DateTime, DateTime) onPeriodSelected;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const PeriodSelector({
    super.key,
    required this.onPeriodSelected,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<PeriodSelector> createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<PeriodSelector> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    // Por defecto, muestra la semana actual
    final now = DateTime.now();
    _startDate = widget.initialStartDate ?? _getMonday(now);
    _endDate = widget.initialEndDate ?? _getSunday(now);
  }

  DateTime _getMonday(DateTime date) {
    final differenceFromMonday = date.weekday - 1;
    return date.subtract(Duration(days: differenceFromMonday));
  }

  DateTime _getSunday(DateTime date) {
    final differenceFromSunday = 7 - date.weekday;
    return date.add(Duration(days: differenceFromSunday));
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      confirmText: 'Seleccionar',
      cancelText: 'Cancelar',
      fieldStartHintText: 'Fecha inicio',
      fieldEndHintText: 'Fecha fin',
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      widget.onPeriodSelected(_startDate, _endDate);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectDateRange,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Período',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.calendar_today, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
