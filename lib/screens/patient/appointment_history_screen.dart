import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../routes/app_routes.dart';

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
  String? _selectedAppointmentId;

  bool _historyTab = false;
  bool _routeArgumentsHandled = false;
  bool _openedDirectlyFromTicket = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Repaint countdown every second.
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
  if (!mounted) {
    return;
  }

  context
      .read<AppointmentProvider>()
      .startAppointmentsListener();
});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_routeArgumentsHandled) {
      return;
    }

    _routeArgumentsHandled = true;

    final args =
        ModalRoute.of(context)
            ?.settings
            .arguments;

    if (args is Map<String, dynamic>) {
      final bookingId =
          args['bookingId'] as String?;

      if (bookingId != null) {
        _selectedAppointmentId =
            bookingId;

        _openedDirectlyFromTicket =
            true;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  AppointmentModel? _findAppointment(
    List<AppointmentModel> appointments,
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

  List<AppointmentModel> _upcoming(
    List<AppointmentModel> appointments,
  ) {
    final result = appointments
        .where(
          (appointment) =>
              appointment.status.name !=
                  'completed' &&
              appointment.status.name !=
                  'noShow',
        )
        .toList();

    result.sort(
      (a, b) =>
          a.date.compareTo(b.date),
    );

    return result;
  }

  List<AppointmentModel> _history(
    List<AppointmentModel> appointments,
  ) {
    final result = appointments
        .where(
          (appointment) =>
              appointment.status.name ==
                  'completed' ||
              appointment.status.name ==
                  'noShow',
        )
        .toList();

    result.sort(
      (a, b) =>
          b.date.compareTo(a.date),
    );

    return result;
  }

  void _goBack() {
    if (_selectedAppointmentId != null &&
        !_openedDirectlyFromTicket) {
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
      (_) => false,
    );
  }

  String _statusLabel(
    AppointmentModel appointment,
  ) {
    switch (appointment.status.name) {
      case 'booked':
        return 'BOOKED';

      case 'confirmed':
        return 'CONFIRMED';

      case 'inQueue':
        return 'IN QUEUE';

      case 'inProgress':
        return 'IN PROGRESS';

      case 'completed':
        return 'COMPLETED';

      case 'noShow':
        return 'NO SHOW';

      default:
        return appointment.status.name
            .toUpperCase();
    }
  }

  String _timerText(
  AppointmentModel appointment,
) {
  final status =
      appointment.status;

  if (status ==
      AppointmentStatus.inProgress) {
    return 'NOW';
  }

  if (status ==
      AppointmentStatus.completed) {
    return 'DONE';
  }

  if (status ==
      AppointmentStatus.noShow) {
    return '--';
  }

  DateTime targetTime;

  if (status ==
          AppointmentStatus.inQueue &&
      appointment.estimatedTurnAt !=
          null) {
    targetTime =
        appointment.estimatedTurnAt!;
  } else {
    targetTime =
        appointment.date;
  }

  final difference =
      targetTime.difference(
    DateTime.now(),
  );

  if (difference.isNegative) {
    return '00:00';
  }

  final totalSeconds =
      difference.inSeconds;

  final hours =
      totalSeconds ~/ 3600;

  final minutes =
      (totalSeconds % 3600) ~/ 60;

  final seconds =
      totalSeconds % 60;

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

 String _timerBottomLabel(
  AppointmentModel appointment,
) {
  switch (appointment.status) {
    case AppointmentStatus.inQueue:
      return 'EST. WAIT';

    case AppointmentStatus.inProgress:
      return 'YOUR TURN';

    case AppointmentStatus.completed:
      return 'FINISHED';

    case AppointmentStatus.noShow:
      return 'NO SHOW';

    case AppointmentStatus.booked:
    case AppointmentStatus.confirmed:
      return 'TO APPOINTMENT';
  }
}

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<
            AppointmentProvider>();

    final appointments =
        provider.realAppointments;

    final selected =
        _findAppointment(
      appointments,
    );

    Widget content;

    if (provider.isLoadingAppointments &&
        appointments.isEmpty) {
      content = const Center(
        child:
            CircularProgressIndicator(),
      );
    } else if (selected != null) {
      content =
          _buildBookingDetail(
        selected,
      );
    } else if (_selectedAppointmentId !=
            null &&
        !provider
            .isLoadingAppointments) {
      content =
          _buildNotFound();
    } else {
      content =
          _buildListView(
        provider,
        appointments,
      );
    }

    return LayoutBuilder(
      builder:
          (context, constraints) {
        const maxPhoneWidth =
            420.0;

        final fittedWidth =
            constraints.maxWidth <
                    maxPhoneWidth
                ? constraints.maxWidth
                : maxPhoneWidth;

        return Scaffold(
          backgroundColor:
              const Color(
            0xFFE9ECEF,
          ),
          body: SafeArea(
            child: Center(
              child:
                  ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 420,
                ),
                child: SizedBox(
                  width:
                      fittedWidth,
                  child: content,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotFound() {
    return Padding(
      padding:
          const EdgeInsets.all(18),
      child: Container(
        padding:
            const EdgeInsets.all(24),
        decoration:
            BoxDecoration(
          color:
              const Color(
            0xFFF4F5F6,
          ),
          borderRadius:
              BorderRadius.circular(
            28,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons
                    .confirmation_number_outlined,
                size: 52,
                color:
                    Color(0xFF5E6D80),
              ),
              const SizedBox(
                height: 14,
              ),
              const Text(
                'Booking not found.',
                style:
                    TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              FilledButton(
                onPressed:
                    _goBack,
                child:
                    const Text(
                  'Go back',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(
    AppointmentProvider provider,
    List<AppointmentModel>
        appointments,
  ) {
    final visible =
        _historyTab
            ? _history(
                appointments,
              )
            : _upcoming(
                appointments,
              );

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      child: Container(
        decoration:
            BoxDecoration(
          color:
              const Color(
            0xFFF4F5F6,
          ),
          borderRadius:
              BorderRadius.circular(
            28,
          ),
        ),
        padding:
            const EdgeInsets.fromLTRB(
          18,
          18,
          18,
          12,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 6,
            ),

            _statusBar(),

            const SizedBox(
              height: 12,
            ),

            Row(
              children: [
                IconButton(
                  onPressed:
                      _goBack,
                  padding:
                      EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(),
                  icon:
                      const Icon(
                    Icons
                        .arrow_back_ios_new_rounded,
                    color:
                        Color(
                      0xFF1E2A39,
                    ),
                    size: 24,
                  ),
                ),

                const Expanded(
                  child: Text(
                    'My Bookings',
                    style:
                        TextStyle(
                      fontSize:
                          28,
                      fontWeight:
                          FontWeight
                              .w800,
                      color:
                          Color(
                        0xFF1E2A39,
                      ),
                      letterSpacing:
                          -0.8,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushNamed(
                      AppRoutes
                          .patientNotifications,
                    );
                  },
                  child:
                      Container(
                    width: 40,
                    height: 40,
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                      border:
                          Border.all(
                        color:
                            const Color(
                          0xFFE0E5EB,
                        ),
                      ),
                    ),
                    child:
                        const Icon(
                      Icons
                          .notifications_none_rounded,
                      color:
                          Color(
                        0xFF1E2A39,
                      ),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            Container(
              padding:
                  const EdgeInsets.all(
                6,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFF9FAFB,
                ),
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                border:
                    Border.all(
                  color:
                      const Color(
                    0xFFE5E8EC,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child:
                        _BookingTab(
                      label:
                          'Upcoming',
                      selected:
                          !_historyTab,
                      onTap: () {
                        setState(() {
                          _historyTab =
                              false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child:
                        _BookingTab(
                      label:
                          'History',
                      selected:
                          _historyTab,
                      onTap: () {
                        setState(() {
                          _historyTab =
                              true;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            Expanded(
              child:
                  provider
                              .appointmentsErrorMessage !=
                          null
                      ? Center(
                          child: Column(
                            mainAxisSize:
                                MainAxisSize
                                    .min,
                            children: [
                              Text(
                                provider
                                    .appointmentsErrorMessage!,
                                textAlign:
                                    TextAlign
                                        .center,
                              ),
                              const SizedBox(
                                height:
                                    10,
                              ),
                              TextButton(
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
                        )
                      : visible
                              .isEmpty
                          ? Center(
                              child:
                                  Text(
                                _historyTab
                                    ? 'No booking history yet.'
                                    : 'No upcoming bookings.',
                                style:
                                    const TextStyle(
                                  color:
                                      Color(
                                    0xFF5E6D80,
                                  ),
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh:
                                  provider
                                      .fetchAppointments,
                              child:
                                  ListView
                                      .separated(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                padding:
                                    EdgeInsets
                                        .zero,
                                itemCount:
                                    visible
                                        .length,
                                separatorBuilder:
                                    (_, _) =>
                                        const SizedBox(
                                  height:
                                      16,
                                ),
                                itemBuilder:
                                    (
                                  context,
                                  index,
                                ) {
                                  final appointment =
                                      visible[
                                          index];

                                  return GestureDetector(
                                    onTap:
                                        () {
                                      setState(
                                        () {
                                          _selectedAppointmentId =
                                              appointment.id;

                                          _openedDirectlyFromTicket =
                                              false;
                                        },
                                      );
                                    },
                                    child:
                                        _BookingTicketCard(
                                      appointment:
                                          appointment,
                                      status:
                                          _statusLabel(
                                        appointment,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetail(
    AppointmentModel appointment,
  ) {
    final dateText =
        DateFormat(
      'd MMM yyyy',
    ).format(
      appointment.date,
    );

    final queueText =
        appointment.queueNumber > 0
            ? appointment
                .queueNumber
                .toString()
                .padLeft(
                  2,
                  '0',
                )
            : '—';

    final locationText =
        appointment.room.isNotEmpty
            ? appointment.room
            : 'Not assigned';

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      child: Container(
        decoration:
            BoxDecoration(
          color:
              const Color(
            0xFFF4F5F6,
          ),
          borderRadius:
              BorderRadius.circular(
            28,
          ),
        ),
        padding:
            const EdgeInsets.fromLTRB(
          18,
          18,
          18,
          18,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 6,
            ),

            _statusBar(),

            const SizedBox(
              height: 12,
            ),

            Row(
              children: [
                IconButton(
                  onPressed:
                      _goBack,
                  padding:
                      EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(),
                  icon:
                      const Icon(
                    Icons
                        .arrow_back_ios_new_rounded,
                    color:
                        Color(
                      0xFF1E2A39,
                    ),
                    size: 28,
                  ),
                ),

                const Expanded(
                  child: Text(
                    'Bookings Details',
                    style:
                        TextStyle(
                      fontSize:
                          28,
                      fontWeight:
                          FontWeight
                              .w800,
                      color:
                          Color(
                        0xFF1E2A39,
                      ),
                      letterSpacing:
                          -0.8,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushNamed(
                      AppRoutes
                          .patientNotifications,
                    );
                  },
                  child:
                      Container(
                    width: 40,
                    height: 40,
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                      border:
                          Border.all(
                        color:
                            const Color(
                          0xFFE0E5EB,
                        ),
                      ),
                    ),
                    child:
                        const Icon(
                      Icons
                          .notifications_none_rounded,
                      color:
                          Color(
                        0xFF1E2A39,
                      ),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            // ================================================
            // ORIGINAL BLUE TICKET DESIGN
            // ================================================

            Container(
              width: double.infinity,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFF2F73E8,
                ),
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
              ),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder:
                        (
                      context,
                      constraints,
                    ) {
                      final timerWidth =
                          constraints.maxWidth >=
                                  360
                              ? 150.0
                              : 128.0;

                      const gap =
                          10.0;

                      return Padding(
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          18,
                          18,
                          18,
                          14,
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Expanded(
                              flex: 4,
                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Container(
                                    width:
                                        30,
                                    height:
                                        30,
                                    decoration:
                                        const BoxDecoration(
                                      color:
                                          Colors.white,
                                      shape:
                                          BoxShape.circle,
                                    ),
                                    child:
                                        const Icon(
                                      Icons
                                          .local_hospital_rounded,
                                      size:
                                          18,
                                      color:
                                          Color(
                                        0xFF2F73E8,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                        18,
                                  ),

                                  const Text(
                                    'Patient',
                                    style:
                                        TextStyle(
                                      color:
                                          Color(
                                        0xFFDDEBFF,
                                      ),
                                      fontSize:
                                          12,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                        6,
                                  ),

                                  Text(
                                    appointment
                                        .patientName,
                                    maxLines:
                                        1,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize:
                                          18,
                                      fontWeight:
                                          FontWeight.w800,
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                        18,
                                  ),

                                  const Text(
                                    'Booking ID',
                                    style:
                                        TextStyle(
                                      color:
                                          Color(
                                        0xFFDDEBFF,
                                      ),
                                      fontSize:
                                          12,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                        6,
                                  ),

                                  Text(
                                    appointment
                                        .id,
                                    maxLines:
                                        1,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize:
                                          14,
                                      fontWeight:
                                          FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              width: gap,
                            ),

                            Expanded(
                              flex: 5,
                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  FittedBox(
                                    fit:
                                        BoxFit.scaleDown,
                                    alignment:
                                        Alignment
                                            .centerLeft,
                                    child:
                                        Text(
                                      appointment
                                          .clinicName,
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.white,
                                        fontSize:
                                            32,
                                        fontWeight:
                                            FontWeight.w800,
                                        height:
                                            1.0,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                        12,
                                  ),

                                  Text(
                                    appointment
                                        .doctorName,
                                    maxLines:
                                        2,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      color:
                                          Color(
                                        0xFFDDEBFF,
                                      ),
                                      fontSize:
                                          13,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                        8,
                                  ),

                                  Text(
                                    _statusLabel(
                                      appointment,
                                    ),
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize:
                                          12,
                                      fontWeight:
                                          FontWeight.w900,
                                      letterSpacing:
                                          0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              width: gap,
                            ),

                            ConstrainedBox(
                              constraints:
                                  BoxConstraints(
                                maxWidth:
                                    timerWidth,
                              ),
                              child:
                                  Container(
                                width:
                                    timerWidth,
                                height:
                                    148,
                                decoration:
                                    BoxDecoration(
                                  color:
                                      Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(
                                    16,
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal:
                                      12,
                                  vertical:
                                      10,
                                ),
                                child:
                                    FittedBox(
                                  fit:
                                      BoxFit.scaleDown,
                                  child:
                                      Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Text(
                                        _timerText(
                                          appointment,
                                        ),
                                        style:
                                            const TextStyle(
                                          color:
                                              Color(
                                            0xFF1E2A39,
                                          ),
                                          fontSize:
                                              38,
                                          fontWeight:
                                              FontWeight.w900,
                                          height:
                                              1.0,
                                        ),
                                      ),

                                      const SizedBox(
                                        height:
                                            4,
                                      ),

                                      const Text(
                                        'LEFT',
                                        style:
                                            TextStyle(
                                          color:
                                              Color(
                                            0xFF5E6D80,
                                          ),
                                          fontSize:
                                              12,
                                          fontWeight:
                                              FontWeight.w800,
                                          letterSpacing:
                                              1.4,
                                        ),
                                      ),

                                      const SizedBox(
                                        height:
                                            10,
                                      ),

                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal:
                                              12,
                                          vertical:
                                              5,
                                        ),
                                        decoration:
                                            BoxDecoration(
                                          color:
                                              const Color(
                                            0xFFEAF2FF,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child:
                                            Text(
                                          _timerBottomLabel(
                                            appointment,
                                          ),
                                          style:
                                              const TextStyle(
                                            color:
                                                Color(
                                              0xFF2F73E8,
                                            ),
                                            fontSize:
                                                10,
                                            fontWeight:
                                                FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),

            // ================================================
            // ORIGINAL LOWER TICKET SECTION
            // ================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                14,
              ),
              decoration:
                  const BoxDecoration(
                color:
                    Color(
                  0xFFF8F9FA,
                ),
                borderRadius:
                    BorderRadius.only(
                  bottomLeft:
                      Radius.circular(
                    18,
                  ),
                  bottomRight:
                      Radius.circular(
                    18,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child:
                            _TicketMetaRow(
                          title:
                              'Date',
                          value:
                              dateText,
                        ),
                      ),
                      const SizedBox(
                        width:
                            18,
                      ),
                      Expanded(
                        child:
                            _TicketMetaRow(
                          title:
                              'Time',
                          value:
                              appointment
                                  .timeWindow,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                            _TicketMetaRow(
                          title:
                              'Queue',
                          value:
                              queueText,
                        ),
                      ),

                      const SizedBox(
                        width:
                            18,
                      ),

                      Expanded(
                        child:
                            _TicketMetaRow(
                          title:
                              'Location',
                          value:
                              locationText,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    appointment
                        .clinicName,
                    maxLines: 2,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF1E2A39,
                      ),
                      fontSize:
                          18,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBar() {
    final time =
        DateFormat(
      'h:mm',
    ).format(
      DateTime.now(),
    );

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              time,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF1E2A39,
                ),
                fontSize:
                    16,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),

          const Row(
            children: [
              Icon(
                Icons
                    .signal_cellular_4_bar_rounded,
                size: 18,
                color:
                    Color(
                  0xFF1E2A39,
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Icon(
                Icons
                    .wifi_rounded,
                size: 18,
                color:
                    Color(
                  0xFF1E2A39,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingTab
    extends StatelessWidget {
  const _BookingTab({
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
      onTap:
          onTap,
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 180,
        ),
        height: 52,
        decoration:
            BoxDecoration(
          gradient:
              selected
                  ? const LinearGradient(
                      colors: [
                        Color(
                          0xFF2A6BF0,
                        ),
                        Color(
                          0xFF3AB7B0,
                        ),
                      ],
                    )
                  : null,
          color:
              selected
                  ? null
                  : const Color(
                      0xFFF7F8F9,
                    ),
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
        alignment:
            Alignment.center,
        child:
            Text(
          label,
          style:
              TextStyle(
            color:
                selected
                    ? Colors.white
                    : const Color(
                        0xFF5E6D80,
                      ),
            fontSize:
                17,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _BookingTicketCard
    extends StatelessWidget {
  const _BookingTicketCard({
    required this.appointment,
    required this.status,
  });

  final AppointmentModel appointment;
  final String status;

  @override
  Widget build(BuildContext context) {
    final month =
        DateFormat(
      'MMM',
    )
            .format(
              appointment.date,
            )
            .toUpperCase();

    final day =
        DateFormat(
      'dd',
    ).format(
      appointment.date,
    );

    final year =
        DateFormat(
      'yyyy',
    ).format(
      appointment.date,
    );

    return Stack(
      children: [
        Container(
          height: 170,
          decoration:
              BoxDecoration(
            gradient:
                const LinearGradient(
              begin:
                  Alignment.centerLeft,
              end:
                  Alignment.centerRight,
              colors: [
                Color(
                  0xFF2F73E8,
                ),
                Color(
                  0xFF4FB4B0,
                ),
                Color(
                  0xFFEAF3FF,
                ),
              ],
            ),
            borderRadius:
                BorderRadius.circular(
              24,
            ),
            boxShadow:
                const [
              BoxShadow(
                color:
                    Color(
                  0x1A1A2C4A,
                ),
                blurRadius:
                    12,
                offset:
                    Offset(
                  0,
                  6,
                ),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    18,
                    16,
                    18,
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
                        maxLines:
                            1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize:
                              17,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        appointment
                            .doctorName,
                        maxLines:
                            1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color:
                              Colors.white70,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child:
                                _TicketSmallValue(
                              title:
                                  'Time',
                              value:
                                  appointment
                                      .timeWindow,
                            ),
                          ),

                          Expanded(
                            child:
                                _TicketSmallValue(
                              title:
                                  'Queue',
                              value: appointment
                                          .queueNumber >
                                      0
                                  ? '#${appointment.queueNumber}'
                                  : '—',
                            ),
                          ),

                          Expanded(
                            child:
                                _TicketSmallValue(
                              title:
                                  'Status',
                              value:
                                  status,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                width: 100,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                decoration:
                    const BoxDecoration(
                  color:
                      Color(
                    0xFFF8FAFF,
                  ),
                  borderRadius:
                      BorderRadius.only(
                    topRight:
                        Radius.circular(
                      24,
                    ),
                    bottomRight:
                        Radius.circular(
                      24,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    Text(
                      month,
                      style:
                          const TextStyle(
                        fontSize:
                            18,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      day,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF2F73E8,
                        ),
                        fontSize:
                            36,
                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      year,
                      style:
                          const TextStyle(
                        fontSize:
                            16,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TicketSmallValue
    extends StatelessWidget {
  const _TicketSmallValue({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(
            color:
                Colors.white70,
            fontSize:
                10,
            fontWeight:
                FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          value,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style:
              const TextStyle(
            color:
                Colors.white,
            fontSize:
                12,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _TicketMetaRow
    extends StatelessWidget {
  const _TicketMetaRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(
            color:
                Color(
              0xFF8592A3,
            ),
            fontSize:
                12,
            fontWeight:
                FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          value,
          maxLines: 2,
          overflow:
              TextOverflow.ellipsis,
          style:
              const TextStyle(
            color:
                Color(
              0xFF1E2A39,
            ),
            fontSize:
                16,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ],
    );
  }
}