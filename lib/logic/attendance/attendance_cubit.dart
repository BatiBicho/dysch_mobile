import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dysch_mobile/data/models/attendance_model.dart';
import 'package:dysch_mobile/data/repositories/attendance_repository.dart';

enum AttendanceAction { checkIn, checkOut }

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

/// Estado que refleja si ya se hizo check-in y/o check-out en el turno actual.
class AttendanceReady extends AttendanceState {
  final bool hasCheckedIn;
  final bool hasCheckedOut;

  AttendanceReady({this.hasCheckedIn = false, this.hasCheckedOut = false});
}

class AttendanceSuccess extends AttendanceState {
  final AttendanceResponseModel response;
  final AttendanceAction action;

  AttendanceSuccess(this.response, this.action);
}

class AttendanceError extends AttendanceState {
  final String message;
  final Map<String, List<String>> errors;

  AttendanceError(this.message, [this.errors = const {}]);
}

class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRepository repository;

  bool _hasCheckedIn = false;
  bool _hasCheckedOut = false;

  AttendanceCubit(this.repository) : super(AttendanceInitial());

  /// Inicializa el estado de asistencia según el turno actual.
  /// Llamar desde [AttendanceCard] al conocer el schedule.
  void initFromSchedule({required bool isCompleted, String? startTime, String? endTime}) {
    if (isCompleted) {
      _hasCheckedIn = true;
      _hasCheckedOut = true;
    } else {
      // Si no está completado asumimos estado limpio (sin check-in aún)
      _hasCheckedIn = false;
      _hasCheckedOut = false;
    }
    emit(AttendanceReady(hasCheckedIn: _hasCheckedIn, hasCheckedOut: _hasCheckedOut));
  }

  /// Marca internamente que se completó una acción exitosa.
  void markSuccess(AttendanceAction action) {
    if (action == AttendanceAction.checkIn) _hasCheckedIn = true;
    if (action == AttendanceAction.checkOut) _hasCheckedOut = true;
    emit(AttendanceReady(hasCheckedIn: _hasCheckedIn, hasCheckedOut: _hasCheckedOut));
  }

  /// Parsea "HH:mm:ss" al DateTime de hoy.
  static DateTime? _parseShiftTime(String? timeStr) {
    if (timeStr == null) return null;
    final parts = timeStr.split(':');
    if (parts.length < 2) return null;
    final now = DateTime.now();
    return DateTime(
      now.year, now.month, now.day,
      int.tryParse(parts[0]) ?? 0,
      int.tryParse(parts[1]) ?? 0,
    );
  }

  /// Valida si la acción está dentro de la ventana de ±15 minutos del turno.
  /// Retorna null si es válido, o un mensaje de error.
  String? _validateWindow(AttendanceAction action, String? startTime, String? endTime) {
    final now = DateTime.now();

    if (action == AttendanceAction.checkIn) {
      final shiftStart = _parseShiftTime(startTime);
      final shiftEnd = _parseShiftTime(endTime);

      // Bloquear si el turno ya terminó (más de 15 min después del fin)
      if (shiftEnd != null && now.difference(shiftEnd).inMinutes > 15) {
        return 'Tu turno ya finalizó. No puedes registrar entrada.';
      }

      // Bloquear si faltan más de 15 min para el inicio
      if (shiftStart != null && shiftStart.difference(now).inMinutes > 15) {
        final mins = shiftStart.difference(now).inMinutes;
        return 'Tu turno inicia en $mins min. Puedes marcar entrada 15 min antes.';
      }
    }

    if (action == AttendanceAction.checkOut) {
      final shiftEnd = _parseShiftTime(endTime);
      if (shiftEnd != null) {
        final diff = now.difference(shiftEnd).inMinutes; // positivo = después del fin
        if (diff < -15) {
          final mins = shiftEnd.difference(now).inMinutes;
          return 'Tu turno termina en $mins min. Puedes marcar salida 15 min antes.';
        }
        if (diff > 15) {
          return 'Han pasado más de 15 min desde el fin de tu turno. Contacta a tu supervisor.';
        }
      }
    }

    return null;
  }

  Future<void> submitAttendance(
    String rawQr,
    AttendanceAction action, {
    String? shiftStartTime,
    String? shiftEndTime,
  }) async {
    // Validar acciones ya realizadas
    if (action == AttendanceAction.checkIn && _hasCheckedIn) {
      emit(AttendanceError('Ya registraste tu entrada en este turno.'));
      return;
    }
    if (action == AttendanceAction.checkOut && _hasCheckedOut) {
      emit(AttendanceError('Ya registraste tu salida en este turno.'));
      return;
    }
    if (action == AttendanceAction.checkOut && !_hasCheckedIn) {
      emit(AttendanceError('Debes registrar tu entrada antes de marcar salida.'));
      return;
    }

    // Validar ventana de 15 minutos
    final windowError = _validateWindow(action, shiftStartTime, shiftEndTime);
    if (windowError != null) {
      emit(AttendanceError(windowError));
      return;
    }

    emit(AttendanceLoading());
    try {
      final qrPayload = AttendanceQrPayload.fromRawValue(rawQr);
      final position = await _determinePosition();
      final nowUtc = DateTime.now().toUtc();

      final response = action == AttendanceAction.checkIn
          ? await repository.checkIn(
              qrCode: qrPayload.token,
              latitude: position.latitude,
              longitude: position.longitude,
              clientTimestamp: nowUtc,
            )
          : await repository.checkOut(
              qrCode: qrPayload.token,
              latitude: position.latitude,
              longitude: position.longitude,
              clientTimestamp: nowUtc,
            );

      if (action == AttendanceAction.checkIn) _hasCheckedIn = true;
      if (action == AttendanceAction.checkOut) _hasCheckedOut = true;

      emit(AttendanceSuccess(response, action));
    } on AttendanceException catch (e) {
      emit(AttendanceError(e.message, e.errors));
    } on FormatException catch (e) {
      emit(AttendanceError(e.message));
    } on Exception catch (e) {
      emit(AttendanceError('Error inesperado: ${e.toString()}'));
    }
  }

  Future<Position> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw AttendanceException(
        'Activa la ubicación del dispositivo para continuar.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw AttendanceException(
        'Permiso de ubicación denegado. Permite el acceso en ajustes.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw AttendanceException(
        'Permiso de ubicación bloqueado permanentemente. Actívalo en los ajustes.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }
}