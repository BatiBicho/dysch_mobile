class PrenominaResponse {
  final String? employeeId;
  final String? departmentId;
  final String? departmentName;
  final bool? isConfirmed;
  final String? periodStart;
  final String? periodEnd;
  final int? daysWorked;
  final int? daysAbsent;
  final double? totalRegularHours;
  final double? totalOvertimeHours;
  final double? grossPay;
  final double? bonusAmount;
  final double? imssDeduction;
  final double? isrDeduction;
  final double? netPay;
  final bool? hasManualAdjustments;
  final List<DailyBreakdown>? dailyBreakdown;
  final String? detail; // Para errores

  PrenominaResponse({
    this.employeeId,
    this.departmentId,
    this.departmentName,
    this.isConfirmed,
    this.periodStart,
    this.periodEnd,
    this.daysWorked,
    this.daysAbsent,
    this.totalRegularHours,
    this.totalOvertimeHours,
    this.grossPay,
    this.bonusAmount,
    this.imssDeduction,
    this.isrDeduction,
    this.netPay,
    this.hasManualAdjustments,
    this.dailyBreakdown,
    this.detail,
  });

  factory PrenominaResponse.fromJson(Map<String, dynamic> json) {
    return PrenominaResponse(
      employeeId: json['employee_id'],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
      isConfirmed: json['is_confirmed'],
      periodStart: json['period_start'],
      periodEnd: json['period_end'],
      daysWorked: json['days_worked'],
      daysAbsent: json['days_absent'],
      totalRegularHours: (json['total_regular_hours'] as num?)?.toDouble(),
      totalOvertimeHours: (json['total_overtime_hours'] as num?)?.toDouble(),
      grossPay: (json['gross_pay'] as num?)?.toDouble(),
      bonusAmount: (json['bonus_amount'] as num?)?.toDouble(),
      imssDeduction: (json['imss_deduction'] as num?)?.toDouble(),
      isrDeduction: (json['isr_deduction'] as num?)?.toDouble(),
      netPay: (json['net_pay'] as num?)?.toDouble(),
      hasManualAdjustments: json['has_manual_adjustments'],
      dailyBreakdown: json['daily_breakdown'] != null
          ? List<DailyBreakdown>.from(
              (json['daily_breakdown'] as List).map(
                (x) => DailyBreakdown.fromJson(x),
              ),
            )
          : null,
      detail: json['detail'],
    );
  }

  bool get isValid => employeeId != null && periodStart != null;
  bool get hasError => detail != null;
}

class DailyBreakdown {
  final String date;
  final String type; // 'worked', 'absent', 'rest'
  final double? basePay;
  final double? overtimePay;
  final double? sundayPremium;
  final double? holidayPremium;
  final double? totalGross;
  final double? regularHours;
  final double? overtimeHours;

  DailyBreakdown({
    required this.date,
    required this.type,
    this.basePay,
    this.overtimePay,
    this.sundayPremium,
    this.holidayPremium,
    this.totalGross,
    this.regularHours,
    this.overtimeHours,
  });

  factory DailyBreakdown.fromJson(Map<String, dynamic> json) {
    return DailyBreakdown(
      date: json['date'],
      type: json['type'],
      basePay: (json['base_pay'] as num?)?.toDouble(),
      overtimePay: (json['overtime_pay'] as num?)?.toDouble(),
      sundayPremium: (json['sunday_premium'] as num?)?.toDouble(),
      holidayPremium: (json['holiday_premium'] as num?)?.toDouble(),
      totalGross: (json['total_gross'] as num?)?.toDouble(),
      regularHours: (json['regular_hours'] as num?)?.toDouble(),
      overtimeHours: (json['overtime_hours'] as num?)?.toDouble(),
    );
  }
}
