import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dysch_mobile/data/models/attendance_model.dart';
import 'package:dysch_mobile/data/repositories/attendance_repository.dart';

enum AttendanceAction { checkIn, checkOut }

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

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

  AttendanceCubit(this.repository) : super(AttendanceInitial());

  Future<void> submitAttendance(String rawQr, AttendanceAction action) async {
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
