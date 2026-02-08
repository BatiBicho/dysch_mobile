import 'dart:math';
import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/presentation/screens/request/widget/absence_type_selector.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class RequestAbsenceScreen extends StatefulWidget {
  const RequestAbsenceScreen({super.key});

  @override
  State<RequestAbsenceScreen> createState() => _RequestAbsenceScreenState();
}

class _RequestAbsenceScreenState extends State<RequestAbsenceScreen> {
  String _selectedType = 'Permiso personal';
  bool _isFullDay = true;
  final TextEditingController _justificationController =
      TextEditingController();

  List<Map<String, dynamic>> _selectedFiles = []; // Cambiado a Map

  // Límites de tamaño (en bytes)
  static const int _maxFileSize = 5 * 1024 * 1024; // 5 MB por archivo
  static const int _maxTotalSize = 20 * 1024 * 1024; // 20 MB total
  static const int _maxImageSize = 3 * 1024 * 1024; // 3 MB para imágenes
  static const int _maxPdfSize = 5 * 1024 * 1024; // 5 MB para PDFs

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
        dialogTitle: 'Seleccionar archivos de soporte',
        withReadStream: true, // Para obtener tamaño
      );

      if (result != null) {
        // Calcular tamaño total actual
        int currentTotalSize = _selectedFiles.fold(
          0,
          (sum, file) => sum + (file['size'] as int),
        );

        for (var platformFile in result.files) {
          // Validar tamaño individual
          if (platformFile.size > _getMaxSizeForExtension(platformFile.path!)) {
            _showErrorSnackBar(
              '❌ ${platformFile.name} excede el tamaño máximo permitido',
            );
            continue;
          }

          // Validar tamaño total
          if (currentTotalSize + platformFile.size > _maxTotalSize) {
            _showErrorSnackBar('⚠️ Límite total de 20MB alcanzado');
            break;
          }

          // Validar cantidad máxima de archivos (opcional)
          if (_selectedFiles.length >= 10) {
            _showErrorSnackBar('⚠️ Máximo 10 archivos permitidos');
            break;
          }

          currentTotalSize += platformFile.size;

          // Agregar archivo con metadata
          _selectedFiles.add({
            'path': platformFile.path!,
            'name': platformFile.name,
            'size': platformFile.size,
            'extension': platformFile.path!.split('.').last.toLowerCase(),
          });
        }

        if (result.files.isNotEmpty) {
          setState(() {});

          // Mostrar resumen de archivos subidos
          _showSuccessSnackBar(
            '${result.files.length} archivo(s) seleccionado(s)\n'
            'Tamaño total: ${_formatBytes(currentTotalSize)}',
          );
        }
      }
    } catch (e) {
      print("Error seleccionando archivos: $e");
      _showErrorSnackBar('Error al seleccionar archivos');
    }
  }

  // Obtener tamaño máximo según extensión
  int _getMaxSizeForExtension(String path) {
    final extension = path.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return _maxPdfSize; // 5 MB para PDFs
      case 'jpg':
      case 'jpeg':
      case 'png':
        return _maxImageSize; // 3 MB para imágenes
      case 'doc':
      case 'docx':
        return _maxFileSize; // 5 MB para documentos
      default:
        return _maxFileSize; // 5 MB por defecto
    }
  }

  // Formatear bytes a formato legible
  String _formatBytes(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });

    _showInfoSnackBar('Archivo eliminado');
  }

  String _getFileIcon(String extension) {
    switch (extension) {
      case 'pdf':
        return '📄';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return '🖼️';
      case 'doc':
      case 'docx':
        return '📝';
      default:
        return '📎';
    }
  }

  // Métodos para mostrar SnackBars
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calcular tamaño total
    final totalSize = _selectedFiles.fold(
      0,
      (sum, file) => sum + (file['size'] as int),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Solicitar Ausencia',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TIPO DE AUSENCIA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            AbsenceTypeSelector(
              selectedType: _selectedType,
              onSelected: (val) => setState(() => _selectedType = val),
            ),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DURACIÓN',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Row(
                  children: [
                    const Text('Todo el día', style: TextStyle(fontSize: 12)),
                    Switch(
                      value: _isFullDay,
                      onChanged: (val) => setState(() => _isFullDay = val),
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),

            // Selectores de Fecha (Inputs)
            Row(
              children: [
                Expanded(child: _buildDateInput('Desde', '12 Oct, 2023')),
                const SizedBox(width: 16),
                Expanded(child: _buildDateInput('Hasta', '13 Oct, 2023')),
              ],
            ),

            const SizedBox(height: 32),
            const Text(
              'JUSTIFICACIÓN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _justificationController,
              maxLines: 4,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: 'Describe brevemente la razón...',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'EVIDENCIA (OPCIONAL)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),

            // Área de carga de archivos
            GestureDetector(onTap: _pickFiles, child: _buildUploadArea()),

            // Información de tamaño
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedFiles.length} archivo(s) - ${_formatBytes(totalSize)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          LinearProgressIndicator(
                            value: totalSize / _maxTotalSize,
                            backgroundColor: Colors.grey[300],
                            color: totalSize > _maxTotalSize * 0.8
                                ? AppColors.primary
                                : Colors.green,
                            minHeight: 4,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Límite: ${_formatBytes(_maxTotalSize)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Lista de archivos seleccionados
            if (_selectedFiles.isNotEmpty) ...[_buildSelectedFilesList()],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedFiles.isEmpty
                    ? null
                    : () => _submitRequest(),
                icon: const Icon(Icons.arrow_forward),
                label: const Text(
                  'Enviar Solicitud',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInput(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: const TextStyle(fontWeight: FontWeight.w500)),
              const Icon(
                Icons.calendar_month,
                size: 18,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _circleIcon(Icons.camera_alt, AppColors.primary),
              const SizedBox(width: 16),
              _circleIcon(Icons.attach_file, Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Toca para seleccionar archivos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Receta médica, justificante, etc.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              Text(
                _selectedFiles.isEmpty
                    ? 'Formatos: JPG, PNG, PDF, DOC'
                    : '${_selectedFiles.length} archivo(s) seleccionado(s)',
                style: const TextStyle(fontSize: 11, color: Colors.blue),
              ),
              const SizedBox(height: 4),
              Text(
                'Máximo: 5MB por archivo, 20MB total',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFilesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Archivos seleccionados:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            if (_selectedFiles.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedFiles.clear();
                  });
                  _showInfoSnackBar('Todos los archivos eliminados');
                },
                icon: const Icon(Icons.delete_outline, size: 14),
                label: const Text(
                  'Limpiar todo',
                  style: TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ..._selectedFiles.asMap().entries.map((entry) {
          final index = entry.key;
          final file = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Text(
                  _getFileIcon(file['extension']),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              file['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              file['extension'].toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _formatBytes(file['size']),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              file['path'],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _removeFile(index),
                  icon: const Icon(Icons.close, size: 18),
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _circleIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }

  Future<void> _submitRequest() async {
    // Validar justificación
    if (_justificationController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor ingresa una justificación');
      return;
    }

    // Validar tamaño total
    final totalSize = _selectedFiles.fold(
      0,
      (sum, file) => sum + (file['size'] as int),
    );

    if (totalSize > _maxTotalSize) {
      _showErrorSnackBar('El tamaño total de los archivos excede los 20MB');
      return;
    }

    // Mostrar loading
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            SizedBox(width: 12),
            Expanded(child: Text('Enviando solicitud...')),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(minutes: 1), // Largo para que no desaparezca
      ),
    );

    try {
      // Aquí iría la lógica real del Cubit para enviar a la API
      await Future.delayed(const Duration(seconds: 2));

      // Cerrar SnackBar de loading
      scaffold.hideCurrentSnackBar();

      // Mostrar éxito
      scaffold.showSnackBar(
        SnackBar(
          content: Text(
            'Solicitud enviada exitosamente\n'
            '${_selectedFiles.length} archivo(s) adjunto(s)',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );

      // Limpiar formulario después de enviar
      setState(() {
        _selectedFiles.clear();
        _justificationController.clear();
      });

      // Opcional: regresar a la pantalla anterior después de un tiempo
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al enviar: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
