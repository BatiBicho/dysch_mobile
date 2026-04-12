import 'package:dysch_mobile/data/models/employee_model.dart';
import 'package:dysch_mobile/data/models/schedule_model.dart';
import 'package:dysch_mobile/data/models/shift_swap_model.dart' show ShiftSwapModel;
import 'package:dysch_mobile/data/repositories/shift_swap_repository.dart' show ShiftSwapRepository;
import 'package:flutter_bloc/flutter_bloc.dart';


abstract class ShiftSwapState {}

class ShiftSwapInitial extends ShiftSwapState {}

class ShiftSwapLoading extends ShiftSwapState {}

// Estados para búsqueda de empleados:
class EmployeesLoaded extends ShiftSwapState {
    final List<EmployeeModel> employees;
    EmployeesLoaded(this.employees);
}

// Estados para horarios de empleados:
class EmployeeSchedulesLoaded extends ShiftSwapState {
    final List<ScheduleModel> schedules;
    final String employeeId;
    EmployeeSchedulesLoaded(this.schedules, this.employeeId);
}

// Estados para solicitudes de intercambio:
class ShiftSwapsLoaded extends ShiftSwapState {
    final List<ShiftSwapModel> swaps;
    ShiftSwapsLoaded(this.swaps);
}

class ShiftSwapCreated extends ShiftSwapState {
    final ShiftSwapModel swap;
    ShiftSwapCreated(this.swap);
}

class ShiftSwapDetailLoaded extends ShiftSwapState {
    final ShiftSwapModel swap;
    ShiftSwapDetailLoaded(this.swap);
}

class ShiftSwapResponseSuccess extends ShiftSwapState {
    final String message;
    final String status;
    ShiftSwapResponseSuccess(this.message, this.status);
}

class ShiftSwapError extends ShiftSwapState {
    final String message;
    ShiftSwapError(this.message);
}


class ShiftSwapCubit extends Cubit<ShiftSwapState> {
    final ShiftSwapRepository repository;

    ShiftSwapCubit(this.repository) : super(ShiftSwapInitial());

    // Buscar empleados de la empresa (el backend filtra por sucursal):
    Future<void> searchEmployees({String? search}) async {
        try {
        emit(ShiftSwapLoading());
        final data = await repository.searchEmployees(search: search);
        emit(EmployeesLoaded(data.employees));
        } catch (e) {
        emit(ShiftSwapError(e.toString().replaceAll('Exception: ', '')));
        }
    }

    // Obtener horarios de un empleado específico:
    Future<void> getEmployeeSchedules({
        required String employeeId,
        String? startDate,
        String? endDate,
    }) async {
        try {
        emit(ShiftSwapLoading());
        final data = await repository.getEmployeeSchedules(
            employeeId: employeeId,
            startDate: startDate,
            endDate: endDate,
        );
        emit(EmployeeSchedulesLoaded(data, employeeId));
        } catch (e) {
        emit(ShiftSwapError(e.toString().replaceAll('Exception: ', '')));
        }
    }

    // Crear solicitud de intercambio de horarios:
    Future<void> createShiftSwap({
        required String targetEmployeeId,
        required String requestingEmployeeId,
        required String companyId,
        required List<String> requestingEmployeeSchedules,
        required List<String> targetEmployeeSchedules,
    }) async {
        try {
        emit(ShiftSwapLoading());
        final swap = await repository.createShiftSwap(
            targetEmployeeId: targetEmployeeId,
            requestingEmployeeId: requestingEmployeeId,
            companyId: companyId,
            requestingEmployeeSchedules: requestingEmployeeSchedules,
            targetEmployeeSchedules: targetEmployeeSchedules,
        );
        emit(ShiftSwapCreated(swap));
        } catch (e) {
        emit(ShiftSwapError(e.toString().replaceAll('Exception: ', '')));
        }
    }

    // Obtener todas las solicitudes de intercambio:
    Future<void> getShiftSwaps({String? status}) async {
        if (state is ShiftSwapLoading) return;

        try {
        emit(ShiftSwapLoading());
        final data = await repository.getShiftSwaps(status: status);
        emit(ShiftSwapsLoaded(data.swaps));
        } catch (e) {
        emit(ShiftSwapError(e.toString().replaceAll('Exception: ', '')));
        }
    }

    // Obtener solicitudes pendientes:
    Future<void> getPendingSwaps() async {
        if (state is ShiftSwapLoading) return;

        try {
        emit(ShiftSwapLoading());
        final data = await repository.getPendingSwaps();
        emit(ShiftSwapsLoaded(data.swaps));
        } catch (e) {
        emit(ShiftSwapError(e.toString().replaceAll('Exception: ', '')));
        }
    }

    // Obtener detalles de una petición:
    Future<void> getShiftSwapById(String swapId) async {
        try {
        emit(ShiftSwapLoading());
        final swap = await repository.getShiftSwapById(swapId);
        emit(ShiftSwapDetailLoaded(swap));
        } catch (e) {
        emit(ShiftSwapError(e.toString().replaceAll('Exception: ', '')));
        }
    }

    // Responder a una petición:
    Future<void> respondAsPeer({
        required String swapId,
        required String action,
    }) async {
        try {
        emit(ShiftSwapLoading());
        final response = await repository.respondAsPeer(
            swapId: swapId,
            action: action,
        );
        emit(ShiftSwapResponseSuccess(
            response['message'] ?? 'Respuesta enviada',
            response['status'] ?? '',
        ));
        } catch (e) {
        emit(ShiftSwapError(e.toString().replaceAll('Exception: ', '')));
        }
    }

    void reset() {
        emit(ShiftSwapInitial());
    }
}