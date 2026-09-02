import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/doctor_slot_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/clinic_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState
    extends State<BookAppointmentScreen> {
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<ClinicProvider>().fetchSlots();
    });
  }

  bool _isSameDay(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  List<DateTime> _availableDays(
    List<DoctorSlotModel> slots,
  ) {
    final days = <DateTime>[];

    for (final slot in slots) {
      final day = DateTime(
        slot.startAt.year,
        slot.startAt.month,
        slot.startAt.day,
      );

      final exists = days.any(
        (existingDay) =>
            _isSameDay(existingDay, day),
      );

      if (!exists) {
        days.add(day);
      }
    }

    days.sort();

    return days;
  }

  String _formatTime(
    DoctorSlotModel slot,
  ) {
    return DateFormat('h:mm a').format(
      slot.startAt,
    );
  }

  String _formatRange(
    DoctorSlotModel slot,
  ) {
    final start =
        DateFormat('h:mm a').format(
      slot.startAt,
    );

    final end =
        DateFormat('h:mm a').format(
      slot.endAt,
    );

    return '$start - $end';
  }

  Future<void> _confirmBooking({
    required ClinicProvider clinicProvider,
    required AppointmentProvider appointmentProvider,
  }) async {
    final clinic =
        clinicProvider.selectedClinic;

    final doctor =
        clinicProvider.selectedDoctor;

    final slot =
        clinicProvider.selectedSlot;

    if (clinic == null ||
        doctor == null ||
        slot == null) {
      return;
    }

    final success =
        await appointmentProvider.bookAppointment(
      clinicId: clinic.id,
      clinicName: clinic.name,
      doctorId: doctor.id,
      doctorName: doctor.name,
      doctorSpecialty: doctor.specialty,
      room: doctor.room,
      slotId: slot.id,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context)
          .pushReplacementNamed(
        AppRoutes.bookingConfirmation,
      );

      return;
    }

    // The slot may have been taken by another patient,
    // so refresh available slots.
    await clinicProvider.fetchSlots();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          appointmentProvider.errorMessage ??
              'Could not book appointment.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clinicProvider =
        context.watch<ClinicProvider>();

    final appointmentProvider =
        context.watch<AppointmentProvider>();

    final clinic =
        clinicProvider.selectedClinic;

    final doctor =
        clinicProvider.selectedDoctor;

    if (clinic == null ||
        doctor == null) {
      return Scaffold(
        backgroundColor:
            AppColors.background,
        appBar: AppBar(
          backgroundColor:
              AppColors.background,
          elevation: 0,
          title: const Text(
            'Book Appointment',
          ),
        ),
        body: Center(
          child: Padding(
            padding:
                const EdgeInsets.all(24),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Icon(
                  Icons
                      .calendar_month_outlined,
                  size: 56,
                  color:
                      AppColors.textSecondary,
                ),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'Please choose a clinic and doctor first.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop();
                  },
                  child:
                      const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final days =
        _availableDays(
      clinicProvider.slots,
    );

    final selectedDay =
        _selectedDay ??
            (days.isNotEmpty
                ? days.first
                : null);

    final visibleSlots =
        selectedDay == null
            ? <DoctorSlotModel>[]
            : clinicProvider.slots
                .where(
                  (slot) => _isSameDay(
                    slot.startAt,
                    selectedDay,
                  ),
                )
                .toList();

    final selectedSlot =
        clinicProvider.selectedSlot;

    final selectedSlotVisible =
        selectedSlot != null &&
            selectedDay != null &&
            _isSameDay(
              selectedSlot.startAt,
              selectedDay,
            );

    return Scaffold(
      backgroundColor:
          AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            32,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Row(
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
                            BorderRadius
                                .circular(14),
                        border: Border.all(
                          color:
                              AppColors.border,
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  const Expanded(
                    child: Text(
                      'Book Appointment',
                      style: TextStyle(
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

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // DOCTOR
              // ==================================================

              Container(
                padding:
                    const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          AppColors
                              .primaryLight,
                      backgroundImage:
                          doctor.imageUrl
                                  .isNotEmpty
                              ? NetworkImage(
                                  doctor
                                      .imageUrl,
                                )
                              : null,
                      child: doctor
                              .imageUrl.isEmpty
                          ? const Icon(
                              Icons
                                  .person_rounded,
                              size: 34,
                              color: AppColors
                                  .primaryBlue,
                            )
                          : null,
                    ),

                    const SizedBox(
                      width: 14,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            doctor.name,
                            style:
                                const TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              color: AppColors
                                  .textPrimary,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            doctor.specialty,
                            style:
                                const TextStyle(
                              color: AppColors
                                  .textSecondary,
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),

                          if (doctor
                              .qualification
                              .isNotEmpty) ...[
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              doctor
                                  .qualification,
                              style:
                                  const TextStyle(
                                fontSize: 12,
                                color: AppColors
                                    .textSecondary,
                              ),
                            ),
                          ],

                          const SizedBox(
                            height: 8,
                          ),

                          Row(
                            children: [
                              const Icon(
                                Icons
                                    .location_on_rounded,
                                size: 14,
                                color: AppColors
                                    .primaryBlue,
                              ),

                              const SizedBox(
                                width: 4,
                              ),

                              Expanded(
                                child: Text(
                                  doctor.room
                                          .isEmpty
                                      ? clinic
                                          .name
                                      : '${clinic.name} · ${doctor.room}',
                                  style:
                                      const TextStyle(
                                    fontSize: 12,
                                    color: AppColors
                                        .textSecondary,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ==================================================
              // DATE + TIME
              // ==================================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(18),
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
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date & Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w800,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    if (clinicProvider
                        .isLoadingSlots)
                      const Padding(
                        padding:
                            EdgeInsets.all(
                          28,
                        ),
                        child: Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      )
                    else if (clinicProvider
                            .slotErrorMessage !=
                        null)
                      _SlotError(
                        message:
                            clinicProvider
                                .slotErrorMessage!,
                        onRetry: () {
                          clinicProvider
                              .fetchSlots();
                        },
                      )
                    else if (clinicProvider
                        .slots.isEmpty)
                      const _NoSlots()
                    else ...[
                      // ==========================================
                      // DATE
                      // ==========================================

                      const Text(
                        'Select a Date',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors
                              .textSecondary,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      SizedBox(
                        height: 118,
                        child:
                            ListView.separated(
                          scrollDirection:
                              Axis.horizontal,
                          itemCount:
                              days.length,
                          separatorBuilder:
                              (_, _) =>
                                  const SizedBox(
                            width: 10,
                          ),
                          itemBuilder:
                              (
                            context,
                            index,
                          ) {
                            final day =
                                days[index];

                            final isSelected =
                                selectedDay !=
                                        null &&
                                    _isSameDay(
                                      day,
                                      selectedDay,
                                    );

                            return GestureDetector(
                              onTap: () {
                                setState(
                                  () {
                                    _selectedDay =
                                        day;
                                  },
                                );
                              },
                              child:
                                  AnimatedContainer(
                                duration:
                                    const Duration(
                                  milliseconds:
                                      180,
                                ),
                                width: 82,
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  vertical: 12,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: isSelected
                                      ? AppColors
                                          .primaryBlue
                                      : AppColors
                                          .surface,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    18,
                                  ),
                                  border:
                                      Border.all(
                                    color: isSelected
                                        ? AppColors
                                            .primaryBlue
                                        : AppColors
                                            .border,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Text(
                                      DateFormat(
                                        'EEE',
                                      ).format(
                                        day,
                                      ),
                                      style:
                                          TextStyle(
                                        fontSize:
                                            12,
                                        color: isSelected
                                            ? Colors
                                                .white
                                            : AppColors
                                                .textSecondary,
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 5,
                                    ),

                                    Text(
                                      DateFormat(
                                        'd',
                                      ).format(
                                        day,
                                      ),
                                      style:
                                          TextStyle(
                                        fontSize:
                                            26,
                                        color: isSelected
                                            ? Colors
                                                .white
                                            : AppColors
                                                .textPrimary,
                                        fontWeight:
                                            FontWeight
                                                .w800,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 2,
                                    ),

                                    Text(
                                      DateFormat(
                                        'MMM',
                                      ).format(
                                        day,
                                      ),
                                      style:
                                          TextStyle(
                                        fontSize:
                                            11,
                                        color: isSelected
                                            ? Colors
                                                .white70
                                            : AppColors
                                                .textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // ==========================================
                      // TIME
                      // ==========================================

                      const Text(
                        'Select a Time',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors
                              .textSecondary,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      if (visibleSlots
                          .isEmpty)
                        const Padding(
                          padding:
                              EdgeInsets
                                  .symmetric(
                            vertical: 20,
                          ),
                          child: Center(
                            child: Text(
                              'No available times on this date.',
                              style:
                                  TextStyle(
                                color: AppColors
                                    .textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          itemCount:
                              visibleSlots
                                  .length,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                3,
                            mainAxisSpacing:
                                10,
                            crossAxisSpacing:
                                10,
                            childAspectRatio:
                                2.15,
                          ),
                          itemBuilder:
                              (
                            context,
                            index,
                          ) {
                            final slot =
                                visibleSlots[
                                    index];

                            final isSelected =
                                selectedSlot
                                        ?.id ==
                                    slot.id;

                            return GestureDetector(
                              onTap: () {
                                context
                                    .read<
                                        ClinicProvider>()
                                    .selectSlot(
                                      slot,
                                    );
                              },
                              child:
                                  AnimatedContainer(
                                duration:
                                    const Duration(
                                  milliseconds:
                                      180,
                                ),
                                alignment:
                                    Alignment
                                        .center,
                                decoration:
                                    BoxDecoration(
                                  color: isSelected
                                      ? AppColors
                                          .primaryLight
                                      : AppColors
                                          .surface,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    14,
                                  ),
                                  border:
                                      Border.all(
                                    color: isSelected
                                        ? AppColors
                                            .primaryBlue
                                        : AppColors
                                            .border,
                                    width: isSelected
                                        ? 1.5
                                        : 1,
                                  ),
                                ),
                                child: Text(
                                  _formatTime(
                                    slot,
                                  ),
                                  style:
                                      TextStyle(
                                    color: isSelected
                                        ? AppColors
                                            .primaryBlue
                                        : AppColors
                                            .textPrimary,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                    fontSize:
                                        12,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ],
                ),
              ),

              // ==================================================
              // SELECTION SUMMARY
              // ==================================================

              if (selectedSlotVisible) ...[
                const SizedBox(
                  height: 18,
                ),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  decoration:
                      BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        AppColors
                            .primaryBlue,
                        AppColors
                            .primaryBlueDark,
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons
                            .calendar_today_rounded,
                        color:
                            Colors.white,
                        size: 18,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Text(
                          '${DateFormat('EEE, d MMM').format(selectedSlot.startAt)} · ${_formatRange(selectedSlot)}',
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 14,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons
                            .check_circle_rounded,
                        color:
                            Colors.white,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // CONFIRM
              // ==================================================

              SizedBox(
                width:
                    double.infinity,
                child: FilledButton(
                  onPressed:
    !selectedSlotVisible ||
            appointmentProvider.isBooking
        ? null
        : () {
                              _confirmBooking(
                                clinicProvider:
                                    context.read<
                                        ClinicProvider>(),
                                appointmentProvider:
                                    context.read<
                                        AppointmentProvider>(),
                              );
                            },

                  style:
                      FilledButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryBlue,
                    disabledBackgroundColor:
                        AppColors.primaryBlue
                            .withValues(
                      alpha: 0.35,
                    ),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 17,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),

                  child: appointmentProvider
                          .isBooking
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Text(
                          'Confirm Booking',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .w700,
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
// ERROR
// ================================================================

class _SlotError extends StatelessWidget {
  const _SlotError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 24,
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 42,
              color:
                  AppColors.textSecondary,
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              message,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color:
                    AppColors.textSecondary,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Try again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// EMPTY
// ================================================================

class _NoSlots extends StatelessWidget {
  const _NoSlots();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding:
          EdgeInsets.symmetric(
        vertical: 30,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 46,
              color:
                  AppColors.textSecondary,
            ),

            SizedBox(
              height: 12,
            ),

            Text(
              'No available appointments for this doctor.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    AppColors.textSecondary,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}