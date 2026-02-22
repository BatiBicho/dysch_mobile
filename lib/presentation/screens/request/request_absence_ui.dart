import 'package:flutter/material.dart';

/// Clase con métodos para mostrar feedback al usuario
class RequestAbsenceUI {
  /// Mostrar SnackBar de éxito (verde)
  static void showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Mostrar SnackBar de error (rojo)
  static void showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Mostrar SnackBar de información (azul)
  static void showInfoSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Mostrar SnackBar de carga
  static void showLoadingSnackBar(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            SizedBox(width: 12),
            Expanded(child: Text('Procesando solicitud...')),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 30),
      ),
    );
  }

  /// Ocultar el SnackBar actual
  static void hideSnackBar(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Mostrar diálogo de éxito
  static Future<void> showSuccessDialog(
    BuildContext context, {
    required int filesCount,
    required VoidCallback onClose,
  }) async {
    if (!context.mounted) return;
    hideSnackBar(context);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('✅ Solicitud Enviada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            Text(
              filesCount == 0
                  ? 'Tu solicitud ha sido enviada exitosamente.'
                  : 'Tu solicitud y $filesCount archivo(s) han sido enviados exitosamente.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onClose();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  /// Mostrar diálogo de error
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String message,
    required VoidCallback onClose,
  }) async {
    if (!context.mounted) return;
    hideSnackBar(context);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('❌ Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onClose();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
