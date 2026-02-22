import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/presentation/screens/request/widgets/incident_form_section.dart';
import 'package:dysch_mobile/presentation/screens/request/widgets/evidence_upload_section.dart';
import 'package:dysch_mobile/presentation/screens/request/request_absence_controller.dart';
import 'package:dysch_mobile/presentation/screens/request/request_absence_ui.dart';
import 'package:dysch_mobile/logic/incident/incident_cubit.dart';

class RequestAbsenceScreen extends StatefulWidget {
  const RequestAbsenceScreen({super.key});

  @override
  State<RequestAbsenceScreen> createState() => _RequestAbsenceScreenState();
}

class _RequestAbsenceScreenState extends State<RequestAbsenceScreen> {
  // === CONTROLLERS Y ESTADO ===
  late RequestAbsenceController _controller;

  // Estado del formulario
  String _selectedType = 'SICK_LEAVE';
  bool _isFullDay = true;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  final _justificationController = TextEditingController();
  final _extraFieldsController = TextEditingController();
  final List<Map<String, dynamic>> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _controller = RequestAbsenceController(selectedFiles: _selectedFiles);
  }

  @override
  void dispose() {
    _justificationController.dispose();
    _extraFieldsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IncidentCubit, IncidentState>(
      listener: _handleIncidentStateChange,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(title: const Text('Solicitar Ausencia')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de formulario
              IncidentFormSection(
                selectedType: _selectedType,
                isFullDay: _isFullDay,
                startDate: _startDate,
                endDate: _endDate,
                justificationController: _justificationController,
                extraFieldsController: _extraFieldsController,
                onTypeChanged: _updateSelectedType,
                onFullDayChanged: _updateFullDay,
                onStartDateChanged: _updateStartDate,
                onEndDateChanged: _updateEndDate,
              ),
              const SizedBox(height: 24),

              // Sección de evidencias
              EvidenceUploadSection(
                selectedFiles: _selectedFiles,
                onPickFiles: _handlePickFiles,
                onRemoveFile: _handleRemoveFile,
                onClearAll: _handleClearAllFiles,
              ),
              const SizedBox(height: 32),

              // Botón enviar
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // === HANDLERS DE FORMULARIO ===

  void _updateSelectedType(String type) {
    setState(() => _selectedType = type);
  }

  void _updateFullDay(bool value) {
    setState(() => _isFullDay = value);
  }

  void _updateStartDate(DateTime date) {
    setState(() => _startDate = date);
  }

  void _updateEndDate(DateTime date) {
    setState(() => _endDate = date);
  }

  // === HANDLERS DE EVIDENCIAS ===

  Future<void> _handlePickFiles() async {
    final success = await _controller.pickFiles();

    if (!mounted) return;

    if (!success && _selectedFiles.isEmpty) {
      RequestAbsenceUI.showErrorSnackBar(
        context,
        '❌ Error al seleccionar archivos',
      );
    } else if (!success) {
      if (_selectedFiles.length >= 10) {
        RequestAbsenceUI.showErrorSnackBar(
          context,
          '⚠️ Máximo 10 archivos permitidos',
        );
      } else if (_validateTotalSize() > 20 * 1024 * 1024) {
        RequestAbsenceUI.showErrorSnackBar(
          context,
          '⚠️ Límite total de 20MB alcanzado',
        );
      } else {
        RequestAbsenceUI.showErrorSnackBar(
          context,
          '❌ Imposible agregar archivo (tamaño máximo excedido)',
        );
      }
    } else {
      setState(() {});
      RequestAbsenceUI.showSuccessSnackBar(
        context,
        '${_selectedFiles.length} archivo(s) cargado(s)',
      );
    }
  }

  void _handleRemoveFile(int index) {
    _controller.removeFile(index);
    setState(() {});
    RequestAbsenceUI.showInfoSnackBar(context, 'Archivo eliminado');
  }

  void _handleClearAllFiles() {
    _controller.clearAllFiles();
    setState(() {});
    RequestAbsenceUI.showInfoSnackBar(context, 'Archivos eliminados');
  }

  // === SUBMIT ===

  void _handleSubmitRequest() {
    final validationError = _controller.validateRequest(
      description: _justificationController.text,
      startDate: _startDate,
      endDate: _endDate,
    );

    if (validationError != null) {
      RequestAbsenceUI.showErrorSnackBar(context, validationError);
      return;
    }

    RequestAbsenceUI.showLoadingSnackBar(context);

    _controller.submitRequest(
      context: context,
      incidentType: _selectedType,
      startDate: _startDate,
      endDate: _endDate,
      description: _justificationController.text,
      extraFields: _extraFieldsController.text,
    );
  }

  // === BLoC LISTENER ===

  void _handleIncidentStateChange(BuildContext context, IncidentState state) {
    if (state is IncidentSuccess) {
      _handleIncidentCreated(context, state.incident.id);
    } else if (state is EvidenceUploadSuccess) {
      _handleEvidenceUploaded(context);
    } else if (state is IncidentError) {
      RequestAbsenceUI.hideSnackBar(context);
      RequestAbsenceUI.showErrorSnackBar(context, '❌ ${state.message}');
    }
  }

  void _handleIncidentCreated(BuildContext context, String incidentId) {
    RequestAbsenceUI.hideSnackBar(context);

    if (incidentId.isEmpty) {
      RequestAbsenceUI.showErrorSnackBar(
        context,
        '❌ Error: No se pudo obtener el ID del incidente',
      );
      return;
    }

    if (_selectedFiles.isNotEmpty) {
      RequestAbsenceUI.showInfoSnackBar(
        context,
        'Subiendo ${_selectedFiles.length} archivo(s)...',
      );
      _controller.uploadEvidences(context: context, incidentId: incidentId);
    } else {
      _showSuccessDialogAndReset(context);
    }
  }

  void _handleEvidenceUploaded(BuildContext context) {
    _controller.incrementEvidencesUploaded();

    if (_controller.allEvidencesUploaded()) {
      RequestAbsenceUI.hideSnackBar(context);
      _showSuccessDialogAndReset(context);
    } else {
      RequestAbsenceUI.showInfoSnackBar(
        context,
        '✅ ${_controller.evidencesUploaded}/${_controller.totalEvidencesToUpload} archivo(s) subido(s)',
      );
    }
  }

  Future<void> _showSuccessDialogAndReset(BuildContext context) async {
    await RequestAbsenceUI.showSuccessDialog(
      context,
      filesCount: _selectedFiles.length,
      onClose: () {
        _resetForm();
        Navigator.pop(context);
      },
    );
  }

  // === UTILIDADES ===

  int _validateTotalSize() {
    return _selectedFiles.fold<int>(
      0,
      (sum, file) => sum + (file['size'] as int),
    );
  }

  void _resetForm() {
    setState(() {
      _selectedType = 'SICK_LEAVE';
      _isFullDay = true;
      _startDate = DateTime.now();
      _endDate = DateTime.now();
      _justificationController.clear();
      _extraFieldsController.clear();
    });
    _controller.reset();
  }

  // === WIDGETS ===

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleSubmitRequest,
        icon: const Icon(Icons.send),
        label: const Text('Enviar Solicitud'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
