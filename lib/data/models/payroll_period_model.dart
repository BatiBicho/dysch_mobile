class PayrollPeriodResponse {
  final String employeeCode;
  final String employeeName;
  final List<PayrollPeriod> periods;
  final int count;

  PayrollPeriodResponse({
    required this.employeeCode,
    required this.employeeName,
    required this.periods,
    required this.count,
  });

  factory PayrollPeriodResponse.fromJson(Map<String, dynamic> json) {
    return PayrollPeriodResponse(
      employeeCode: json['employee_code'] as String? ?? '',
      employeeName: json['employee_name'] as String? ?? '',
      periods:
          (json['periods'] as List<dynamic>?)
              ?.map((p) => PayrollPeriod.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      count: json['count'] as int? ?? 0,
    );
  }
}

class PayrollPeriod {
  final DateTime periodStart;
  final DateTime periodEnd;

  PayrollPeriod({required this.periodStart, required this.periodEnd});

  String get label {
    final start = _formatDate(periodStart);
    final end = _formatDate(periodEnd);
    return '$start - $end';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  factory PayrollPeriod.fromJson(Map<String, dynamic> json) {
    final startStr = json['period_start'] as String?;
    final endStr = json['period_end'] as String?;

    return PayrollPeriod(
      periodStart: startStr != null ? DateTime.parse(startStr) : DateTime.now(),
      periodEnd: endStr != null ? DateTime.parse(endStr) : DateTime.now(),
    );
  }
}
