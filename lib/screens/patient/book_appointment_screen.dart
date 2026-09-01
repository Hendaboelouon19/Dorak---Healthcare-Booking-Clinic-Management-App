import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/clinic_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final List<String> dates = ['Mon 14', 'Tue 15', 'Wed 16', 'Thu 17', 'Fri 18', 'Sat 19'];
  final List<String> slots = ['9:00 AM', '9:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM', '1:00 PM', '1:30 PM', '2:00 PM'];
  String selectedDate = 'Tue 15';
  String selectedSlot = '10:00 AM';

  DateTime _selectedDateTime(DateTime now) {
    final weekdayIndex = dates.indexOf(selectedDate);
    final base = DateTime(now.year, now.month, now.day);

    final offset = weekdayIndex >= 0 ? weekdayIndex - base.weekday + 1 : 1;
    return base.add(Duration(days: offset));
  }

  @override
  Widget build(BuildContext context) {
    final patient = context.watch<AuthProvider>().currentUser;
    final clinicProvider = context.watch<ClinicProvider>();
    final clinic = clinicProvider.selectedClinic;
    final clinicName = clinic?.name ?? 'BloomCare Clinic';
    final doctorName = clinicProvider.selectedDoctorName ??
        (clinic?.specialties.any((specialty) => specialty.toLowerCase().contains('cardio')) ?? true
            ? 'Dr. Hassan Nasser'
            : 'Dr. Noor Badr');
    final doctorSpecialty = clinicProvider.selectedDoctorSpecialty ?? 'Cardiology Consultant';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Book Appointment',
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
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                      ),
                      child: const Icon(Icons.medical_services_rounded, color: AppColors.primaryBlue, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctorName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctorSpecialty,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primaryBlue),
                              const SizedBox(width: 4),
                              Text(
                                '$clinicName · 2nd floor',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date & Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 94,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: dates.length,
                        itemBuilder: (context, index) {
                          final date = dates[index];
                          final isSelected = date == selectedDate;
                          return GestureDetector(
                            onTap: () => setState(() => selectedDate = date),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 80,
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryBlue : AppColors.surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryBlue : AppColors.border,
                                ),
                                boxShadow: isSelected
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x1F043FC0),
                                          blurRadius: 12,
                                          offset: Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    date.split(' ')[0],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected ? Colors.white : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    date.split(' ')[1],
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Select a Time',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      itemCount: slots.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.25,
                      ),
                      itemBuilder: (context, index) {
                        final slot = slots[index];
                        final isSelected = slot == selectedSlot;
                        return GestureDetector(
                          onTap: () => setState(() => selectedSlot = slot),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryLight : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryBlue : AppColors.border,
                                width: isSelected ? 1.2 : 1,
                              ),
                            ),
                            child: Text(
                              slot,
                              style: TextStyle(
                                color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$selectedDate · $selectedSlot',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final provider = context.read<AppointmentProvider>();
                    await provider.bookAppointment(
                      patientName: patient?.name ?? 'Hend Aboelouon',
                      clinicName: clinicName,
                      doctorName: doctorName,
                      date: _selectedDateTime(DateTime.now()),
                      timeWindow: selectedSlot,
                      queueNumber: 4,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pushNamed(AppRoutes.bookingConfirmation);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Book an Appointment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
