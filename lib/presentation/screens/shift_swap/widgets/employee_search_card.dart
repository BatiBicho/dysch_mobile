import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/data/models/employee_model.dart';
import 'package:flutter/material.dart';

class EmployeeSearchCard extends StatelessWidget {
  final EmployeeModel employee;
  final bool isSelected;
  final VoidCallback onTap;

  const EmployeeSearchCard({
    super.key,
    required this.employee,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.04) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  employee.firstName.isNotEmpty ? employee.firstName[0].toUpperCase() : 'E',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.fullName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${employee.employeeCode}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                  ),
                  if (employee.departmentName != null)
                    Text(
                      employee.departmentName!,
                      style: const TextStyle(fontSize: 11, color: Color(0xFFBBBBBB)),
                    ),
                ],
              ),
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20, key: const ValueKey('check'))
                  : Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[300], size: 14, key: const ValueKey('arrow')),
            ),
          ],
        ),
      ),
    );
  }
}