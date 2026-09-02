import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

class AppointmentHistoryScreen
    extends StatefulWidget {
  const AppointmentHistoryScreen({
    super.key,
  });

  @override
  State<AppointmentHistoryScreen>
      createState() =>
          _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState
    extends State<AppointmentHistoryScreen> {
  bool _showHistory = false;

  String? _selectedAppointmentId;

  bool _handledRouteArguments =
      false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context
          .read<AppointmentProvider>()
          .fetchAppointments();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_handledRouteArguments) {
      return;
    }

    _handledRouteArguments = true;

    final args =
        ModalRoute.of(context)
            ?.settings
            .arguments;

    if (args
        is Map<String, dynamic>) {
      _selectedAppointmentId =
          args['bookingId']
              as String?;
    }
  }

  List<AppointmentModel>
      _upcomingAppointments(
    List<AppointmentModel>
        appointments,
  ) {
    final result = appointments
        .where(
          (appointment) =>
              appointment.status !=
                  AppointmentStatus
                      .completed &&
              appointment.status !=
                  AppointmentStatus
                      .noShow,
        )
        .toList();

    result.sort(
      (a, b) =>
          a.date.compareTo(b.date),
    );

    return result;
  }

  List<AppointmentModel>
      _historyAppointments(
    List<AppointmentModel>
        appointments,
  ) {
    final result = appointments
        .where(
          (appointment) =>
              appointment.status ==
                  AppointmentStatus
                      .completed ||
              appointment.status ==
                  AppointmentStatus
                      .noShow,
        )
        .toList();

    result.sort(
      (a, b) =>
          b.date.compareTo(a.date),
    );

    return result;
  }

  AppointmentModel?
      _findSelectedAppointment(
    List<AppointmentModel>
        appointments,
  ) {
    final id =
        _selectedAppointmentId;

    if (id == null) {
      return null;
    }

    for (final appointment
        in appointments) {
      if (appointment.id == id) {
        return appointment;
      }
    }

    return null;
  }

  void _goBack() {
    if (_selectedAppointmentId !=
        null) {
      setState(() {
        _selectedAppointmentId =
            null;
      });

      return;
    }

    if (Navigator.of(context)
        .canPop()) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context)
        .pushNamedAndRemoveUntil(
      AppRoutes.patientHome,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<
            AppointmentProvider>();

    final appointments =
        provider.realAppointments;

    final selected =
        _findSelectedAppointment(
      appointments,
    );

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
            horizontal: 16,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _goBack,
                icon: const Icon(
                  Icons
                      .arrow_back_ios_new_rounded,
                ),
              ),

              Expanded(
                child: Text(
                  selected == null
                      ? 'My Appointments'
                      : 'Appointment Details',
                  style:
                      const TextStyle(
                    fontSize: 25,
                    fontWeight:
                        FontWeight.w800,
                    color: AppColors
                        .textPrimary,
                  ),
                ),
              ),

              if (selected == null)
                IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(
                      AppRoutes
                          .patientNotifications,
                    );
                  },
                  icon: const Icon(
                    Icons
                        .notifications_none_rounded,
                  ),
                ),
            ],
          ),
        ),
      ),

      body: selected != null
          ? _AppointmentDetails(
              appointment:
                  selected,
            )
          : _buildAppointments(
              provider,
              appointments,
            ),
    );
  }

  Widget _buildAppointments(
    AppointmentProvider provider,
    List<AppointmentModel>
        appointments,
  ) {
    if (provider
        .isLoadingAppointments) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (provider
            .appointmentsErrorMessage !=
        null) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons
                    .error_outline_rounded,
                size: 48,
                color: AppColors
                    .textSecondary,
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                provider
                    .appointmentsErrorMessage!,
                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(
                height: 12,
              ),

              FilledButton(
                onPressed:
                    provider
                        .fetchAppointments,
                child:
                    const Text(
                  'Try again',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final visibleAppointments =
        _showHistory
            ? _historyAppointments(
                appointments,
              )
            : _upcomingAppointments(
                appointments,
              );

    return RefreshIndicator(
      onRefresh:
          provider.fetchAppointments,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          28,
        ),
        children: [
          // =================================================
          // TABS
          // =================================================

          Container(
            padding:
                const EdgeInsets.all(5),
            decoration:
                BoxDecoration(
              color:
                  AppColors.surface,
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
              border: Border.all(
                color:
                    AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label:
                        'Upcoming',
                    selected:
                        !_showHistory,
                    onTap: () {
                      setState(() {
                        _showHistory =
                            false;
                      });
                    },
                  ),
                ),

                Expanded(
                  child: _TabButton(
                    label:
                        'History',
                    selected:
                        _showHistory,
                    onTap: () {
                      setState(() {
                        _showHistory =
                            true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          if (visibleAppointments
              .isEmpty)
            _EmptyAppointments(
              history:
                  _showHistory,
            )
          else
            ...visibleAppointments.map(
              (appointment) =>
                  Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 14,
                ),
                child:
                    _AppointmentCard(
                  appointment:
                      appointment,
                  onTap: () {
                    setState(() {
                      _selectedAppointmentId =
                          appointment
                              .id;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ===============================================================
// TAB
// ===============================================================

class _TabButton
    extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 180,
        ),
        padding:
            const EdgeInsets.symmetric(
          vertical: 13,
        ),
        decoration:
            BoxDecoration(
          color: selected
              ? AppColors
                  .primaryBlue
              : Colors
                  .transparent,
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
        alignment:
            Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : AppColors
                    .textSecondary,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// APPOINTMENT CARD
// ===============================================================

class _AppointmentCard
    extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.onTap,
  });

  final AppointmentModel
      appointment;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final month =
        DateFormat('MMM')
            .format(
      appointment.date,
    )
            .toUpperCase();

    final day =
        DateFormat('d').format(
      appointment.date,
    );

    final year =
        DateFormat('yyyy').format(
      appointment.date,
    );

    return Material(
      color:
          AppColors.surface,
      borderRadius:
          BorderRadius.circular(
        20,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        child: Container(
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            border: Border.all(
              color:
                  AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        appointment
                            .clinicName,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize:
                              17,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        appointment
                            .doctorName,
                        style:
                            const TextStyle(
                          color: AppColors
                              .textSecondary,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      Row(
                        children: [
                          const Icon(
                            Icons
                                .access_time_rounded,
                            size: 16,
                            color: AppColors
                                .primaryBlue,
                          ),

                          const SizedBox(
                            width: 5,
                          ),

                          Expanded(
                            child: Text(
                              appointment
                                  .timeWindow,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _StatusBadge(
                        status:
                            appointment
                                .status,
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                width: 92,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 18,
                ),
                decoration:
                    const BoxDecoration(
                  color: AppColors
                      .primaryLight,
                  borderRadius:
                      BorderRadius.only(
                    topRight:
                        Radius.circular(
                      20,
                    ),
                    bottomRight:
                        Radius.circular(
                      20,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      month,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),

                    Text(
                      day,
                      style:
                          const TextStyle(
                        fontSize: 32,
                        color: AppColors
                            .primaryBlue,
                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),

                    Text(
                      year,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// DETAILS
// ===============================================================

class _AppointmentDetails
    extends StatelessWidget {
  const _AppointmentDetails({
    required this.appointment,
  });

  final AppointmentModel
      appointment;

  @override
  Widget build(BuildContext context) {
    final date =
        DateFormat(
      'EEEE, d MMMM yyyy',
    ).format(
      appointment.date,
    );

    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        30,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width:
                double.infinity,
            padding:
                const EdgeInsets.all(
              20,
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
                22,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                const Text(
                  'Patient',
                  style:
                      TextStyle(
                    color:
                        Colors.white70,
                    fontSize:
                        12,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  appointment
                      .patientName,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize:
                        21,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                const Text(
                  'Booking ID',
                  style:
                      TextStyle(
                    color:
                        Colors.white70,
                    fontSize:
                        12,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                SelectableText(
                  appointment.id,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          _DetailsCard(
            children: [
              _DetailRow(
                icon: Icons
                    .local_hospital_rounded,
                title:
                    'Clinic',
                value:
                    appointment
                        .clinicName,
              ),

              _DetailRow(
                icon: Icons
                    .person_rounded,
                title:
                    'Doctor',
                value:
                    appointment
                        .doctorName,
              ),

              _DetailRow(
                icon: Icons
                    .medical_services_rounded,
                title:
                    'Specialty',
                value: appointment
                        .doctorSpecialty
                        .isEmpty
                    ? 'Not specified'
                    : appointment
                        .doctorSpecialty,
              ),

              _DetailRow(
                icon: Icons
                    .calendar_today_rounded,
                title:
                    'Date',
                value:
                    date,
              ),

              _DetailRow(
                icon: Icons
                    .access_time_rounded,
                title:
                    'Time',
                value:
                    appointment
                        .timeWindow,
              ),

              _DetailRow(
                icon: Icons
                    .meeting_room_rounded,
                title:
                    'Room',
                value: appointment
                        .room
                        .isEmpty
                    ? 'Not specified'
                    : appointment
                        .room,
              ),

              _DetailRow(
                icon: Icons
                    .confirmation_number_outlined,
                title:
                    'Queue',
                value: appointment
                            .queueNumber >
                        0
                    ? '#${appointment.queueNumber}'
                    : 'Not in queue yet',
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          Container(
            width:
                double.infinity,
            padding:
                const EdgeInsets.all(
              16,
            ),
            decoration:
                BoxDecoration(
              color: AppColors
                  .primaryLight,
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons
                      .info_outline_rounded,
                  color: AppColors
                      .primaryBlue,
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    appointment
                                .queueNumber >
                            0
                        ? 'Your arrival has been approved and you are in the live queue.'
                        : 'When you arrive at the clinic, the assistant will approve your arrival and add you to the live queue.',
                    style:
                        const TextStyle(
                      height:
                          1.4,
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard
    extends StatelessWidget {
  const _DetailsCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color:
              AppColors.border,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0;
              i < children.length;
              i++) ...[
            children[i],

            if (i <
                children.length -
                    1)
              const Divider(
                height:
                    26,
                color: AppColors
                    .border,
              ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow
    extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color:
              AppColors.primaryBlue,
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
                title,
                style:
                    const TextStyle(
                  fontSize:
                      11,
                  color: AppColors
                      .textSecondary,
                  fontWeight:
                      FontWeight
                          .w700,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                value,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight
                          .w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// STATUS
// ===============================================================

class _StatusBadge
    extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final label =
        switch (status) {
      AppointmentStatus.booked =>
        'Booked',

      AppointmentStatus.confirmed =>
        'Confirmed',

      AppointmentStatus.inProgress =>
        'In Progress',

      AppointmentStatus.completed =>
        'Completed',

      AppointmentStatus.noShow =>
        'No Show',
    };

    final color =
        switch (status) {
      AppointmentStatus.completed =>
        AppColors.successGreen,

      AppointmentStatus.noShow =>
        AppColors.dangerRed,

      AppointmentStatus.inProgress =>
        AppColors.warningAmber,

      _ =>
        AppColors.primaryBlue,
    };

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          999,
        ),
      ),
      child: Text(
        label,
        style:
            TextStyle(
          color:
              color,
          fontSize:
              11,
          fontWeight:
              FontWeight.w800,
        ),
      ),
    );
  }
}

// ===============================================================
// EMPTY
// ===============================================================

class _EmptyAppointments
    extends StatelessWidget {
  const _EmptyAppointments({
    required this.history,
  });

  final bool history;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 70,
      ),
      child: Column(
        children: [
          const Icon(
            Icons
                .calendar_month_outlined,
            size: 54,
            color: AppColors
                .textSecondary,
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            history
                ? 'No past appointments yet.'
                : 'No upcoming appointments.',
            style:
                const TextStyle(
              color: AppColors
                  .textSecondary,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}