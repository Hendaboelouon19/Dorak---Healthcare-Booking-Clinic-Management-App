import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/appointment_model.dart';
import '../../models/notification_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/notification_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

class NotificationsScreen
    extends StatelessWidget {
  const NotificationsScreen({
    super.key,
  });

  // ===========================================================
  // OPEN NOTIFICATION
  //
  // EVERY APPOINTMENT NOTIFICATION OPENS THE SAME
  // BOOKING DETAILS SCREEN.
  // ===========================================================

  Future<void> _openNotification(
    BuildContext context,
    NotificationModel notification,
  ) async {
    final notificationProvider =
        context.read<NotificationProvider>();

    final appointmentProvider =
        context.read<AppointmentProvider>();

    await notificationProvider.markAsRead(
      notification.id,
    );

    if (!context.mounted) {
      return;
    }

    if (notification.appointmentId.isEmpty) {
      return;
    }

    AppointmentModel? appointment;

    for (final item
        in appointmentProvider.realAppointments) {
      if (item.id ==
          notification.appointmentId) {
        appointment = item;
        break;
      }
    }

    if (appointment != null) {
      appointmentProvider.selectAppointment(
        appointment,
      );
    }

    Navigator.of(context).pushNamed(
      AppRoutes.appointmentHistory,
      arguments: {
        'bookingId':
            notification.appointmentId,
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final provider =
        context.watch<NotificationProvider>();

    final notifications =
        provider.notifications;

    final unreadCount =
        provider.unreadCount;

    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        backgroundColor:
            AppColors.background,
        elevation: 0,
        automaticallyImplyLeading:
            false,
        titleSpacing: 0,
        title: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pop();
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                    border: Border.all(
                      color:
                          AppColors.border,
                    ),
                  ),
                  child:
                      const Icon(
                    Icons
                        .arrow_back_ios_new_rounded,
                    color: AppColors
                        .textPrimary,
                    size: 18,
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              const Expanded(
                child: Text(
                  'Notifications',
                  style:
                      TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.w800,
                    color: AppColors
                        .textPrimary,
                    letterSpacing:
                        -0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          // ===================================================
          // HEADER
          // ===================================================

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
              decoration:
                  BoxDecoration(
                color:
                    Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                border: Border.all(
                  color:
                      AppColors.border,
                ),
                boxShadow:
                    const [
                  BoxShadow(
                    color:
                        Color(
                      0x0F102A43,
                    ),
                    blurRadius: 10,
                    offset:
                        Offset(
                      0,
                      4,
                    ),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration:
                        BoxDecoration(
                      color: AppColors
                          .primaryLight,
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child:
                        const Icon(
                      Icons
                          .notifications_none_rounded,
                      color: AppColors
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
                        const Text(
                          'Your inbox',
                          style:
                              TextStyle(
                            fontSize: 12,
                            color: AppColors
                                .textSecondary,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),

                        const SizedBox(
                          height: 2,
                        ),

                        Text(
                          '$unreadCount unread',
                          style:
                              const TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight
                                    .w800,
                            color: AppColors
                                .textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (unreadCount >
                      0)
                    TextButton(
                      onPressed:
                          () async {
                        await context
                            .read<
                                NotificationProvider>()
                            .markAllAsRead();
                      },
                      child:
                          const Text(
                        'Mark all read',
                        style:
                            TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          Expanded(
            child: _buildContent(
              context,
              provider,
              notifications,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // CONTENT
  // ===========================================================

  Widget _buildContent(
    BuildContext context,
    NotificationProvider provider,
    List<NotificationModel>
        notifications,
  ) {
    if (provider.isLoading &&
        notifications.isEmpty) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage != null &&
        notifications.isEmpty) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(
            24,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons
                    .error_outline_rounded,
                size: 44,
                color: AppColors
                    .textSecondary,
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                provider.errorMessage!,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color: AppColors
                      .textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (notifications.isEmpty) {
      return const Center(
        child: Padding(
          padding:
              EdgeInsets.all(
            24,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                Icons
                    .notifications_none_rounded,
                size: 54,
                color: AppColors
                    .textSecondary,
              ),

              SizedBox(
                height: 14,
              ),

              Text(
                'No notifications yet',
                style:
                    TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                  color: AppColors
                      .textPrimary,
                ),
              ),

              SizedBox(
                height: 6,
              ),

              Text(
                'Queue and appointment updates will appear here.',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  color: AppColors
                      .textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        24,
      ),
      itemCount:
          notifications.length,
      separatorBuilder:
          (_, _) =>
              const SizedBox(
        height: 12,
      ),
      itemBuilder:
          (context, index) {
        final item =
            notifications[index];

        return _NotificationCard(
          notification:
              item,
          onTap: () async {
            await _openNotification(
              context,
              item,
            );
          },
        );
      },
    );
  }
}

// ===============================================================
// NOTIFICATION CARD
// ===============================================================

class _NotificationCard
    extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    final accent =
        _accentForType(
      notification.type,
    );

    final icon =
        _iconForType(
      notification.type,
    );

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(
        18,
      ),
      child: Container(
        padding:
            const EdgeInsets.all(
          14,
        ),
        decoration:
            BoxDecoration(
          color:
              notification.isUnread
                  ? accent.withValues(
                      alpha: 0.06,
                    )
                  : AppColors.surface,
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          border: Border.all(
            color:
                notification.isUnread
                    ? accent.withValues(
                        alpha: 0.20,
                      )
                    : AppColors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration:
                  BoxDecoration(
                color:
                    notification
                            .isUnread
                        ? accent
                            .withValues(
                              alpha:
                                  0.12,
                            )
                        : AppColors
                            .primaryLight,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Icon(
                icon,
                color:
                    notification
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
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification
                              .title,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .w800,
                            fontSize: 15,
                            color: AppColors
                                .textPrimary,
                          ),
                        ),
                      ),

                      if (notification
                          .isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration:
                              const BoxDecoration(
                            color: AppColors
                                .primaryBlue,
                            shape:
                                BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    notification
                        .message,
                    style:
                        const TextStyle(
                      color: AppColors
                          .textSecondary,
                      height: 1.45,
                      fontSize: 13,
                    ),
                  ),

                  if (notification
                          .timestamp !=
                      null) ...[
                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      _formatTime(
                        notification
                            .timestamp!,
                      ),
                      style:
                          const TextStyle(
                        fontSize: 11,
                        color: AppColors
                            .textSecondary,
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            const Padding(
              padding:
                  EdgeInsets.only(
                top: 12,
              ),
              child: Icon(
                Icons
                    .chevron_right_rounded,
                size: 20,
                color: AppColors
                    .textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _accentForType(
    NotificationType type,
  ) {
    switch (type) {
      case NotificationType
          .bookingConfirmed:
        return AppColors
            .primaryBlue;

      case NotificationType
          .turnApproaching:
        return AppColors
            .warningAmber;

      case NotificationType
          .doctorArrived:
        return AppColors
            .successGreen;

      case NotificationType
          .arrivalApproved:
        return AppColors
            .primaryBlue;
    }
  }

  static IconData _iconForType(
    NotificationType type,
  ) {
    switch (type) {
      case NotificationType
          .bookingConfirmed:
        return Icons
            .calendar_today_rounded;

      case NotificationType
          .turnApproaching:
        return Icons
            .notifications_active_rounded;

      case NotificationType
          .doctorArrived:
        return Icons
            .local_hospital_rounded;

      case NotificationType
          .arrivalApproved:
        return Icons
            .check_circle_rounded;
    }
  }

  static String _formatTime(
    DateTime date,
  ) {
    final now =
        DateTime.now();

    final today =
        DateTime(
      now.year,
      now.month,
      now.day,
    );

    final notificationDay =
        DateTime(
      date.year,
      date.month,
      date.day,
    );

    if (notificationDay ==
        today) {
      return 'Today · '
          '${DateFormat('h:mm a').format(date)}';
    }

    final yesterday =
        today.subtract(
      const Duration(
        days: 1,
      ),
    );

    if (notificationDay ==
        yesterday) {
      return 'Yesterday · '
          '${DateFormat('h:mm a').format(date)}';
    }

    return DateFormat(
      'd MMM · h:mm a',
    ).format(
      date,
    );
  }
}