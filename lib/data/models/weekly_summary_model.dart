class WeeklySummaryModel {
  final Week week;
  final Scheduled scheduled;
  final Completed completed;
  final Summary summary;
  final HoursBreakdown? hoursBreakdown;

  WeeklySummaryModel({
    required this.week,
    required this.scheduled,
    required this.completed,
    required this.summary,
    this.hoursBreakdown,
  });

  factory WeeklySummaryModel.fromJson(Map<String, dynamic> json) {
    return WeeklySummaryModel(
      week: Week.fromJson(json['week'] as Map<String, dynamic>),
      scheduled: Scheduled.fromJson(json['scheduled'] as Map<String, dynamic>),
      completed: Completed.fromJson(json['completed'] as Map<String, dynamic>),
      summary: Summary.fromJson(json['summary'] as Map<String, dynamic>),
      hoursBreakdown: json['hours_breakdown'] != null
          ? HoursBreakdown.fromJson(
              json['hours_breakdown'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'week': week.toJson(),
    'scheduled': scheduled.toJson(),
    'completed': completed.toJson(),
    'summary': summary.toJson(),
    if (hoursBreakdown != null) 'hours_breakdown': hoursBreakdown!.toJson(),
  };
}

class Week {
  final String startDate;
  final String endDate;

  Week({required this.startDate, required this.endDate});

  factory Week.fromJson(Map<String, dynamic> json) {
    return Week(
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'start_date': startDate,
    'end_date': endDate,
  };
}

class Scheduled {
  final int totalDays;
  final Hours hours;

  Scheduled({required this.totalDays, required this.hours});

  factory Scheduled.fromJson(Map<String, dynamic> json) {
    return Scheduled(
      totalDays: json['total_days'] as int,
      hours: Hours.fromJson(json['hours'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_days': totalDays,
    'hours': hours.toJson(),
  };
}

class Completed {
  final int totalDays;
  final Hours hours;

  Completed({required this.totalDays, required this.hours});

  factory Completed.fromJson(Map<String, dynamic> json) {
    return Completed(
      totalDays: json['total_days'] as int,
      hours: Hours.fromJson(json['hours'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_days': totalDays,
    'hours': hours.toJson(),
  };
}

class Hours {
  final int totalMinutes;
  final int hours;
  final int minutes;
  final String formatted;

  Hours({
    required this.totalMinutes,
    required this.hours,
    required this.minutes,
    required this.formatted,
  });

  factory Hours.fromJson(Map<String, dynamic> json) {
    return Hours(
      totalMinutes: json['total_minutes'] as int,
      hours: json['hours'] as int,
      minutes: json['minutes'] as int,
      formatted: json['formatted'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_minutes': totalMinutes,
    'hours': hours,
    'minutes': minutes,
    'formatted': formatted,
  };
}

class HoursBreakdown {
  final Hours ordinary;
  final Hours extras;
  final Hours sobreExtras;
  final Hours total;

  HoursBreakdown({
    required this.ordinary,
    required this.extras,
    required this.sobreExtras,
    required this.total,
  });

  factory HoursBreakdown.fromJson(Map<String, dynamic> json) {
    return HoursBreakdown(
      ordinary: Hours.fromJson(json['ordinary'] as Map<String, dynamic>),
      extras: Hours.fromJson(json['extras'] as Map<String, dynamic>),
      sobreExtras: Hours.fromJson(json['sobre_extras'] as Map<String, dynamic>),
      total: Hours.fromJson(json['total'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'ordinary': ordinary.toJson(),
    'extras': extras.toJson(),
    'sobre_extras': sobreExtras.toJson(),
    'total': total.toJson(),
  };
}

class Summary {
  final String daysProgress;
  final double completionPercentage;
  final int hoursDifference;

  Summary({
    required this.daysProgress,
    required this.completionPercentage,
    required this.hoursDifference,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      daysProgress: json['days_progress'] as String,
      completionPercentage: (json['completion_percentage'] as num).toDouble(),
      hoursDifference: json['hours_difference'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'days_progress': daysProgress,
    'completion_percentage': completionPercentage,
    'hours_difference': hoursDifference,
  };
}
