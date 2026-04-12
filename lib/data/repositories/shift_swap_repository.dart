import 'package:dio/dio.dart';
import 'package:dysch_mobile/data/models/employee_model.dart';
import 'package:dysch_mobile/data/models/schedule_model.dart';
import 'package:dysch_mobile/data/models/shift_swap_model.dart';

class ShiftSwapRepository {
    final Dio _dio;

    ShiftSwapRepository(this._dio);

    // GET: Buscar empleados de la empresa (el backend filtra por sucursal automáticamente).
    Future<EmployeesListModel> searchEmployees({String? search}) async {
    try {
        final queryParams = <String, dynamic>{
        if (search?.isNotEmpty ?? false) 'search': search,
        };

        final response = await _dio.get(
        '/organization/employees/',
        queryParameters: queryParams,
        );

        // Verdad: Validamos que la data sea lo que esperamos antes de mapear
        if (response.data is List) {
        return EmployeesListModel.fromJson(response.data as List);
        } else if (response.data is Map && response.data.containsKey('results')) {
        // Por si el backend decide paginar de repente (consistencia)
        return EmployeesListModel.fromJson(response.data['results'] as List);
        } else {
        throw Exception('Formato de respuesta inesperado');
        }

    } on DioException catch (e) {
        // Matiz: No confíes en que 'detail' siempre exista
        final errorMessage = e.response?.data is Map
            ? e.response?.data['detail'] ?? 'Error en el servidor'
            : 'Error de conexión';
        throw Exception(errorMessage);
    } catch (e) {
        throw Exception('Error inesperado: $e');
    }
    }

    // GET: Obtener horarios de un empleado específico.
    Future<List<ScheduleModel>> getEmployeeSchedules({
        required String employeeId,
        String? startDate,
        String? endDate,
    }) async {
        try {
        final queryParams = <String, dynamic>{
            'employee_id': employeeId,
            'is_published': true,
            'ordering': 'shift_date',
        };

        if (startDate != null) {
            queryParams['shift_date__gte'] = startDate;
        }
        if (endDate != null) {
            queryParams['shift_date__lte'] = endDate;
        }

        final response = await _dio.get(
            '/schedules/schedules/',
            queryParameters: queryParams,
        );

        final List<dynamic> data = response.data is Map
            ? (response.data['results'] as List? ?? [])
            : response.data as List;
        return data.map((json) => ScheduleModel.fromJson(json)).toList();
        } on DioException catch (e) {
        final errorMessage =
            e.response?.data['detail'] ?? 'Error al obtener horarios';
        throw Exception(errorMessage);
        }
    }

    // POST: Crear solicitud de intercambio de horarios.
    Future<ShiftSwapModel> createShiftSwap({
        required String targetEmployeeId,
        required String requestingEmployeeId,
        required String companyId,
        required List<String> requestingEmployeeSchedules,
        required List<String> targetEmployeeSchedules,
    }) async {
        try {
        final response = await _dio.post(
            '/schedules/swaps/',
            data: {
            'company_id': companyId,
            'requesting_employee_id': requestingEmployeeId,
            'target_employee_id': targetEmployeeId,
            'requesting_employee_schedules': requestingEmployeeSchedules,
            'target_employee_schedules': targetEmployeeSchedules,
            },
        );

        return ShiftSwapModel.fromJson(response.data);
        } on DioException catch (e) {
        final data = e.response?.data;
        String errorMessage = 'Error al crear solicitud de intercambio';
        if (data is Map) {
            errorMessage = data['detail']?.toString() ??
                data['error']?.toString() ??
                data['requesting_employee_schedules']?.toString() ??
                data['target_employee_schedules']?.toString() ??
                data['non_field_errors']?.toString() ??
                (data.values.isNotEmpty ? data.values.first?.toString() : null) ??
                errorMessage;
        }
        throw Exception(errorMessage);
        }
    }

    // GET: Obtener todas las solicitudes de intercambio.
    Future<ShiftSwapsListModel> getShiftSwaps({String? status}) async {
        try {
        final queryParams = <String, dynamic>{};
        if (status != null) {
            queryParams['status'] = status;
        }

        final response = await _dio.get(
            '/schedules/swaps/',
            queryParameters: queryParams,
        );

        return ShiftSwapsListModel.fromJson(response.data as Map<String, dynamic>);
        } on DioException catch (e) {
        final errorMessage = (e.response?.data is Map ? e.response?.data['detail'] : null) ??
            'Error al obtener solicitudes de intercambio';
        throw Exception(errorMessage);
        }
    }

    // GET: Obtener solicitudes pendientes.
    Future<ShiftSwapsListModel> getPendingSwaps() async {
        try {
        final response = await _dio.get('/schedules/swaps/pending/');

        return ShiftSwapsListModel.fromJson(response.data as Map<String, dynamic>);
        } on DioException catch (e) {
        final errorMessage = (e.response?.data is Map ? e.response?.data['detail'] : null) ??
            'Error al obtener solicitudes pendientes';
        throw Exception(errorMessage);
        }
    }

    // GET: Obtener detalles de una solicitud específica.
    Future<ShiftSwapModel> getShiftSwapById(String swapId) async {
        try {
        final response = await _dio.get('/schedules/swaps/$swapId/');

        return ShiftSwapModel.fromJson(response.data);
        } on DioException catch (e) {
        final errorMessage = e.response?.data['detail'] ??
            'Error al obtener detalles de la solicitud';
        throw Exception(errorMessage);
        }
    }

    // POST: Responder como compañero (aceptar/rechazar).
    Future<Map<String, dynamic>> respondAsPeer({
        required String swapId,
        required String action,
    }) async {
        try {
        final response = await _dio.post(
            '/schedules/swaps/$swapId/peer-response/',
            data: {'action': action},
        );

        return response.data;
        } on DioException catch (e) {
        final errorMessage = e.response?.data['error'] ??
            e.response?.data['detail'] ??
            'Error al responder a la solicitud';
        throw Exception(errorMessage);
        }
    }
}