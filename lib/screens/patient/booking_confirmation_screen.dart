import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/appointment_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

class BookingConfirmationScreen
    extends StatelessWidget {
  const BookingConfirmationScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appointment =
        context
            .watch<AppointmentProvider>()
            .selectedAppointment;

    if (appointment == null) {
      return Scaffold(
        backgroundColor:
            AppColors.background,
        body: SafeArea(
          child: Center(
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
                    size: 56,
                    color: AppColors
                        .textSecondary,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const Text(
                    'Appointment information is unavailable.',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w700,
                      color: AppColors
                          .textPrimary,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  FilledButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(
                        AppRoutes
                            .patientHome,
                        (route) =>
                            false,
                      );
                    },
                    child: const Text(
                      'Back to Home',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final formattedDate =
        DateFormat(
      'EEEE, d MMMM yyyy',
    ).format(
      appointment.date,
    );

    return Scaffold(
      backgroundColor:
          AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            30,
            20,
            32,
          ),
          child: Column(
            children: [
              // ==================================================
              // SUCCESS
              // ==================================================

              Container(
                width: 86,
                height: 86,
                decoration:
                    BoxDecoration(
                  color: AppColors
                      .successGreen
                      .withValues(
                    alpha: 0.12,
                  ),
                  shape:
                      BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .check_circle_rounded,
                  size: 56,
                  color:
                      AppColors.successGreen,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                'Appointment Booked!',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      AppColors.textPrimary,
                  letterSpacing:
                      -0.8,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                'Your appointment has been reserved successfully.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors
                      .textSecondary,
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ==================================================
              // APPOINTMENT CARD
              // ==================================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  18,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),
                  border: Border.all(
                    color:
                        AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration:
                              BoxDecoration(
                            color: AppColors
                                .primaryLight,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),
                          child: const Icon(
                            Icons
                                .local_hospital_rounded,
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
                              Text(
                                appointment
                                    .clinicName,
                                style:
                                    const TextStyle(
                                  fontSize:
                                      18,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                  color: AppColors
                                      .textPrimary,
                                ),
                              ),

                              const SizedBox(
                                height: 3,
                              ),

                              Text(
                                appointment
                                        .doctorSpecialty
                                        .isEmpty
                                    ? appointment
                                        .doctorName
                                    : '${appointment.doctorName} · ${appointment.doctorSpecialty}',
                                style:
                                    const TextStyle(
                                  color: AppColors
                                      .textSecondary,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    const Divider(
                      color:
                          AppColors.border,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    _ConfirmationRow(
                      icon: Icons
                          .calendar_today_rounded,
                      label: 'Date',
                      value:
                          formattedDate,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    _ConfirmationRow(
                      icon: Icons
                          .access_time_rounded,
                      label: 'Time',
                      value: appointment
                          .timeWindow,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    _ConfirmationRow(
                      icon: Icons
                          .location_on_rounded,
                      label: 'Room',
                      value: appointment
                              .room
                              .isEmpty
                          ? 'Not specified'
                          : appointment
                              .room,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    _ConfirmationRow(
                      icon: Icons
                          .confirmation_number_outlined,
                      label:
                          'Booking ID',
                      value: appointment
                          .id,
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // QUEUE EXPLANATION
              // ==================================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                decoration:
                    BoxDecoration(
                  color: AppColors
                      .primaryBlue
                      .withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Icon(
                      Icons
                          .info_outline_rounded,
                      color: AppColors
                          .primaryBlue,
                    ),

                    SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Text(
                        'Your appointment is booked. When you arrive at the clinic, the assistant will approve your arrival and add you to the live queue.',
                        style: TextStyle(
                          height: 1.45,
                          color: AppColors
                              .textPrimary,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ==================================================
              // APPOINTMENTS
              // ==================================================

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(
                      AppRoutes
                          .appointmentHistory,
                      (route) =>
                          route.settings
                              .name ==
                          AppRoutes
                              .patientHome,
                    );
                  },
                  style:
                      FilledButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryBlue,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 16,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                  child: const Text(
                    'View My Appointments',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // ==================================================
              // HOME
              // ==================================================

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(
                      AppRoutes.patientHome,
                      (route) =>
                          false,
                    );
                  },
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        AppColors
                            .primaryBlue,
                    side: const BorderSide(
                      color:
                          AppColors.border,
                    ),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 16,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// DETAIL ROW
// ================================================================

class _ConfirmationRow
    extends StatelessWidget {
  const _ConfirmationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration:
              BoxDecoration(
            color:
                AppColors.primaryLight,
            borderRadius:
                BorderRadius.circular(
              11,
            ),
          ),
          child: Icon(
            icon,
            size: 19,
            color:
                AppColors.primaryBlue,
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
              Text(
                label,
                style:
                    const TextStyle(
                  fontSize: 11,
                  color: AppColors
                      .textSecondary,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                value,
                style:
                    const TextStyle(
                  fontSize: 14,
                  color: AppColors
                      .textPrimary,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}