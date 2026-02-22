import 'package:flutter/material.dart';
import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/presentation/screens/request/widget/absence_type_selector.dart';
import 'package:intl/intl.dart';

/// Widget que contiene el formulario de incidente
class IncidentFormSection extends StatelessWidget {
  final String selectedType;
  final bool isFullDay;
  final DateTime startDate;
  final DateTime endDate;
  final TextEditingController justificationController;
  final TextEditingController extraFieldsController;
  final Function(String) onTypeChanged;
  final Function(bool) onFullDayChanged;
  final Function(DateTime) onStartDateChanged;
  final Function(DateTime) onEndDateChanged;

  const IncidentFormSection({
    required this.selectedType,
    required this.isFullDay,
    required this.startDate,
    required this.endDate,
    required this.justificationController,
    required this.extraFieldsController,
    required this.onTypeChanged,
    required this.onFullDayChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('TIPO DE INCIDENCIA'),
        AbsenceTypeSelector(
          selectedType: selectedType,
          onSelected: onTypeChanged,
        ),
        const SizedBox(height: 32),
        _buildDurationSection(context),
        const SizedBox(height: 32),
        _buildSectionTitle('DESCRIPCIÓN/JUSTIFICACIÓN'),
        _buildTextField(
          justificationController,
          'Describe la razón...',
          4,
          300,
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('CAMPO ADICIONAL'),
        _buildTextField(extraFieldsController, 'Ej: "Graduación"', 2, 100),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    int lines,
    int max,
  ) {
    return TextField(
      controller: controller,
      maxLines: lines,
      maxLength: max,
      decoration: InputDecoration(
        hintText: hint,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDurationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('DURACIÓN'),
            Row(
              children: [
                const Text('Todo el día', style: TextStyle(fontSize: 12)),
                Switch(
                  value: isFullDay,
                  onChanged: onFullDayChanged,
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
        _buildDateSelectorsRow(context),
      ],
    );
  }

  Widget _buildDateSelectorsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDateInput(
            context,
            'Desde',
            startDate,
            onStartDateChanged,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateInput(context, 'Hasta', endDate, onEndDateChanged),
        ),
      ],
    );
  }

  Widget _buildDateInput(
    BuildContext context,
    String label,
    DateTime selectedDate,
    Function(DateTime) onDateChanged,
  ) {
    final formattedDate = DateFormat('dd MMM, yyyy').format(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              onDateChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Icon(
                  Icons.calendar_month,
                  size: 18,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
