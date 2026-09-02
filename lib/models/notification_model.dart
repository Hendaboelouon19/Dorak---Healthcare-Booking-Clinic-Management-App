enum NotificationType {
  bookingConfirmed,
  turnApproaching,
  doctorArrived,
  arrivalApproved,
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.timestamp,
    this.isUnread = true,
  });

  final String id;
  final String title;
  final String message;

  final DateTime? timestamp;

  final NotificationType type;

  final bool isUnread;

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isUnread,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}