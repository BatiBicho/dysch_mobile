class NotificationModel {
  final String id;
  final String? companyId;
  final String? recipientUserId;
  final String? recipientEmail;
  final String notificationType;
  final String title;
  final String message;
  final String? actionUrl;
  final String? relatedObjectType;
  final String? relatedObjectId;
  final bool isRead;
  final DateTime? readAt;
  final bool pushSent;
  final DateTime? pushSentAt;
  final DateTime? expiresAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    this.companyId,
    this.recipientUserId,
    this.recipientEmail,
    required this.notificationType,
    required this.title,
    required this.message,
    this.actionUrl,
    this.relatedObjectType,
    this.relatedObjectId,
    required this.isRead,
    this.readAt,
    required this.pushSent,
    this.pushSentAt,
    this.expiresAt,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return NotificationModel(
      id: json['id'] ?? '',
      companyId: json['company_id'],
      recipientUserId: json['recipient_user_id'],
      recipientEmail: json['recipient_email'],
      notificationType: json['notification_type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      actionUrl: json['action_url'],
      relatedObjectType: json['related_object_type'],
      relatedObjectId: json['related_object_id'],
      isRead: json['is_read'] ?? false,
      readAt: parseDate(json['read_at']),
      pushSent: json['push_sent'] ?? false,
      pushSentAt: parseDate(json['push_sent_at']),
      expiresAt: parseDate(json['expires_at']),
      isActive: json['is_active'] ?? false,
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }
}
