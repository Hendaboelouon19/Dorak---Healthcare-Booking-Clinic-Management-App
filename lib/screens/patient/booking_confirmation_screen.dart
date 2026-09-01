import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/appointment_provider.dart';
import '../../theme/app_colors.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointment = context.watch<AppointmentProvider>().selectedAppointment;
    final bookingDate = appointment?.date ?? DateTime.now().add(const Duration(days: 1));
    final dateLabel = DateFormat('EEE, d MMM').format(bookingDate);
    final timeLabel = appointment?.timeWindow ?? '10:00 AM';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 18),
              Container(
                width: 104,
                height: 104,
                decoration: const BoxDecoration(
                  color: AppColors.successGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A20C997),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 52),
              ),
              const SizedBox(height: 20),
              const Text(
                'Appointment Booked',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your appointment request has been received successfully.',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment?.clinicName ?? 'BloomCare Clinic',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${appointment?.doctorName ?? 'Dr. Hassan Nasser'} · Cardiology',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primaryBlue),
                        const SizedBox(width: 8),
                        Text('$dateLabel · $timeLabel', style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 18, color: AppColors.primaryBlue),
                        SizedBox(width: 8),
                        Text('Floor 2 · Room 210', style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const _ProgressStepper(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (appointment != null) {
                      Navigator.of(context).pushNamed(
                        '/appointment-history',
                        arguments: {'bookingId': appointment.id},
                      );
                      return;
                    }
                    Navigator.of(context).pushNamed('/appointment-history');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('View My Queue'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/patient-home'),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressStepper extends StatelessWidget {
  const _ProgressStepper();

  @override
  Widget build(BuildContext context) {
    final steps = ['Booked', 'Confirmed', 'In Progress', 'Completed'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: SizedBox(
        height: 78,
        child: Row(
          children: List.generate(steps.length, (index) {
            final isActive = index == 0;
            final isDone = index < 1;
            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isActive || isDone ? AppColors.primaryBlue : AppColors.surface,
                      border: Border.all(color: isActive || isDone ? AppColors.primaryBlue : AppColors.border),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDone ? Icons.check : Icons.circle,
                      size: 16,
                      color: isActive || isDone ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive || isDone ? AppColors.primaryBlue : AppColors.textSecondary,
                      fontWeight: isActive || isDone ? FontWeight.w700 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
