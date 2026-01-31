import 'package:dio/dio.dart';

class AttendanceRepository {
  // Cuando tengas tu API, aquí usarás Dio
  Future<bool> registerAttendance(String qrCode, String userId) async {
    // Simulación de envío a la API
    await Future.delayed(const Duration(seconds: 2));

    // Aquí podrías validar si el QR contiene la palabra "DYSCH-OFFICE"
    if (qrCode.isNotEmpty) {
      print(
        "Asistencia registrada para el usuario $userId con código: $qrCode",
      );
      return true;
    }
    return false;
  }
}
