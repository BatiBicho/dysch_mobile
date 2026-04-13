// prenomina_detail_card.dart
import 'package:flutter/material.dart';
import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/data/models/prenomina_model.dart';

class PrenominaDetailCard extends StatelessWidget {
  final PrenominaResponse prenomina;
  final bool isLoading;
  final VoidCallback? onDownloadPdf;

  const PrenominaDetailCard({
    super.key,
    required this.prenomina,
    this.isLoading = false,
    this.onDownloadPdf,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (prenomina.hasError) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, color: Colors.orange, size: 48),
            const SizedBox(height: 12),
            Text(
              prenomina.detail ?? 'Periodo aún no confirmado',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (!prenomina.isValid) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado con título y botón de descarga
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Detalle Prenómina',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (onDownloadPdf != null)
              SizedBox(
                width: 100,
                child: ElevatedButton.icon(
                  onPressed: onDownloadPdf,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Resumen de ingresos y deducciones
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                'Sueldo Bruto',
                prenomina.grossPay ?? 0,
                color: Colors.green,
              ),
              const Divider(height: 16),
              if ((prenomina.bonusAmount ?? 0) > 0) ...[
                _buildSummaryRow(
                  'Bono',
                  prenomina.bonusAmount ?? 0,
                  color: Colors.blue,
                ),
                const Divider(height: 16),
              ],
              _buildSummaryRow(
                'IMSS',
                prenomina.imssDeduction ?? 0,
                color: Colors.red,
                isDeduction: true,
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                'ISR',
                prenomina.isrDeduction ?? 0,
                color: Colors.red,
                isDeduction: true,
              ),
              const Divider(height: 16),
              _buildSummaryRow(
                'Sueldo Neto',
                prenomina.netPay ?? 0,
                isTotal: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Información de horas
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen de Días y Horas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Días trabajados', '${prenomina.daysWorked}'),
              _buildInfoRow('Días ausentes', '${prenomina.daysAbsent}'),
              _buildInfoRow(
                'Horas regulares',
                '${prenomina.totalRegularHours}',
              ),
              _buildInfoRow('Horas extras', '${prenomina.totalOvertimeHours}'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Desglose diario
        if (prenomina.dailyBreakdown != null &&
            prenomina.dailyBreakdown!.isNotEmpty) ...[
          const Text(
            'Desglose Diario',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ...prenomina.dailyBreakdown!.map(
            (day) => _buildDailyBreakdownItem(day),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    Color? color,
    bool isDeduction = false,
    bool isTotal = false,
  }) {
    final formattedAmount = '\$${amount.toStringAsFixed(2)}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          isDeduction ? '-$formattedAmount' : formattedAmount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: color ?? (isTotal ? AppColors.primary : Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyBreakdownItem(DailyBreakdown day) {
    final isWorked = day.type == 'worked';
    final isAbsent = day.type == 'absent';

    Color statusColor = Colors.grey;
    String statusLabel = 'Descanso';

    if (isWorked) {
      statusColor = Colors.green;
      statusLabel = 'Trabajado';
    } else if (isAbsent) {
      statusColor = Colors.red;
      statusLabel = 'Ausente';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day.date,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (isWorked) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pago base: \$${day.basePay?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(fontSize: 12),
                ),
                if ((day.overtimePay ?? 0) > 0)
                  Text(
                    'Extras: \$${day.overtimePay?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Total: \$${day.totalGross?.toStringAsFixed(2) ?? '0.00'} | ${day.regularHours}h regulares${day.overtimeHours != null && day.overtimeHours! > 0 ? ' + ${day.overtimeHours}h extras' : ''}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }
}
