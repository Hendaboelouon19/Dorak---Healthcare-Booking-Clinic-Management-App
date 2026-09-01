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
    this.timestamp,
    required this.type,
    required this.isUnread,
  });

  final String id;
  final String title;
  final String message;
  final DateTime? timestamp;
  final NotificationType type;
  final bool isUnread;
}
