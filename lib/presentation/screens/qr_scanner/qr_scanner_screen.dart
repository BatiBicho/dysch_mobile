import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/attendance_repository.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool isScanning = true;
  final AttendanceRepository _repository = AttendanceRepository();

  void _onDetect(BarcodeCapture capture) async {
    if (!isScanning) return; // Evita múltiples escaneos accidentales

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      setState(() => isScanning = false); // Pausamos el escaneo

      final String code = barcodes.first.rawValue ?? "Código vacío";

      // Mostrar feedback visual de carga
      _showLoadingDialog();

      // Enviar a la "API"
      final success = await _repository.registerAttendance(code, "ID-999");

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        if (success) {
          _showSuccessSheet(code);
        } else {
          _showErrorSnackBar();
          setState(() => isScanning = true); // Reintentar
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Entrada'),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
              facing: CameraFacing.back,
            ),
            onDetect: _onDetect,
          ),
          // Cuadro guía para el usuario
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 4),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Text(
              'Alinea el código QR dentro del cuadro',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE FEEDBACK ---

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text("Validando entrada..."),
          ],
        ),
      ),
    );
  }

  void _showSuccessSheet(String code) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              '¡Entrada Exitosa!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'Registrada a las ${DateTime.now().hour}:${DateTime.now().minute}',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Volver al Inicio'),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error al validar el código. Intenta de nuevo.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
