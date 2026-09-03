import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';

class NotificationProvider
    extends ChangeNotifier {
  NotificationProvider() {
    _authSubscription =
        _auth.authStateChanges().listen(
      _handleAuthStateChanged,
    );
  }

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final List<NotificationModel>
      _notifications = [];

  StreamSubscription<User?>?
      _authSubscription;

  StreamSubscription<
      QuerySnapshot<
          Map<String, dynamic>>>?
      _notificationSubscription;

  bool _isLoading = false;

  String? _errorMessage;

  String? _listeningUserId;

  // ===========================================================
  // GETTERS
  // ===========================================================

  List<NotificationModel>
      get notifications =>
          List.unmodifiable(
            _notifications,
          );

  int get unreadCount =>
      _notifications
          .where(
            (notification) =>
                notification.isUnread,
          )
          .length;

  bool get isLoading =>
      _isLoading;

  String? get errorMessage =>
      _errorMessage;

  // ===========================================================
  // AUTH
  // ===========================================================

  void _handleAuthStateChanged(
    User? user,
  ) {
    unawaited(
      _listenForUser(user),
    );
  }

  // ===========================================================
  // REALTIME FIRESTORE LISTENER
  // ===========================================================

  Future<void> _listenForUser(
    User? user,
  ) async {
    if (user == null) {
      await _notificationSubscription
          ?.cancel();

      _notificationSubscription =
          null;

      _listeningUserId = null;

      _notifications.clear();

      _isLoading = false;

      _errorMessage = null;

      notifyListeners();

      return;
    }

    if (_notificationSubscription !=
            null &&
        _listeningUserId == user.uid) {
      return;
    }

    await _notificationSubscription
        ?.cancel();

    _notificationSubscription =
        null;

    _listeningUserId =
        user.uid;

    _isLoading = true;

    _errorMessage = null;

    notifyListeners();

    _notificationSubscription =
        _firestore
            .collection('users')
            .doc(user.uid)
            .collection(
              'notifications',
            )
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots()
            .listen(
      (snapshot) {
        final loadedNotifications =
            <NotificationModel>[];

        for (final document
            in snapshot.docs) {
          try {
            loadedNotifications.add(
              NotificationModel
                  .fromFirestore(
                document,
              ),
            );
          } catch (error) {
            debugPrint(
              'Invalid notification '
              '${document.id}: $error',
            );
          }
        }

        _notifications
          ..clear()
          ..addAll(
            loadedNotifications,
          );

        _isLoading = false;

        _errorMessage = null;

        debugPrint(
          'Realtime notifications: '
          '${_notifications.length}, '
          'unread: $unreadCount',
        );

        notifyListeners();
      },
      onError: (Object error) {
        debugPrint(
          'Notification listener error: '
          '$error',
        );

        _isLoading = false;

        _errorMessage =
            'Could not load notifications.';

        notifyListeners();
      },
    );
  }

  // ===========================================================
  // MARK ONE AS READ
  // ===========================================================

  Future<void> markAsRead(
    String notificationId,
  ) async {
    final user =
        _auth.currentUser;

    if (user == null) {
      return;
    }

    NotificationModel?
        notification;

    for (final item
        in _notifications) {
      if (item.id ==
          notificationId) {
        notification = item;

        break;
      }
    }

    if (notification == null ||
        !notification.isUnread) {
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection(
            'notifications',
          )
          .doc(notificationId)
          .update({
        'isRead': true,
        'readAt':
            FieldValue
                .serverTimestamp(),
      });

      // No local manual edit is required.
      // Firestore realtime listener will
      // immediately update the UI.
    } on FirebaseException catch (e) {
      debugPrint(
        'Mark notification read error: '
        '${e.code} - ${e.message}',
      );

      _errorMessage =
          'Could not update notification.';

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Mark notification read error: $e',
      );

      _errorMessage =
          'Could not update notification.';

      notifyListeners();
    }
  }

  // ===========================================================
  // MARK ALL AS READ
  // ===========================================================

  Future<void> markAllAsRead() async {
    final user =
        _auth.currentUser;

    if (user == null) {
      return;
    }

    final unreadNotifications =
        _notifications
            .where(
              (notification) =>
                  notification
                      .isUnread,
            )
            .toList();

    if (unreadNotifications
        .isEmpty) {
      return;
    }

    try {
      final batch =
          _firestore.batch();

      for (final notification
          in unreadNotifications) {
        final reference =
            _firestore
                .collection('users')
                .doc(user.uid)
                .collection(
                  'notifications',
                )
                .doc(
                  notification.id,
                );

        batch.update(
          reference,
          {
            'isRead': true,
            'readAt':
                FieldValue
                    .serverTimestamp(),
          },
        );
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      debugPrint(
        'Mark all read error: '
        '${e.code} - ${e.message}',
      );

      _errorMessage =
          'Could not update notifications.';

      notifyListeners();
    }
  }

  // ===========================================================
  // DISPOSE
  // ===========================================================

  @override
  void dispose() {
    _notificationSubscription
        ?.cancel();

    _authSubscription?.cancel();

    super.dispose();
  }
}