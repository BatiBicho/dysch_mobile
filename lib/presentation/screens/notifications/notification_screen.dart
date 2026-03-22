import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/data/models/notification_model.dart';
import 'package:dysch_mobile/logic/auth/auth_cubit.dart';
import 'package:dysch_mobile/logic/notification/notification_cubit.dart';
import 'package:dysch_mobile/presentation/screens/notifications/widgets/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _showOnlyUnread = false;
  bool _hasLoadedNotifications = false;

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Hace unos segundos';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void initState() {
    super.initState();
    // Cargar notificaciones si el usuario está autenticado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isAuthenticated = context.read<AuthCubit>().state is AuthSuccess;
      if (isAuthenticated && !_hasLoadedNotifications) {
        context.read<NotificationCubit>().getListNotification();
        _hasLoadedNotifications = true;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Escuchar cambios en el estado de autenticación
    final isAuthenticated = context.read<AuthCubit>().state is AuthSuccess;
    if (isAuthenticated && !_hasLoadedNotifications) {
      context.read<NotificationCubit>().getListNotification();
      _hasLoadedNotifications = true;
    } else if (!isAuthenticated) {
      _hasLoadedNotifications = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.select((AuthCubit cubit) {
      return cubit.state is AuthSuccess;
    });

    // Si no está autenticado, mostrar mensaje
    if (!isAuthenticated) {
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
        ),
        body: const Center(
          child: Text(
            'Debes iniciar sesión para ver las notificaciones',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, authState) {
        if (authState is AuthSuccess && !_hasLoadedNotifications) {
          context.read<NotificationCubit>().getListNotification();
          _hasLoadedNotifications = true;
        } else if (authState is AuthInitial) {
          _hasLoadedNotifications = false;
        }
      },
      child: Scaffold(
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
            IconButton(
              tooltip: 'Marcar todas como leídas',
              icon: const Icon(Icons.done_all),
              color: AppColors.primary.withValues(alpha: 0.8),
              onPressed: () {
                context.read<NotificationCubit>().markAllNotifications();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: FilterChip(
                      label: const Text('Todas'),
                      selected: !_showOnlyUnread,
                      onSelected: (value) {
                        setState(() {
                          _showOnlyUnread = !value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilterChip(
                      label: const Text('Sin leer'),
                      selected: _showOnlyUnread,
                      onSelected: (value) {
                        setState(() {
                          _showOnlyUnread = value;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<NotificationCubit>().getListNotification();
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: BlocConsumer<NotificationCubit, NotificationState>(
                listener: (context, state) {
                  if (state is NotificationError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  } else if (state is NotificationActionSuccess) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  final cubit = context.read<NotificationCubit>();
                  List<NotificationModel> items = cubit.notifications;
                  if (state is NotificationLoaded) {
                    items = state.notifications;
                  }

                  if (state is NotificationLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredItems = _showOnlyUnread
                      ? items.where((item) => !item.isRead).toList()
                      : items;

                  if (filteredItems.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay notificaciones${_showOnlyUnread ? ' sin leer' : ''}.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final model = filteredItems[index];

                      return Dismissible(
                        key: Key(model.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.done_all, color: Colors.red),
                        ),
                        onDismissed: (_) {
                          context.read<NotificationCubit>().markOneNotification(
                            idNotification: model.id,
                          );
                        },
                        child: NotificationItem(
                          icon: Icons.notifications,
                          iconColor: model.isRead
                              ? Colors.grey
                              : AppColors.primary,
                          title: model.title,
                          time: _formatTimeAgo(model.createdAt),
                          description: model.message,
                          isUnread: !model.isRead,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
