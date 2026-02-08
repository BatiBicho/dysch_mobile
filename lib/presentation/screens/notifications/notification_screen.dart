import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'widgets/notification_item.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            color: Color(0xFF1A1C1E),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.done_all,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de pestañas (Sin leer / Todas)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Sin leer  3',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Todas',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista de Notificaciones
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Dismissible(
                  key: const Key(
                    'notification_dismiss',
                  ), // Usa un ID único real aquí
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  child: const NotificationItem(
                    icon: Icons.access_time_filled,
                    iconColor: AppColors.primary,
                    title: 'Recordatorio de Entrada',
                    time: 'Hace 5 min',
                    isUnread: true,
                    description:
                        'No has registrado tu entrada. Tienes 5 minutos para evitar un retardo.',
                  ),
                ),

                Dismissible(
                  key: const Key(
                    'notification_dismiss',
                  ), // Usa un ID único real aquí
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  child: const NotificationItem(
                    icon: Icons.check_circle,
                    iconColor: Colors.green,
                    title: 'Vacaciones Aprobadas',
                    time: 'Hace 1h',
                    isUnread: true,
                    description:
                        'Tu solicitud para el 15-20 de Dic ha sido aprobada por RH.',
                  ),
                ),

                Dismissible(
                  key: const Key(
                    'notification_dismiss',
                  ), // Usa un ID único real aquí
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  child: const NotificationItem(
                    icon: Icons.swap_horiz,
                    iconColor: Colors.amber,
                    title: 'Cambio de Turno',
                    time: 'Ayer',
                    description: 'Tu horario del Jueves ha cambiado a 9:00 AM.',
                  ),
                ),

                Dismissible(
                  key: const Key(
                    'notification_dismiss',
                  ), // Usa un ID único real aquí
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  child: const NotificationItem(
                    icon: Icons.description,
                    iconColor: Colors.blue,
                    title: 'Nómina Disponible',
                    time: 'Lun',
                    description:
                        'Tu recibo de pago de la 1ra quincena de Diciembre está listo.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
