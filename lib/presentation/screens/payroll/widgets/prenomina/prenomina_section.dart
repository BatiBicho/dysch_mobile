import 'package:flutter/material.dart';
import 'package:dysch_mobile/data/models/payroll_period_model.dart';
import 'package:dysch_mobile/data/models/prenomina_model.dart';
import 'package:dysch_mobile/data/repositories/prenomina_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'period_dropdown_selector.dart';
import 'prenomina_detail_card.dart';

class PrenominaSection extends StatefulWidget {
  const PrenominaSection({super.key});

  @override
  State<PrenominaSection> createState() => _PrenominaSectionState();
}

class _PrenominaSectionState extends State<PrenominaSection> {
  late PrenominaRepository _repository;
  List<PayrollPeriod> _availablePeriods = [];
  PayrollPeriod? _selectedPeriod;
  PrenominaResponse? _prenomina;
  bool _isLoadingPeriods = false;
  bool _isLoadingPrenomina = false;
  bool _isDownloadingPdf = false;

  @override
  void initState() {
    super.initState();
    _repository = context.read<PrenominaRepository>();
    _fetchAvailablePeriods();
  }

  Future<void> _fetchAvailablePeriods() async {
    setState(() => _isLoadingPeriods = true);

    try {
      final response = await _repository.getAvailablePeriods();
      if (response != null && response.periods.isNotEmpty) {
        setState(() {
          _availablePeriods = response.periods;
          _selectedPeriod = response.periods.first;
        });
        _fetchPrenomina();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error al obtener períodos', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingPeriods = false);
      }
    }
  }

  Future<void> _fetchPrenomina() async {
    if (_selectedPeriod == null) return;

    setState(() => _isLoadingPrenomina = true);

    try {
      final result = await _repository.getPrenomina(
        periodStart: _selectedPeriod!.periodStart,
        periodEnd: _selectedPeriod!.periodEnd,
      );

      setState(() => _prenomina = result);
    } catch (e) {
      setState(() {
        _prenomina = PrenominaResponse(detail: 'Error al obtener la prenómina');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingPrenomina = false);
      }
    }
  }

  Future<void> _downloadPrenominaPdf() async {
    if (_selectedPeriod == null) return;

    setState(() => _isDownloadingPdf = true);

    try {
      final filePath = await _repository.downloadPrenominaPdf(
        periodStart: _selectedPeriod!.periodStart,
        periodEnd: _selectedPeriod!.periodEnd,
      );

      if (filePath != null && mounted) {
        _showDownloadSuccessSnackBar(filePath);
      } else if (mounted) {
        _showSnackBar('❌ No se pudo descargar la prenómina', Colors.red);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloadingPdf = false);
      }
    }
  }

  void _showDownloadSuccessSnackBar(String filePath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Prenómina descargada exitosamente',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'ABRIR',
          textColor: Colors.white,
          onPressed: () async {
            try {
              await OpenFile.open(filePath);
            } catch (e) {
              _showSnackBar('No se pudo abrir el archivo', Colors.red);
            }
          },
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prenómina',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        PeriodDropdownSelector(
          periods: _availablePeriods,
          selectedPeriod: _selectedPeriod,
          isLoading: _isLoadingPeriods,
          onPeriodSelected: (period) {
            setState(() => _selectedPeriod = period);
            _fetchPrenomina();
          },
        ),
        const SizedBox(height: 20),
        PrenominaDetailCard(
          prenomina: _prenomina ?? PrenominaResponse(),
          isLoading: _isLoadingPrenomina,
          onDownloadPdf: _isDownloadingPdf ? null : _downloadPrenominaPdf,
        ),
      ],
    );
  }
}
