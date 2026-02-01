import 'package:dysch_mobile/data/repositories/payroll_repository.dart';
import 'package:flutter/material.dart';
import 'widgets/current_payroll_card.dart';
import 'widgets/history_payroll_item.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  final PayrollRepository _payrollRepository = PayrollRepository();
  bool _isDownloading = false;
  String? _currentDownloadId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CurrentPayrollCard(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Historial de Pagos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Ver todo',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            HistoryPayrollItem(
              dateRange: '01 - 15 Enero 2026',
              amount: '\$11,200.00',
              isDownloading: _isDownloading && _currentDownloadId == 'JAN-1',
              onDownload: () => _startDownload('JAN-1'),
            ),
            HistoryPayrollItem(
              dateRange: '16 - 31 Diciembre 2025',
              amount: '\$14,500.00',
              isDownloading: _isDownloading && _currentDownloadId == 'DEC-2',
              onDownload: () => _startDownload('DEC-2'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startDownload(String id) async {
    // Evitar múltiples descargas simultáneas
    if (_isDownloading) {
      _showSnackBar(
        'Espera a que termine la descarga actual',
        Colors.orange,
        duration: 3,
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _currentDownloadId = id;
    });

    try {
      // SnackBar de inicio
      _showSnackBar('Descargando nómina...', Colors.blue, duration: 2);

      // Descargar archivo (sin abrir automáticamente)
      final String? filePath = await _payrollRepository.downloadPayroll(id);

      if (filePath != null) {
        // Mostrar SnackBar con opción de abrir
        _showDownloadSuccessSnackBar(filePath, id);
      } else {
        _showSnackBar(
          '❌ Error al descargar la nómina',
          Colors.red,
          duration: 5,
        );
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red, duration: 5);
    } finally {
      setState(() {
        _isDownloading = false;
        _currentDownloadId = null;
      });
    }
  }

  void _showDownloadSuccessSnackBar(String filePath, String periodId) {
    final snackBarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Nómina descargada exitosamente',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green, // Verde más profesional
        duration: const Duration(seconds: 5), // Duración extendida
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'ABRIR',
          textColor: Colors.white,
          onPressed: () async {
            try {
              await _payrollRepository.openPayrollFile(filePath);
            } catch (e) {
              _showSnackBar(
                'No se pudo abrir el archivo',
                Colors.red,
                duration: 3,
              );
            }
          },
        ),
        // Callback cuando se cierra automáticamente
        onVisible: () {
          print('SnackBar visible - se cerrará en 8 segundos');
        },
      ),
    );

    // Opcional: Agregar un timer para cerrar manualmente si quieres
    // Future.delayed(const Duration(seconds: 8), () {
    //   snackBarController.close();
    // });
  }

  void _showSnackBar(
    String message,
    Color backgroundColor, {
    int duration = 3,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: duration),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Opcional: Si quieres mostrar un diálogo de confirmación antes de abrir
  Future<void> _confirmAndOpenFile(String filePath, String periodId) async {
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nómina descargada'),
        content: Text('¿Deseas abrir la nómina de $periodId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('NO'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('ABRIR'),
          ),
        ],
      ),
    );

    if (shouldOpen == true) {
      try {
        await _payrollRepository.openPayrollFile(filePath);
      } catch (e) {
        _showSnackBar('No se pudo abrir el archivo', Colors.red, duration: 3);
      }
    }
  }
}
