import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications =
        context.watch<NotificationProvider>().notifications;

    final unreadCount =
        context.watch<NotificationProvider>().unreadCount;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).pop(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary,
                    size: 18,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          // =====================================================
          // HEADER
          // =====================================================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              16,
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.border,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F102A43),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color:
                          AppColors.primaryLight,
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: const Icon(
                      Icons
                          .notifications_none_rounded,
                      color:
                          AppColors.primaryBlue,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your inbox',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors
                                .textSecondary,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        Text(
                          '$unreadCount unread',
                          style:
                              const TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w800,
                            color: AppColors
                                .textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          AppColors.primaryLight,
                      borderRadius:
                          BorderRadius.circular(
                        999,
                      ),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                        color:
                            AppColors.primaryBlue,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =====================================================
          // NOTIFICATIONS
          // =====================================================

          Expanded(
            child: notifications.isEmpty
                ? const Center(
                    child: Text(
                      'No notifications yet.',
                      style: TextStyle(
                        color: AppColors
                            .textSecondary,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      24,
                    ),
                    itemCount:
                        notifications.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(
                      height: 12,
                    ),
                    itemBuilder:
                        (context, index) {
                      final item =
                          notifications[index];

                      final Color accent;

                      switch (item.type) {
                        case NotificationType
                              .bookingConfirmed:
                          accent = AppColors
                              .primaryBlue;
                          break;

                        case NotificationType
                              .turnApproaching:
                          accent = AppColors
                              .warningAmber;
                          break;

                        case NotificationType
                              .doctorArrived:
                          accent = AppColors
                              .successGreen;
                          break;

                        case NotificationType
                              .arrivalApproved:
                          accent = AppColors
                              .primaryBlue;
                          break;
                      }

                      return GestureDetector(
                        onTap: () {
                          context
                              .read<
                                  NotificationProvider>()
                              .markAsRead(
                                item.id,
                              );
                        },
                        child: Container(
                          padding:
                              const EdgeInsets
                                  .all(14),
                          decoration:
                              BoxDecoration(
                            color: item.isUnread
                                ? accent
                                    .withValues(
                                    alpha:
                                        0.06,
                                  )
                                : AppColors
                                    .surface,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              18,
                            ),
                            border:
                                Border.all(
                              color: item
                                      .isUnread
                                  ? accent
                                      .withValues(
                                      alpha:
                                          0.20,
                                    )
                                  : AppColors
                                      .border,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration:
                                    BoxDecoration(
                                  color: item
                                          .isUnread
                                      ? accent
                                          .withValues(
                                          alpha:
                                              0.12,
                                        )
                                      : AppColors
                                          .primaryLight,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    12,
                                  ),
                                ),
                                child: Icon(
                                  _iconForType(
                                    item.type,
                                  ),
                                  color: item
                                          .isUnread
                                      ? accent
                                      : AppColors
                                          .primaryBlue,
                                ),
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style:
                                                const TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .w800,
                                              fontSize:
                                                  15,
                                              color: AppColors
                                                  .textPrimary,
                                            ),
                                          ),
                                        ),

                                        if (item
                                            .isUnread)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration:
                                                const BoxDecoration(
                                              color: AppColors
                                                  .primaryBlue,
                                              shape: BoxShape
                                                  .circle,
                                            ),
                                          ),
                                      ],
                                    ),

                                    const SizedBox(
                                      height: 6,
                                    ),

                                    Text(
                                      item.message,
                                      style:
                                          const TextStyle(
                                        color: AppColors
                                            .textSecondary,
                                        height: 1.45,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static IconData _iconForType(
    NotificationType type,
  ) {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return Icons.calendar_today_rounded;

      case NotificationType.turnApproaching:
        return Icons.notifications_active_rounded;

      case NotificationType.doctorArrived:
        return Icons.local_hospital_rounded;

      case NotificationType.arrivalApproved:
        return Icons.check_circle_rounded;
    }
  }
}