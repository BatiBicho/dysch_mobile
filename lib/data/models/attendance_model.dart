import 'dart:convert';

class AttendanceQrPayload {
  final String token;
  final String? branchId;
  final String? companyId;

  AttendanceQrPayload({required this.token, this.branchId, this.companyId});

  factory AttendanceQrPayload.fromJson(Map<String, dynamic> json) {
    final token = (json['token'] ?? '').toString().trim();
    if (token.isEmpty) {
      throw const FormatException('El QR no contiene un token válido.');
    }
    return AttendanceQrPayload(
      token: token,
      branchId: json['branch_id']?.toString(),
      companyId: json['company_id']?.toString(),
    );
  }

  factory AttendanceQrPayload.fromRawValue(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Código QR vacío.');
    }

    if (trimmed.startsWith('{')) {
      final jsonData = jsonDecode(trimmed);
      if (jsonData is Map<String, dynamic>) {
        return AttendanceQrPayload.fromJson(jsonData);
      }
      throw const FormatException('Formato de QR no válido.');
    }

    return AttendanceQrPayload(token: trimmed);
  }
}

class AttendanceRecordModel {
  final String id;
  final String employeeId;
  final String employeeCode;
  final String employeeName;
  final String companyId;
  final String companyName;
  final String? scheduleId;
  final String? checkInClientTimestamp;
  final String? checkInServerTimestamp;
  final double? checkInLat;
  final double? checkInLong;
  final String? checkInMethod;
  final String? checkOutClientTimestamp;
  final String? checkOutServerTimestamp;
  final double? checkOutLat;
  final double? checkOutLong;
  final String? checkOutMethod;
  final bool isOfflineSync;
  final int minutesLate;
  final int minutesWorked;
  final double? distanceFromBranchMeters;
  final bool isWithinGeofence;
  final int? geofenceRadiusMeters;
  final List<dynamic>? anomalyFlags;
  final bool requiresReview;
  final bool isActive;

  AttendanceRecordModel({
    required this.id,
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.companyId,
    required this.companyName,
    this.scheduleId,
    this.checkInClientTimestamp,
    this.checkInServerTimestamp,
    this.checkInLat,
    this.checkInLong,
    this.checkInMethod,
    this.checkOutClientTimestamp,
    this.checkOutServerTimestamp,
    this.checkOutLat,
    this.checkOutLong,
    this.checkOutMethod,
    required this.isOfflineSync,
    required this.minutesLate,
    required this.minutesWorked,
    this.distanceFromBranchMeters,
    required this.isWithinGeofence,
    this.geofenceRadiusMeters,
    this.anomalyFlags,
    required this.requiresReview,
    required this.isActive,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    return AttendanceRecordModel(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      employeeCode: json['employee_code']?.toString() ?? '',
      employeeName: json['employee_name']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      scheduleId: json['schedule_id']?.toString(),
      checkInClientTimestamp: json['check_in_client_timestamp']?.toString(),
      checkInServerTimestamp: json['check_in_server_timestamp']?.toString(),
      checkInLat: parseDouble(json['check_in_lat']),
      checkInLong: parseDouble(json['check_in_long']),
      checkInMethod: json['check_in_method']?.toString(),
      checkOutClientTimestamp: json['check_out_client_timestamp']?.toString(),
      checkOutServerTimestamp: json['check_out_server_timestamp']?.toString(),
      checkOutLat: parseDouble(json['check_out_lat']),
      checkOutLong: parseDouble(json['check_out_long']),
      checkOutMethod: json['check_out_method']?.toString(),
      isOfflineSync: json['is_offline_sync'] == true,
      minutesLate: parseInt(json['minutes_late']),
      minutesWorked: parseInt(json['minutes_worked']),
      distanceFromBranchMeters: parseDouble(
        json['distance_from_branch_meters'],
      ),
      isWithinGeofence: json['is_within_geofence'] == true,
      geofenceRadiusMeters: json['geofence_radius_meters'] is int
          ? json['geofence_radius_meters'] as int
          : int.tryParse(json['geofence_radius_meters']?.toString() ?? ''),
      anomalyFlags: json['anomaly_flags'] is List<dynamic>
          ? List<dynamic>.from(json['anomaly_flags'] as List<dynamic>)
          : null,
      requiresReview: json['requires_review'] == true,
      isActive: json['is_active'] == true,
    );
  }
}

class AttendanceResponseModel {
  final String message;
  final AttendanceRecordModel record;
  final List<dynamic>? warnings;
  final int? minutesWorked;

  AttendanceResponseModel({
    required this.message,
    required this.record,
    this.warnings,
    this.minutesWorked,
  });

  factory AttendanceResponseModel.fromJson(Map<String, dynamic> json) {
    return AttendanceResponseModel(
      message: json['message']?.toString() ?? '',
      record: AttendanceRecordModel.fromJson(
        json['record'] as Map<String, dynamic>? ?? {},
      ),
      warnings: json['warnings'] is List<dynamic>
          ? List<dynamic>.from(json['warnings'] as List<dynamic>)
          : null,
      minutesWorked: json['minutes_worked'] is int
          ? json['minutes_worked'] as int
          : int.tryParse(json['minutes_worked']?.toString() ?? ''),
    );
  }
}
