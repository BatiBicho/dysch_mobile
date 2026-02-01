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
      {'label': 'Permiso personal', 'icon': Icons.person},
      {'label': 'Cita médica', 'icon': Icons.medical_services},
      {'label': 'Viaje', 'icon': Icons.flight},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: types.map((t) {
          bool isSelected = selectedType == t['label'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(t['label'] as String),
              avatar: Icon(
                t['icon'] as IconData,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(t['label'] as String),
              selectedColor: const Color(0xFFFF7043),
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
