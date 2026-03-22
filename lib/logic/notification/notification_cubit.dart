import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dysch_mobile/data/models/notification_model.dart';
import 'package:dysch_mobile/data/repositories/notification_repository.dart';

// Estados
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;

  NotificationLoaded(this.notifications);
}

class NotificationActionSuccess extends NotificationState {
  final String message;

  NotificationActionSuccess(this.message);
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}

// Cubit
class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;
  List<NotificationModel> _notifications = [];

  NotificationCubit(this._repository) : super(NotificationInitial());

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  Future<void> getListNotification() async {
    emit(NotificationLoading());
    try {
      _notifications = await _repository.getListNotifications();
      emit(NotificationLoaded(_notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> markOneNotification({required String idNotification}) async {
    emit(NotificationLoading());
    try {
      final updated = await _repository.markOneNotification(idNotification: idNotification);
      _notifications = _notifications
          .map((item) => item.id == updated.id ? updated : item)
          .toList();
      emit(NotificationLoaded(_notifications));
      emit(NotificationActionSuccess('Notificación marcada como leída'));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> markAllNotifications() async {
    emit(NotificationLoading());
    try {
      final message = await _repository.markAllNotifications();
      _notifications = _notifications.map((item) =>
          NotificationModel(
            id: item.id,
            companyId: item.companyId,
            recipientUserId: item.recipientUserId,
            recipientEmail: item.recipientEmail,
            notificationType: item.notificationType,
            title: item.title,
            message: item.message,
            actionUrl: item.actionUrl,
            relatedObjectType: item.relatedObjectType,
            relatedObjectId: item.relatedObjectId,
            isRead: true,
            readAt: DateTime.now(),
            pushSent: item.pushSent,
            pushSentAt: item.pushSentAt,
            expiresAt: item.expiresAt,
            isActive: item.isActive,
            createdAt: item.createdAt,
            updatedAt: DateTime.now(),
          ))
          .toList();
      emit(NotificationLoaded(_notifications));
      emit(NotificationActionSuccess(message));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
