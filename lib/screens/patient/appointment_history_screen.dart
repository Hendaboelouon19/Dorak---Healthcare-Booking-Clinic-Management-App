import 'dart:async';

import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  static const int _initialCountdownSeconds = 11 * 60 + 38;

  final List<_BookingItem> _bookings = const [
    _BookingItem(
      location: 'Heartline Clinic • Jeddah',
      time: '10:00 AM - 10:30 AM',
      bookingId: 'APT-2048',
      price: 'MYR 300',
      month: 'AUG',
      day: '01',
      year: '2025',
      color: Color(0xFF7CCBCF),
    ),
    _BookingItem(
      location: 'CityCare Clinic • Riyadh',
      time: '12:15 PM - 12:45 PM',
      bookingId: 'APT-2145',
      price: 'MYR 420',
      month: 'AUG',
      day: '04',
      year: '2025',
      color: Color(0xFF2F73E8),
    ),
    _BookingItem(
      location: 'MediNest Clinic • Dubai',
      time: '03:30 PM - 04:00 PM',
      bookingId: 'APT-2211',
      price: 'MYR 380',
      month: 'AUG',
      day: '13',
      year: '2025',
      color: Color(0xFF2F73E8),
    ),
  ];

  _BookingItem? _selectedBooking;
  late int _remainingSeconds;
  Timer? _timer;

  void _goBackOrHome() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.patientHome,
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        final bookingId = args['bookingId'] as String?;
        if (bookingId != null) {
          final booking = _bookings.firstWhere(
            (item) => item.bookingId == bookingId,
            orElse: () => _bookings.first,
          );
          if (mounted) {
            setState(() => _selectedBooking = booking);
          }
        }
      }
    });

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
    final screenContent = _selectedBooking == null
        ? _buildListView()
        : _buildBookingDetail(_selectedBooking!);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxPhoneWidth = 420.0;
        final fittedWidth = constraints.maxWidth < maxPhoneWidth
            ? constraints.maxWidth
            : maxPhoneWidth;

        return Scaffold(
          backgroundColor: const Color(0xFFE9ECEF),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SizedBox(width: fittedWidth, child: screenContent),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F6),
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        child: Column(
          children: [
            const SizedBox(height: 6),
            _statusBar(),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: _goBackOrHome,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF1E2A39),
                    size: 24,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'My Bookings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E2A39),
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.patientNotifications),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E5EB)),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF1E2A39),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E8EC)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF2A6BF0),
                            Color(0xFF3AB7B0),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Upcoming',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'History',
                        style: TextStyle(
                          color: Color(0xFF5E6D80),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _bookings.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final booking = _bookings[index];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBooking = booking),
                    child: _BookingTicketCard(booking: booking),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetail(_BookingItem booking) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F6),
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          children: [
            const SizedBox(height: 6),
            _statusBar(),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: _goBackOrHome,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF1E2A39),
                    size: 28,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Bookings Details',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E2A39),
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.patientNotifications),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E5EB)),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF1E2A39),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF2F73E8),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final timerWidth = constraints.maxWidth >= 360 ? 150.0 : 128.0;
                      final gap = 10.0;

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.local_hospital_rounded,
                                      size: 18,
                                      color: Color(0xFF2F73E8),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  const Text(
                                    'Patient',
                                    style: TextStyle(
                                      color: Color(0xFFDDEBFF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'John Smith',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  const Text(
                                    'Booking ID',
                                    style: TextStyle(
                                      color: Color(0xFFDDEBFF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'APT-2048',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: gap),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Heartline',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Clinic',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: gap),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: timerWidth),
                              child: Container(
                                width: timerWidth,
                                height: 148,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        countdownText,
                                        style: const TextStyle(
                                          color: Color(0xFF1E2A39),
                                          fontSize: 38,
                                          fontWeight: FontWeight.w900,
                                          height: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'LEFT',
                                        style: TextStyle(
                                          color: Color(0xFF5E6D80),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEAF2FF),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: const Text(
                                          'Queue time',
                                          style: TextStyle(
                                            color: Color(0xFF2F73E8),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
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
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(child: _TicketMetaRow(title: 'Date', value: '14 Aug 2020')),
                      SizedBox(width: 18),
                      Expanded(child: _TicketMetaRow(title: 'Time', value: '10:00 AM')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Expanded(child: _TicketMetaRow(title: 'Queue', value: '03')),
                      SizedBox(width: 18),
                      Expanded(child: _TicketMetaRow(title: 'Location', value: 'Jeddah')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '92 Imani Mall Apt. 293',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF1E2A39),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '9:41',
              style: TextStyle(
                color: Color(0xFF1E2A39),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.signal_cellular_4_bar_rounded,
                size: 18,
                color: Color(0xFF1E2A39),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.wifi_rounded,
                size: 18,
                color: Color(0xFF1E2A39),
              ),
              const SizedBox(width: 4),
              Container(
                width: 18,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2A39),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 10,
                    height: 6,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8DE79C),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

class _BookingItem {
  const _BookingItem({
    required this.location,
    required this.time,
    required this.bookingId,
    required this.price,
    required this.month,
    required this.day,
    required this.year,
    required this.color,
  });

  final String location;
  final String time;
  final String bookingId;
  final String price;
  final String month;
  final String day;
  final String year;
  final Color color;
}

class _BookingTicketCard extends StatelessWidget {
  const _BookingTicketCard({required this.booking});

  final _BookingItem booking;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 170,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                booking.color,
                booking.color.withValues(alpha: 0.96),
                const Color(0xFFEAF3FF),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A1A2C4A),
                blurRadius: 12,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
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
                              booking.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Time',
                                  style: TextStyle(
                                    color: Color(0xFFDDEAFB),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  booking.time,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ID',
                                  style: TextStyle(
                                    color: Color(0xFFDDEAFB),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  booking.bookingId,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fee',
                                  style: TextStyle(
                                    color: Color(0xFFDDEAFB),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  booking.price,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
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
                  color: Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      booking.month,
                      style: const TextStyle(
                        color: Color(0xFF2A2C30),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.day,
                      style: const TextStyle(
                        color: Color(0xFF2F73E8),
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.year,
                      style: const TextStyle(
                        color: Color(0xFF2A2C30),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
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
                    color: Color(0xFFF4F5F6),
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
              painter: DashedTicketDividerPainter(),
              size: const Size(8, 170),
            ),
          ),
        ),
      ],
    );
  }
}

class DashedTicketDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8C96A3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    const dashHeight = 8.0;
    const dashSpace = 9.0;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TicketMetaRow extends StatelessWidget {
  const _TicketMetaRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF69798F),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1E2A39),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
