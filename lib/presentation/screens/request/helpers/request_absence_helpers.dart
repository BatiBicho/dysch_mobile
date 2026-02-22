import 'dart:math';

/// Clase con utilidades para la pantalla de solicitud de ausencia
class RequestAbsenceHelpers {
  /// Obtener el tamaño máximo permitido según la extensión de archivo
  static int getMaxSizeForExtension(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 5 * 1024 * 1024; // 5MB para PDF
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 3 * 1024 * 1024; // 3MB para imágenes
      default:
        return 5 * 1024 * 1024; // 5MB por defecto
    }
  }

  /// Convertir bytes a formato legible (B, KB, MB)
  static String formatBytes(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB"];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// Obtener emoji para el tipo de archivo
  static String getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
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

  /// Validar si un archivo es de tipo válido
  static bool isValidFileType(String extension) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'];
    return validExtensions.contains(extension.toLowerCase());
  }

  /// Obtener lista de extensiones permitidas
  static List<String> get allowedExtensions => [
    'jpg',
    'jpeg',
    'png',
    'pdf',
    'doc',
    'docx',
  ];

  /// Obtener información de validación
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const int maxTotalSize = 20 * 1024 * 1024; // 20MB
  static const int maxImageSize = 3 * 1024 * 1024; // 3MB
  static const int maxPdfSize = 5 * 1024 * 1024; // 5MB
  static const int maxFiles = 10;
}
