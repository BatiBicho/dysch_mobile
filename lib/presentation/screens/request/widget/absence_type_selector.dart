import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AbsenceTypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String) onSelected;

  const AbsenceTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final types = [
      {
        'label': 'SICK_LEAVE',
        'display': 'Incapacidad',
        'icon': Icons.medical_services,
      },
      {
        'label': 'VACATION',
        'display': 'Vacaciones',
        'icon': Icons.beach_access,
      },
      {'label': 'PERMIT', 'display': 'Permiso', 'icon': Icons.person},
      {
        'label': 'WORK_ACCIDENT',
        'display': 'Accidente Laboral',
        'icon': Icons.warning,
      },
      {
        'label': 'UNEXCUSED',
        'display': 'Sin Justificación',
        'icon': Icons.cancel,
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: types.map((t) {
          bool isSelected = selectedType == t['label'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(t['display'] as String),
              avatar: Icon(
                t['icon'] as IconData,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(t['label'] as String),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
