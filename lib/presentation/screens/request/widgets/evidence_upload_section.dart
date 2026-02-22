import 'package:flutter/material.dart';
import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/presentation/screens/request/helpers/request_absence_helpers.dart';

/// Widget que contiene la sección de carga de evidencias
class EvidenceUploadSection extends StatelessWidget {
  final List<Map<String, dynamic>> selectedFiles;
  final VoidCallback onPickFiles;
  final Function(int) onRemoveFile;
  final VoidCallback onClearAll;

  const EvidenceUploadSection({
    required this.selectedFiles,
    required this.onPickFiles,
    required this.onRemoveFile,
    required this.onClearAll,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('EVIDENCIA (OPCIONAL)'),
        GestureDetector(onTap: onPickFiles, child: _buildUploadArea()),
        if (selectedFiles.isNotEmpty) ...[
          _buildSizeIndicator(),
          const SizedBox(height: 16),
          _buildSelectedFilesList(),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCircleIcon(Icons.camera_alt, AppColors.primary),
              const SizedBox(width: 16),
              _buildCircleIcon(Icons.attach_file, Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Toca para seleccionar archivos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'JPG, PNG, PDF, DOC, DOCX',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildSizeIndicator() {
    final totalSize = selectedFiles.fold<int>(
      0,
      (sum, file) => sum + (file['size'] as int),
    );
    final maxTotalSize = RequestAbsenceHelpers.maxTotalSize;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${selectedFiles.length} archivo(s) - ${RequestAbsenceHelpers.formatBytes(totalSize)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: totalSize / maxTotalSize,
                  backgroundColor: Colors.grey[300],
                  color: totalSize > maxTotalSize * 0.8
                      ? AppColors.primary
                      : Colors.green,
                  minHeight: 4,
                ),
                const SizedBox(height: 4),
                Text(
                  'Límite: ${RequestAbsenceHelpers.formatBytes(maxTotalSize)}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
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
            if (selectedFiles.isNotEmpty)
              TextButton.icon(
                onPressed: onClearAll,
                icon: const Icon(Icons.delete_outline, size: 14),
                label: const Text(
                  'Limpiar todo',
                  style: TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ..._buildFilesList(),
      ],
    );
  }

  List<Widget> _buildFilesList() {
    return selectedFiles.asMap().entries.map((entry) {
      final file = entry.value;
      final index = entry.key;
      return _buildFileTile(file, index);
    }).toList();
  }

  Widget _buildFileTile(Map<String, dynamic> file, int index) {
    final size = RequestAbsenceHelpers.formatBytes(file['size']);
    final icon = RequestAbsenceHelpers.getFileIcon(file['extension']);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  size,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => onRemoveFile(index),
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
            padding: EdgeInsets.zero,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
