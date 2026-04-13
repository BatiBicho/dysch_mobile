import 'package:flutter/material.dart';
import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/data/models/payroll_period_model.dart';

class PeriodDropdownSelector extends StatelessWidget {
  final List<PayrollPeriod> periods;
  final PayrollPeriod? selectedPeriod;
  final Function(PayrollPeriod) onPeriodSelected;
  final bool isLoading;

  const PeriodDropdownSelector({
    super.key,
    required this.periods,
    required this.selectedPeriod,
    required this.onPeriodSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const SizedBox(
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (periods.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade300),
        ),
        child: const Text(
          'No hay períodos disponibles',
          style: TextStyle(color: Colors.orange, fontSize: 14),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<PayrollPeriod>(
        value: selectedPeriod,
        isExpanded: true,
        underline: const SizedBox(),
        hint: const Text(
          'Selecciona un período',
          style: TextStyle(color: Colors.grey),
        ),
        items: periods
            .map(
              (period) => DropdownMenuItem(
                value: period,
                child: Text(period.label, style: const TextStyle(fontSize: 14)),
              ),
            )
            .toList(),
        onChanged: (PayrollPeriod? newValue) {
          if (newValue != null) {
            onPeriodSelected(newValue);
          }
        },
      ),
    );
  }
}
