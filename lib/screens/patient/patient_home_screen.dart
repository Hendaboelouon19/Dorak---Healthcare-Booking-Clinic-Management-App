import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/queue_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  static const int _initialCountdownSeconds = 11 * 60 + 38;
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _initialCountdownSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _remainingSeconds <= 0) {
        return;
      }
      setState(() {
        _remainingSeconds -= 1;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get countdownText {
    final safeSeconds = _remainingSeconds < 0 ? 0 : _remainingSeconds;
    final minutes = (safeSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (safeSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final queue = context.watch<QueueProvider>();
    final appointmentProvider = context.watch<AppointmentProvider>();
    final notificationCount = context.watch<NotificationProvider>().unreadCount;
    final isQueueActive = queue.position <= 4;
    final upcomingAppointment = appointmentProvider.selectedAppointment ?? appointmentProvider.appointments.first;
    final appointmentDateLabel = DateFormat('EEE, d MMM').format(upcomingAppointment.date);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2F73E8).withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF2F73E8), Color(0xFF3AB7B0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: SvgPicture.asset(
                      'assets/logo/dowrak_logo_transparent.svg',
                      width: 30,
                      height: 30,
                      semanticsLabel: 'Dorak logo',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Hello,',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      auth.currentUser?.name ?? 'Siyam Ahamed',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.15,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.patientNotifications),
                child: Stack(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        size: 22,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (notificationCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: AppColors.dangerRed,
                            shape: BoxShape.circle,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.clinicDiscovery,
                arguments: {'category': 'Cardiologist'},
              ),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 14),
                    Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search Doctor',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F102A43),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 68,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryChip(
                    icon: Icons.psychology_rounded,
                    label: 'Neurologist',
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.clinicDiscovery,
                      arguments: {'category': 'Neurologist'},
                    ),
                  ),
                  _CategoryChip(
                    icon: Icons.favorite_rounded,
                    label: 'Cardiologist',
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.clinicDiscovery,
                      arguments: {'category': 'Cardiologist'},
                    ),
                  ),
                  _CategoryChip(
                    icon: Icons.accessibility_new_rounded,
                    label: 'Orthopedist',
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.clinicDiscovery,
                      arguments: {'category': 'Orthopedist'},
                    ),
                  ),
                  _CategoryChip(
                    icon: Icons.medical_services_rounded,
                    label: 'Pulmo',
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.clinicDiscovery,
                      arguments: {'category': 'Pulmo'},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F102A43),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                isQueueActive ? 'Queue App' : 'Upcoming Appointment',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (appointmentProvider.appointments.isNotEmpty)
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  final upcoming = appointmentProvider.appointments
                      .where((appointment) =>
                          appointment.status != AppointmentStatus.completed &&
                          appointment.status != AppointmentStatus.noShow)
                      .toList()
                    ..sort((a, b) => a.date.compareTo(b.date));
                  final nearest = upcoming.isNotEmpty ? upcoming.first : appointmentProvider.appointments.first;

                  Navigator.of(context).pushNamed(
                    AppRoutes.appointmentHistory,
                    arguments: {'bookingId': nearest.id},
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      height: 170,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF2F73E8),
                            Color(0xFF4FB4B0),
                            Color(0xFFEAF2FF),
                          ],
                          stops: [0.0, 0.68, 1.0],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1A043FC0),
                            blurRadius: 18,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.local_hospital_rounded,
                                          size: 12,
                                          color: Color(0xFF2F73E8),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          appointmentProvider.appointments.first.clinicName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _HomeTicketMetric(
                                          label: 'Time',
                                          value: appointmentProvider.appointments.first.timeWindow,
                                        ),
                                      ),
                                      Expanded(
                                        child: _HomeTicketMetric(
                                          label: 'Queue',
                                          value: appointmentProvider.appointments.first.queueNumber.toString(),
                                        ),
                                      ),
                                      Expanded(
                                        child: _HomeTicketMetric(
                                          label: 'Fee',
                                          value: 'MYR 300',
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8FAFF),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'AUG',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2A2C30),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '04',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF2F73E8),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '2025',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2A2C30),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: -10,
                      top: 0,
                      bottom: 0,
                      child: SizedBox(
                        width: 20,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            2,
                            (_) => Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8EBF0),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 100,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _HomeTicketDividerPainter(),
                          size: const Size(8, 170),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => Navigator.of(context).pushNamed('/book-appointment'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A043FC0),
                        blurRadius: 20,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        child: const Icon(Icons.calendar_today_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No active queue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Book your next appointment now',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F102A43),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Clinics near me',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/patient-clinics'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _NearClinicCard(
                    name: 'Smile Dentals',
                    distance: '1.2 km',
                    wait: '12 waiting',
                    rating: '4.9',
                    open: true,
                    onTap: () => Navigator.of(context).pushNamed('/clinic-details'),
                  ),
                  _NearClinicCard(
                    name: 'City Clinic',
                    distance: '2.4 km',
                    wait: '8 waiting',
                    rating: '4.7',
                    open: true,
                    onTap: () => Navigator.of(context).pushNamed('/clinic-details'),
                  ),
                  _NearClinicCard(
                    name: 'Carepoint',
                    distance: '3.1 km',
                    wait: '5 waiting',
                    rating: '4.8',
                    open: false,
                    onTap: () => Navigator.of(context).pushNamed('/clinic-details'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F102A43),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Upcoming Appointment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => Navigator.of(context).pushNamed('/live-queue'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A043FC0),
                      blurRadius: 20,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            upcomingAppointment.doctorName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            upcomingAppointment.clinicName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white70),
                                  const SizedBox(width: 6),
                                  Text(
                                    appointmentDateLabel,
                                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 14, color: Colors.white70),
                                  const SizedBox(width: 6),
                                  Text(
                                    upcomingAppointment.timeWindow,
                                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 88,
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0F102A43),
              blurRadius: 18,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _NavButton(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      active: true,
                      activeColor: const Color(0xFF3AB7B0),
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.patientHome),
                    ),
                  ),
                  Expanded(
                    child: _NavButton(
                      icon: Icons.notifications_rounded,
                      label: 'Alerts',
                      active: false,
                      activeColor: const Color(0xFF3AB7B0),
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.patientNotifications),
                    ),
                  ),
                  const SizedBox(width: 88),
                  Expanded(
                    child: _NavButton(
                      icon: Icons.calendar_today_rounded,
                      label: 'Bookings',
                      active: false,
                      activeColor: const Color(0xFF3AB7B0),
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.appointmentHistory),
                    ),
                  ),
                  Expanded(
                    child: _NavButton(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      activeColor: const Color(0xFF3AB7B0),
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.patientProfile),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.bookAppointment),
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryBlue, Color(0xFF3AB7B0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F043FC0),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTicketDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7C8794)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    const dashLength = 8.0;
    const gap = 8.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashLength),
        paint,
      );
      startY += dashLength + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomeTicketMetric extends StatelessWidget {
  const _HomeTicketMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFD9E7FF),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _NearClinicCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_hospital_rounded, color: AppColors.primaryBlue, size: 18),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: open ? AppColors.successGreen.withValues(alpha: 0.12) : AppColors.warningAmber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    open ? 'Open' : 'Busy',
                    style: TextStyle(
                      color: open ? AppColors.successGreen : AppColors.warningAmber,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(distance, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 14, color: AppColors.warningAmber),
                const SizedBox(width: 4),
                Text(rating, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    wait,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700,
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

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    this.active = false,
    this.activeColor = AppColors.primaryBlue,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: active ? activeColor : AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? activeColor : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
