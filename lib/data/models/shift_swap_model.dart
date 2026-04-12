import 'package:dysch_mobile/data/models/schedule_model.dart';

class ShiftSwapModel {
    final String id;
    final String companyId;
    final String companyName;
    final String requestingEmployeeId;
    final String requestingEmployeeCode;
    final String requestingEmployeeName;
    final String targetEmployeeId;
    final String targetEmployeeCode;
    final String targetEmployeeName;
    final List<String> requestingEmployeeSchedules;
    final List<String> targetEmployeeSchedules;
    final List<ScheduleModel> requestingSchedulesDetail;
    final List<ScheduleModel> targetSchedulesDetail;
    final String status;
    final String requestedAt;
    final String? peerRespondedAt;
    final String? supervisorRespondedAt;
    final String? supervisorUserId;
    final bool isActive;

    ShiftSwapModel({
        required this.id,
        required this.companyId,
        required this.companyName,
        required this.requestingEmployeeId,
        required this.requestingEmployeeCode,
        required this.requestingEmployeeName,
        required this.targetEmployeeId,
        required this.targetEmployeeCode,
        required this.targetEmployeeName,
        required this.requestingEmployeeSchedules,
        required this.targetEmployeeSchedules,
        required this.requestingSchedulesDetail,
        required this.targetSchedulesDetail,
        required this.status,
        required this.requestedAt,
        this.peerRespondedAt,
        this.supervisorRespondedAt,
        this.supervisorUserId,
        required this.isActive,
    });

    String get displayStatus {
        switch (status) {
        case 'PENDING_PEER':
            return 'Enviado';
        case 'PENDING_SUPERVISOR':
            return 'Pendiente';
        case 'APPROVED':
            return 'Aprobado';
        case 'REJECTED':
            return 'Rechazado';
        default:
            return status;
        }
    }

    // Verifica si el usuario actual es el solicitante (por código):
    bool isRequester(String currentEmployeeCode) {
        return requestingEmployeeCode == currentEmployeeCode;
    }

    // Verifica si el usuario actual es el objetivo (por código):
    bool isTarget(String currentEmployeeCode) {
        return targetEmployeeCode == currentEmployeeCode;
    }

    // Verifica si el usuario puede responder como compañero:
    bool canRespondAsPeer(String currentEmployeeCode) {
        return isTarget(currentEmployeeCode) && status == 'PENDING_PEER';
    }

    factory ShiftSwapModel.fromJson(Map<String, dynamic> json) {
        return ShiftSwapModel(
        id: json['id'] ?? '',
        companyId: json['company_id'] ?? '',
        companyName: json['company_name'] ?? '',
        requestingEmployeeId: json['requesting_employee_id'] ?? '',
        requestingEmployeeCode: json['requesting_employee_code'] ?? '',
        requestingEmployeeName: json['requesting_employee_name'] ?? '',
        targetEmployeeId: json['target_employee_id'] ?? '',
        targetEmployeeCode: json['target_employee_code'] ?? '',
        targetEmployeeName: json['target_employee_name'] ?? '',
        requestingEmployeeSchedules:
            List<String>.from(json['requesting_employee_schedules'] ?? []),
        targetEmployeeSchedules:
            List<String>.from(json['target_employee_schedules'] ?? []),
        requestingSchedulesDetail: (json['requesting_schedules_detail'] as List?)
                ?.map((e) => ScheduleModel.fromJson(e))
                .toList() ??
            [],
        targetSchedulesDetail: (json['target_schedules_detail'] as List?)
                ?.map((e) => ScheduleModel.fromJson(e))
                .toList() ??
            [],
        status: json['status'] ?? 'PENDING_PEER',
        requestedAt: json['requested_at'] ?? '',
        peerRespondedAt: json['peer_responded_at'],
        supervisorRespondedAt: json['supervisor_responded_at'],
        supervisorUserId: json['supervisor_user_id'],
        isActive: json['is_active'] ?? true,
        );
    }

    Map<String, dynamic> toJson() => {
        'requesting_employee_schedules': requestingEmployeeSchedules,
        'target_employee_schedules': targetEmployeeSchedules,
        'target_employee_id': targetEmployeeId,
    };
}

// Listado de intercambios de horarios (respuesta paginada):
class ShiftSwapsListModel {
    final List<ShiftSwapModel> swaps;
    final int count;
    final String? next;
    final String? previous;

    ShiftSwapsListModel({
        required this.swaps,
        this.count = 0,
        this.next,
        this.previous,
    });

    factory ShiftSwapsListModel.fromJson(Map<String, dynamic> json) {
        return ShiftSwapsListModel(
            count: json['count'] ?? 0,
            next: json['next'],
            previous: json['previous'],
            swaps: (json['results'] as List? ?? [])
                .map((e) => ShiftSwapModel.fromJson(e))
                .toList(),
        );
    }
}