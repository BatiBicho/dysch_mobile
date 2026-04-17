import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/logic/attendance/attendance_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  /// Parámetros opcionales pasados desde AttendanceCard vía GoRouter extra:
  /// { 'action': AttendanceAction, 'startTime': String, 'endTime': String }
  final Map<String, dynamic>? extra;

  const QrScannerScreen({super.key, this.extra});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool isScanning = true;
  bool _isDialogOpen = false;
  late AttendanceAction _currentAction;
  String? _shiftStartTime;
  String? _shiftEndTime;

  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  @override
  void initState() {
    super.initState();
    final extra = widget.extra;
    _currentAction =
        (extra?['action'] as AttendanceAction?) ?? AttendanceAction.checkIn;
    _shiftStartTime = extra?['startTime'] as String?;
    _shiftEndTime = extra?['endTime'] as String?;
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    setState(() => isScanning = false);
    final String rawQr = barcodes.first.rawValue ?? '';
    context.read<AttendanceCubit>().submitAttendance(
          rawQr,
          _currentAction,
          shiftStartTime: _shiftStartTime,
          shiftEndTime: _shiftEndTime,
        );
  }

  void _showLoadingDialog() {
    if (_isDialogOpen) return;
    _isDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Validando datos...'),
          ],
        ),
      ),
    ).then((_) => _isDialogOpen = false);
  }

  void _closeLoadingDialog() {
    if (!_isDialogOpen) return;
    Navigator.of(context, rootNavigator: true).pop();
    _isDialogOpen = false;
  }

  void _showSuccessSheet(AttendanceSuccess state) {
    final isCheckIn = state.action == AttendanceAction.checkIn;
    final title = isCheckIn ? 'Check-in registrado' : 'Check-out registrado';
    final timestamp = isCheckIn
        ? state.response.record.checkInClientTimestamp
        : state.response.record.checkOutClientTimestamp;
    final subtitle = isCheckIn ? '¡Entrada exitosa!' : '¡Salida registrada!';
    final details = !isCheckIn && state.response.minutesWorked != null
        ? 'Horas trabajadas: ${state.response.minutesWorked}'
        : 'Usuario: ${state.response.record.employeeName}';

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 72),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle),
            if (timestamp != null) ...[
              const SizedBox(height: 12),
              Text('Hora: $timestamp'),
            ],
            const SizedBox(height: 12),
            Text(details),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(AttendanceError state) {
    final errorDetails = state.errors.entries
        .map((e) => '${e.key}: ${e.value.join(', ')}')
        .join(' • ');
    final message =
        state.message.isNotEmpty ? state.message : errorDetails;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.isNotEmpty ? message : 'Ocurrió un error al procesar el QR.',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCheckIn = _currentAction == AttendanceAction.checkIn;

    return BlocListener<AttendanceCubit, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceLoading) {
          _showLoadingDialog();
        } else {
          _closeLoadingDialog();
        }

        if (state is AttendanceSuccess) {
          _showSuccessSheet(state);
        }

        if (state is AttendanceError) {
          _showErrorSnackBar(state);
          setState(() => isScanning = true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isCheckIn ? 'Escanear Check-in' : 'Escanear Check-out',
          ),
          backgroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Indicador de acción fija (no editable desde aquí)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isCheckIn
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCheckIn ? AppColors.primary : Colors.orange,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isCheckIn ? Icons.login : Icons.logout,
                        color: isCheckIn ? AppColors.primary : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCheckIn
                            ? 'Registrando ENTRADA'
                            : 'Registrando SALIDA',
                        style: TextStyle(
                          color:
                              isCheckIn ? AppColors.primary : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: _onDetect,
                    ),
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.white, width: 4),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            isScanning
                                ? 'Alinea el código QR dentro del cuadro'
                                : 'Procesando... espera un momento',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isCheckIn
                                ? 'Se enviará un check-in'
                                : 'Se enviará un check-out',
                            textAlign: TextAlign.center,
                            style:
                                const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}