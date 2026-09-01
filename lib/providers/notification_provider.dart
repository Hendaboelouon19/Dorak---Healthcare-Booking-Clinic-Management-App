import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import 'mock_data.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider() {
    _notifications = List<NotificationModel>.from(MockData.notifications);
  }

  late List<NotificationModel> _notifications;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((item) => item.isUnread).length;

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((item) => item.id == notificationId);
    if (index == -1) return;

    final item = _notifications[index];
    _notifications[index] = NotificationModel(
      id: item.id,
      title: item.title,
      message: item.message,
      timestamp: item.timestamp,
      type: item.type,
      isUnread: false,
    );
    notifyListeners();
  }

  void markAllAsRead() {
    _notifications = _notifications
        .map((item) => NotificationModel(
              id: item.id,
              title: item.title,
              message: item.message,
              timestamp: item.timestamp,
              type: item.type,
              isUnread: false,
            ))
        .toList();
    notifyListeners();
  }
}
