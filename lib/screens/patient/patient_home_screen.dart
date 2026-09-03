import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/clinic_provider.dart';
import '../../providers/notification_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() =>
      _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context
          .read<AppointmentProvider>()
          .startAppointmentsListener();

      context
          .read<ClinicProvider>()
          .fetchClinics();
    });
  }

  // ===========================================================
  // FIND HOME APPOINTMENT
  // ===========================================================

  AppointmentModel? _findHomeAppointment(
    List<AppointmentModel> appointments,
  ) {
    if (appointments.isEmpty) {
      return null;
    }

    // Current queue / doctor visit has highest priority.
    for (final appointment in appointments) {
      if (appointment.status == AppointmentStatus.inQueue ||
          appointment.status == AppointmentStatus.inProgress) {
        return appointment;
      }
    }

    final now = DateTime.now();

    final upcoming = appointments
        .where(
          (appointment) =>
              appointment.status != AppointmentStatus.completed &&
              appointment.status != AppointmentStatus.noShow &&
              appointment.date.isAfter(now),
        )
        .toList()
      ..sort(
        (a, b) => a.date.compareTo(b.date),
      );

    if (upcoming.isNotEmpty) {
      return upcoming.first;
    }

    // Keep a still-active booking visible even if its scheduled
    // time recently passed and Assistant has not updated status yet.
    final active = appointments
        .where(
          (appointment) =>
              appointment.status != AppointmentStatus.completed &&
              appointment.status != AppointmentStatus.noShow,
        )
        .toList()
      ..sort(
        (a, b) => b.date.compareTo(a.date),
      );

    if (active.isNotEmpty) {
      return active.first;
    }

    return null;
  }

  // ===========================================================
  // STATUS
  // ===========================================================

  String _statusLabel(
    AppointmentModel appointment,
  ) {
    switch (appointment.status) {
      case AppointmentStatus.booked:
        return 'Booked';

      case AppointmentStatus.confirmed:
        return 'Confirmed';

      case AppointmentStatus.inQueue:
        return 'In Queue';

      case AppointmentStatus.inProgress:
        return 'In Progress';

      case AppointmentStatus.completed:
        return 'Completed';

      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }

  // ===========================================================
  // OPEN APPOINTMENT
  //
  // IMPORTANT:
  // EVERY STATUS OPENS THE SAME BOOKING DETAILS SCREEN.
  // ===========================================================

  void _openAppointment(
    AppointmentModel appointment,
  ) {
    context
        .read<AppointmentProvider>()
        .selectAppointment(
          appointment,
        );

    Navigator.of(context).pushNamed(
      AppRoutes.appointmentHistory,
      arguments: {
        'bookingId': appointment.id,
      },
    );
  }

  void _openCategory(
    String category,
  ) {
    Navigator.of(context).pushNamed(
      AppRoutes.clinicDiscovery,
      arguments: {
        'category': category,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
        context.watch<AuthProvider>();

    final appointmentProvider =
        context.watch<AppointmentProvider>();

    final clinicProvider =
        context.watch<ClinicProvider>();

    final unreadNotifications =
        context.watch<NotificationProvider>().unreadCount;

    final appointments =
        appointmentProvider.realAppointments;

    final homeAppointment =
        _findHomeAppointment(
      appointments,
    );

    final hasLiveQueue =
        homeAppointment?.status == AppointmentStatus.inQueue ||
            homeAppointment?.status ==
                AppointmentStatus.inProgress;

    return Scaffold(
      backgroundColor:
          AppColors.background,

      // =======================================================
      // APP BAR
      // =======================================================

      appBar: AppBar(
        backgroundColor:
            Colors.white,
        elevation: 0,
        automaticallyImplyLeading:
            false,
        titleSpacing: 0,
        title: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.background,
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(
                        0xFF2F73E8,
                      ).withValues(
                        alpha: 0.08,
                      ),
                      blurRadius: 10,
                      offset:
                          const Offset(
                        0,
                        4,
                      ),
                    ),
                  ],
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback:
                        (bounds) {
                      return const LinearGradient(
                        colors: [
                          Color(
                            0xFF2F73E8,
                          ),
                          Color(
                            0xFF3AB7B0,
                          ),
                        ],
                        begin:
                            Alignment.topLeft,
                        end:
                            Alignment.bottomRight,
                      ).createShader(
                        bounds,
                      );
                    },
                    blendMode:
                        BlendMode.srcIn,
                    child:
                        SvgPicture.asset(
                      'assets/logo/dowrak_logo_transparent.svg',
                      width: 30,
                      height: 30,
                      semanticsLabel:
                          'Dorak logo',
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Hello,',
                      style:
                          TextStyle(
                        fontSize: 14,
                        color: AppColors
                            .textSecondary,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    Text(
                      authProvider
                              .currentUser
                              ?.name ??
                          'Patient',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight.w800,
                        color: AppColors
                            .textPrimary,
                        height: 1.15,
                        letterSpacing:
                            -0.8,
                      ),
                    ),
                  ],
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(
                    AppRoutes
                        .patientNotifications,
                  );
                },
                child: Stack(
                  children: [
                    Container(
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
                            .notifications_none_rounded,
                        size: 22,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),

                    if (unreadNotifications >
                        0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration:
                              const BoxDecoration(
                            color: AppColors
                                .dangerRed,
                            shape:
                                BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // =======================================================
      // BODY
      // =======================================================

      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context
                .read<
                    AppointmentProvider>()
                .fetchAppointments(),
            context
                .read<
                    ClinicProvider>()
                .fetchClinics(),
          ]);
        },
        child:
            SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            24,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // =================================================
              // SEARCH
              // =================================================

              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(
                    AppRoutes
                        .clinicDiscovery,
                  );
                },
                child: Container(
                  height: 52,
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    border: Border.all(
                      color:
                          AppColors.border,
                    ),
                  ),
                  child:
                      const Row(
                    children: [
                      SizedBox(
                        width: 14,
                      ),
                      Icon(
                        Icons
                            .search_rounded,
                        color: AppColors
                            .textSecondary,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          'Search Doctor',
                          style:
                              TextStyle(
                            color: AppColors
                                .textSecondary,
                            fontSize: 15,
                            fontWeight:
                                FontWeight
                                    .w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // =================================================
              // CATEGORIES
              // =================================================

              const _SectionHeader(
                title:
                    'Categories',
              ),

              const SizedBox(
                height: 12,
              ),

              SizedBox(
                height: 68,
                child: ListView(
                  scrollDirection:
                      Axis.horizontal,
                  children: [
                    _CategoryChip(
                      icon: Icons
                          .psychology_rounded,
                      label:
                          'Neurologist',
                      onTap: () {
                        _openCategory(
                          'Neurologist',
                        );
                      },
                    ),
                    _CategoryChip(
                      icon: Icons
                          .favorite_rounded,
                      label:
                          'Cardiologist',
                      onTap: () {
                        _openCategory(
                          'Cardiologist',
                        );
                      },
                    ),
                    _CategoryChip(
                      icon: Icons
                          .accessibility_new_rounded,
                      label:
                          'Orthopedist',
                      onTap: () {
                        _openCategory(
                          'Orthopedist',
                        );
                      },
                    ),
                    _CategoryChip(
                      icon: Icons
                          .medical_services_rounded,
                      label:
                          'Pulmo',
                      onTap: () {
                        _openCategory(
                          'Pulmo',
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // =================================================
              // MAIN APPOINTMENT TICKET
              // =================================================

              _SectionHeader(
                title: hasLiveQueue
                    ? 'Current Appointment'
                    : 'Upcoming Appointment',
              ),

              const SizedBox(
                height: 12,
              ),

              if (appointmentProvider
                      .isLoadingAppointments &&
                  appointments.isEmpty)
                const SizedBox(
                  height: 170,
                  child: Center(
                    child:
                        CircularProgressIndicator(),
                  ),
                )
              else if (homeAppointment !=
                  null)
                _HomeAppointmentTicket(
                  appointment:
                      homeAppointment,
                  statusLabel:
                      _statusLabel(
                    homeAppointment,
                  ),
                  onTap: () {
                    _openAppointment(
                      homeAppointment,
                    );
                  },
                )
              else
                _NoAppointmentCard(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(
                      AppRoutes
                          .clinicDiscovery,
                    );
                  },
                ),

              const SizedBox(
                height: 24,
              ),

              // =================================================
              // CLINICS
              // =================================================

              _SectionHeader(
                title:
                    'Clinics near me',
                trailing:
                    TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(
                      AppRoutes
                          .clinicDiscovery,
                    );
                  },
                  style:
                      TextButton.styleFrom(
                    padding:
                        EdgeInsets.zero,
                    minimumSize:
                        Size.zero,
                    tapTargetSize:
                        MaterialTapTargetSize
                            .shrinkWrap,
                  ),
                  child:
                      const Text(
                    'See all',
                    style:
                        TextStyle(
                      fontSize: 13,
                      color: AppColors
                          .textSecondary,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              if (clinicProvider
                      .isLoading &&
                  clinicProvider
                      .clinics.isEmpty)
                const SizedBox(
                  height: 180,
                  child: Center(
                    child:
                        CircularProgressIndicator(),
                  ),
                )
              else if (clinicProvider
                  .clinics.isEmpty)
                Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    border: Border.all(
                      color:
                          AppColors.border,
                    ),
                  ),
                  child:
                      const Text(
                    'No approved clinics are currently available.',
                    textAlign:
                        TextAlign.center,
                    style:
                        TextStyle(
                      color: AppColors
                          .textSecondary,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 180,
                  child:
                      ListView.separated(
                    scrollDirection:
                        Axis.horizontal,
                    itemCount:
                        clinicProvider
                            .clinics.length,
                    separatorBuilder:
                        (_, _) =>
                            const SizedBox(
                      width: 12,
                    ),
                    itemBuilder:
                        (context, index) {
                      final clinic =
                          clinicProvider
                              .clinics[index];

                      return _NearClinicCard(
                        name:
                            clinic.name,
                        distance:
                            clinic.distance,
                        wait:
                            '${clinic.currentQueue} waiting',
                        rating: clinic
                            .rating
                            .toStringAsFixed(
                          1,
                        ),
                        open:
                            clinic.openNow,
                        onTap: () {
                          context
                              .read<
                                  ClinicProvider>()
                              .selectClinic(
                                clinic.id,
                              );

                          Navigator.of(
                            context,
                          ).pushNamed(
                            AppRoutes
                                .clinicDetails,
                          );
                        },
                      );
                    },
                  ),
                ),

              // =================================================
              // SECONDARY APPOINTMENT CARD
              // =================================================

              if (homeAppointment !=
                  null) ...[
                const SizedBox(
                  height: 24,
                ),

                _SectionHeader(
                  title: hasLiveQueue
                      ? 'Current Appointment'
                      : 'Upcoming Appointment',
                ),

                const SizedBox(
                  height: 12,
                ),

                _UpcomingAppointmentCard(
                  appointment:
                      homeAppointment,
                  onTap: () {
                    _openAppointment(
                      homeAppointment,
                    );
                  },
                ),
              ],

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),

      // =======================================================
      // BOTTOM NAVIGATION
      // =======================================================

      bottomNavigationBar:
          Container(
        height: 88,
        padding:
            const EdgeInsets.fromLTRB(
          18,
          8,
          18,
          12,
        ),
        decoration:
            const BoxDecoration(
          color:
              AppColors.surface,
          borderRadius:
              BorderRadius.vertical(
            top:
                Radius.circular(
              24,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Color(
                0x0F102A43,
              ),
              blurRadius: 18,
              offset:
                  Offset(
                0,
                -8,
              ),
            ),
          ],
        ),
        child: Stack(
          alignment:
              Alignment.center,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 6,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  Expanded(
                    child:
                        _NavButton(
                      icon: Icons
                          .home_rounded,
                      label:
                          'Home',
                      active: true,
                      activeColor:
                          const Color(
                        0xFF3AB7B0,
                      ),
                      onTap: () {},
                    ),
                  ),

                  Expanded(
                    child:
                        _NavButton(
                      icon: Icons
                          .notifications_rounded,
                      label:
                          'Alerts',
                      activeColor:
                          const Color(
                        0xFF3AB7B0,
                      ),
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed(
                          AppRoutes
                              .patientNotifications,
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    width: 88,
                  ),

                  Expanded(
                    child:
                        _NavButton(
                      icon: Icons
                          .calendar_today_rounded,
                      label:
                          'Bookings',
                      activeColor:
                          const Color(
                        0xFF3AB7B0,
                      ),
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed(
                          AppRoutes
                              .appointmentHistory,
                        );
                      },
                    ),
                  ),

                  Expanded(
                    child:
                        _NavButton(
                      icon: Icons
                          .person_rounded,
                      label:
                          'Profile',
                      activeColor:
                          const Color(
                        0xFF3AB7B0,
                      ),
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed(
                          AppRoutes
                              .patientProfile,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 10,
              child:
                  GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(
                    AppRoutes
                        .clinicDiscovery,
                  );
                },
                child: Container(
                  width: 68,
                  height: 68,
                  decoration:
                      BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        AppColors
                            .primaryBlue,
                        Color(
                          0xFF3AB7B0,
                        ),
                      ],
                      begin: Alignment
                          .topCenter,
                      end: Alignment
                          .bottomCenter,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                    boxShadow:
                        const [
                      BoxShadow(
                        color:
                            Color(
                          0x1F043FC0,
                        ),
                        blurRadius:
                            18,
                        offset:
                            Offset(
                          0,
                          8,
                        ),
                      ),
                    ],
                  ),
                  child:
                      const Icon(
                    Icons.add_rounded,
                    color:
                        Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// SECTION HEADER
// ===============================================================

class _SectionHeader
    extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.trailing =
        const SizedBox.shrink(),
  });

  final String title;
  final Widget trailing;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        boxShadow:
            const [
          BoxShadow(
            color:
                Color(
              0x0F102A43,
            ),
            blurRadius: 12,
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
          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
                color: AppColors
                    .textPrimary,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

// ===============================================================
// HOME APPOINTMENT TICKET
// ===============================================================

class _HomeAppointmentTicket
    extends StatelessWidget {
  const _HomeAppointmentTicket({
    required this.appointment,
    required this.statusLabel,
    required this.onTap,
  });

  final AppointmentModel appointment;
  final String statusLabel;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    final month =
        DateFormat('MMM')
            .format(
              appointment.date,
            )
            .toUpperCase();

    final day =
        DateFormat('dd')
            .format(
              appointment.date,
            );

    final year =
        DateFormat('yyyy')
            .format(
              appointment.date,
            );

    return InkWell(
      borderRadius:
          BorderRadius.circular(
        24,
      ),
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            height: 170,
            decoration:
                const BoxDecoration(
              gradient:
                  LinearGradient(
                colors: [
                  Color(
                    0xFF2F73E8,
                  ),
                  Color(
                    0xFF4FB4B0,
                  ),
                  Color(
                    0xFFEAF2FF,
                  ),
                ],
                stops: [
                  0.0,
                  0.68,
                  1.0,
                ],
                begin: Alignment
                    .centerLeft,
                end: Alignment
                    .centerRight,
              ),
              borderRadius:
                  BorderRadius.all(
                Radius.circular(
                  24,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Color(
                    0x1A043FC0,
                  ),
                  blurRadius: 18,
                  offset:
                      Offset(
                    0,
                    10,
                  ),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child:
                      Padding(
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
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
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
                                size: 12,
                                color:
                                    Color(
                                  0xFF2F73E8,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Expanded(
                              child: Text(
                                appointment
                                    .clinicName,
                                maxLines:
                                    1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontSize:
                                      15,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                  color:
                                      Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          appointment
                              .doctorName,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 12,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),

                        const Spacer(),

                        Row(
                          children: [
                            Expanded(
                              child:
                                  _HomeTicketMetric(
                                label:
                                    'Time',
                                value:
                                    appointment
                                        .timeWindow,
                              ),
                            ),
                            Expanded(
                              child:
                                  _HomeTicketMetric(
                                label:
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
                                  _HomeTicketMetric(
                                label:
                                    'Status',
                                value:
                                    statusLabel,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  width: 110,
                  padding:
                      const EdgeInsets
                          .symmetric(
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
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .w800,
                          color:
                              Color(
                            0xFF2A2C30,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        day,
                        style:
                            const TextStyle(
                          fontSize: 36,
                          fontWeight:
                              FontWeight
                                  .w900,
                          color:
                              Color(
                            0xFF2F73E8,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        year,
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .w800,
                          color:
                              Color(
                            0xFF2A2C30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 100,
            top: 0,
            bottom: 0,
            child:
                IgnorePointer(
              child:
                  CustomPaint(
                painter:
                    _HomeTicketDividerPainter(),
                size:
                    const Size(
                  8,
                  170,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// NO APPOINTMENT CARD
// ===============================================================

class _NoAppointmentCard
    extends StatelessWidget {
  const _NoAppointmentCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(
        22,
      ),
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.all(
          16,
        ),
        decoration:
            BoxDecoration(
          gradient:
              const LinearGradient(
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryBlueDark,
            ],
            begin:
                Alignment.centerLeft,
            end:
                Alignment.centerRight,
          ),
          borderRadius:
              BorderRadius.circular(
            22,
          ),
          boxShadow:
              const [
            BoxShadow(
              color:
                  Color(
                0x1A043FC0,
              ),
              blurRadius: 20,
              offset:
                  Offset(
                0,
                12,
              ),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor:
                  Colors.white.withValues(
                alpha: 0.18,
              ),
              child:
                  const Icon(
                Icons
                    .calendar_today_rounded,
                color:
                    Colors.white,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'No upcoming appointment',
                    style:
                        TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Choose a clinic and book your next appointment',
                    style:
                        TextStyle(
                      fontSize: 12,
                      color:
                          Colors.white70,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons
                  .chevron_right_rounded,
              color:
                  Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// SECONDARY APPOINTMENT CARD
// ===============================================================

class _UpcomingAppointmentCard
    extends StatelessWidget {
  const _UpcomingAppointmentCard({
    required this.appointment,
    required this.onTap,
  });

  final AppointmentModel appointment;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    final dateLabel =
        DateFormat(
      'EEE, d MMM',
    ).format(
      appointment.date,
    );

    return InkWell(
      borderRadius:
          BorderRadius.circular(
        22,
      ),
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.all(
          16,
        ),
        decoration:
            BoxDecoration(
          gradient:
              const LinearGradient(
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryBlueDark,
            ],
            begin:
                Alignment.centerLeft,
            end:
                Alignment.centerRight,
          ),
          borderRadius:
              BorderRadius.circular(
            22,
          ),
          boxShadow:
              const [
            BoxShadow(
              color:
                  Color(
                0x1A043FC0,
              ),
              blurRadius: 20,
              offset:
                  Offset(
                0,
                12,
              ),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor:
                  Colors.white.withValues(
                alpha: 0.18,
              ),
              child:
                  const Icon(
                Icons.person,
                color:
                    Colors.white,
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
                    appointment
                        .doctorName,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          Colors.white,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    appointment
                        .clinicName,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color:
                          Colors.white70,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _SmallWhiteInfo(
                        icon: Icons
                            .calendar_today_rounded,
                        text:
                            dateLabel,
                      ),
                      _SmallWhiteInfo(
                        icon: Icons
                            .access_time_rounded,
                        text: appointment
                            .timeWindow,
                      ),
                      if (appointment
                              .queueNumber >
                          0)
                        _SmallWhiteInfo(
                          icon: Icons
                              .confirmation_number_outlined,
                          text:
                              'Queue #${appointment.queueNumber}',
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons
                  .chevron_right_rounded,
              color:
                  Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallWhiteInfo
    extends StatelessWidget {
  const _SmallWhiteInfo({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color:
              Colors.white70,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          text,
          style:
              const TextStyle(
            fontSize: 12,
            color:
                Colors.white70,
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// CATEGORY
// ===============================================================

class _CategoryChip
    extends StatelessWidget {
  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(
        14,
      ),
      onTap: onTap,
      child: Container(
        margin:
            const EdgeInsets.only(
          right: 10,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
        ),
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
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color:
                  AppColors.primaryBlue,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              label,
              style:
                  const TextStyle(
                fontSize: 12,
                color: AppColors
                    .textPrimary,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// TICKET METRIC
// ===============================================================

class _HomeTicketMetric
    extends StatelessWidget {
  const _HomeTicketMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style:
              const TextStyle(
            color:
                Color(
              0xFFD9E7FF,
            ),
            fontSize: 12,
            fontWeight:
                FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: 8,
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
            fontSize: 13,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// TICKET DIVIDER
// ===============================================================

class _HomeTicketDividerPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color =
          const Color(
        0xFF7C8794,
      )
      ..style =
          PaintingStyle.stroke
      ..strokeWidth =
          2.6
      ..strokeCap =
          StrokeCap.round;

    const dashLength =
        8.0;

    const gap =
        8.0;

    double startY =
        0;

    while (startY <
        size.height) {
      canvas.drawLine(
        Offset(
          size.width / 2,
          startY,
        ),
        Offset(
          size.width / 2,
          startY +
              dashLength,
        ),
        paint,
      );

      startY +=
          dashLength +
              gap;
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter
        oldDelegate,
  ) {
    return false;
  }
}

// ===============================================================
// CLINIC CARD
// ===============================================================

class _NearClinicCard
    extends StatelessWidget {
  const _NearClinicCard({
    required this.name,
    required this.distance,
    required this.wait,
    required this.rating,
    required this.open,
    required this.onTap,
  });

  final String name;
  final String distance;
  final String wait;
  final String rating;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(
        20,
      ),
      onTap: onTap,
      child: Container(
        width: 180,
        padding:
            const EdgeInsets.all(
          14,
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
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.primaryLight,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child:
                      const Icon(
                    Icons
                        .local_hospital_rounded,
                    color: AppColors
                        .primaryBlue,
                    size: 18,
                  ),
                ),

                const Spacer(),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration:
                      BoxDecoration(
                    color: open
                        ? AppColors
                            .successGreen
                            .withValues(
                            alpha: 0.12,
                          )
                        : AppColors
                            .warningAmber
                            .withValues(
                            alpha: 0.12,
                          ),
                    borderRadius:
                        BorderRadius.circular(
                      999,
                    ),
                  ),
                  child: Text(
                    open
                        ? 'Open'
                        : 'Closed',
                    style:
                        TextStyle(
                      color: open
                          ? AppColors
                              .successGreen
                          : AppColors
                              .warningAmber,
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              name,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w800,
                color: AppColors
                    .textPrimary,
              ),
            ),

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
                      .textSecondary,
                ),
                const SizedBox(
                  width: 4,
                ),
                Expanded(
                  child: Text(
                    distance,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color: AppColors
                          .textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 8,
            ),

            Row(
              children: [
                const Icon(
                  Icons
                      .star_rounded,
                  size: 14,
                  color: AppColors
                      .warningAmber,
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  rating,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color: AppColors
                        .textPrimary,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.primaryLight,
                    borderRadius:
                        BorderRadius.circular(
                      999,
                    ),
                  ),
                  child: Text(
                    wait,
                    style:
                        const TextStyle(
                      fontSize: 10,
                      color: AppColors
                          .primaryBlue,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// NAV BUTTON
// ===============================================================

class _NavButton
    extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.activeColor =
        AppColors.primaryBlue,
  });

  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior:
          HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: active
                ? activeColor
                : AppColors
                    .textSecondary,
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            label,
            style:
                TextStyle(
              fontSize: 11,
              color: active
                  ? activeColor
                  : AppColors
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