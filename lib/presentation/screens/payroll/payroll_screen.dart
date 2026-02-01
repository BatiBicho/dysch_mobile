import 'package:dysch_mobile/data/repositories/payroll_repository.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'widgets/current_payroll_card.dart';
import 'widgets/history_payroll_item.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

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
              onDownload: () => _startDownload(context, 'JAN-1'),
            ),
            HistoryPayrollItem(
              dateRange: '16 - 31 Diciembre 2025',
              amount: '\$14,500.00',
              onDownload: () => _startDownload(context, 'DEC-2'),
            ),
          ],
        ),
      ),
    );
  }

  void _startDownload(BuildContext context, String id) async {
    // 1. Feedback visual de inicio
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Descargando recibo de nómina...")),
    );

    // 2. Llamada al repositorio
    final String? filePath = await PayrollRepository().downloadPayroll(id);

    if (filePath != null) {
      // 3. Si se descargó, mostramos SnackBar con opción de abrir
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Descarga completa"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: "ABRIR",
            textColor: Colors.white,
            onPressed: () async {
              // 4. Abrir el archivo descargado
              final result = await OpenFile.open(filePath);

              // Opcional: Manejar si no hay app para abrir PDFs
              if (result.type != ResultType.done) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "No se pudo abrir el archivo: ${result.message}",
                    ),
                  ),
                );
              }
            },
          ),
        ),
      );
    } else {
      // Error en la descarga
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al descargar el archivo"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
