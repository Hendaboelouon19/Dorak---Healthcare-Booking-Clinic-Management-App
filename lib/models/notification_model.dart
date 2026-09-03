import 'package:cloud_firestore/cloud_firestore.dart';

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
    this.appointmentId = '',
  });

  final String id;
  final String title;
  final String message;

  final NotificationType type;

  final DateTime? timestamp;

  final bool isUnread;

  final String appointmentId;

  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw StateError(
        'Notification ${document.id} contains no data.',
      );
    }

    final createdAtValue = data['createdAt'];

    final isRead =
        data['isRead'] as bool? ?? false;

    return NotificationModel(
      id: document.id,

      title:
          data['title'] as String? ??
          'Notification',

      message:
          data['message'] as String? ??
          '',

      type: _typeFromString(
        data['type'] as String? ??
            'bookingConfirmed',
      ),

      timestamp:
          createdAtValue is Timestamp
              ? createdAtValue.toDate()
              : null,

      isUnread: !isRead,

      appointmentId:
          data['appointmentId']
                  as String? ??
              '',
    );
  }

  static NotificationType _typeFromString(
    String value,
  ) {
    switch (value.trim()) {
      case 'arrivalApproved':
        return NotificationType
            .arrivalApproved;

      case 'turnApproaching':
        return NotificationType
            .turnApproaching;

      case 'doctorArrived':
        return NotificationType
            .doctorArrived;

      case 'bookingConfirmed':
      default:
        return NotificationType
            .bookingConfirmed;
    }
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isUnread,
    String? appointmentId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isUnread:
          isUnread ?? this.isUnread,
      appointmentId:
          appointmentId ??
          this.appointmentId,
    );
  }
}