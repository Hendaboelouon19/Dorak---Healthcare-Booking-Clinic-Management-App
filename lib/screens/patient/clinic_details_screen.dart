import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/clinic_model.dart';
import '../../providers/clinic_provider.dart';
import '../../theme/app_colors.dart';

class ClinicDetailsScreen extends StatelessWidget {
  const ClinicDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedClinic = context.watch<ClinicProvider>().selectedClinic;
    final clinic = selectedClinic ?? const ClinicModel(
      id: 'clinic_1',
      name: 'BloomCare Clinic',
      address: '15 Al Noor Street, Jeddah',
      specialties: ['Cardiology', 'Heart Diagnostics', 'Preventive Care'],
      rating: 4.8,
      distance: '2.3 km',
      imageUrl: 'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=1200&q=80',
      openNow: true,
      currentQueue: 12,
      assistantName: 'Sara Al-Khalid',
      workingHours: 'Mon-Sat · 9:00 AM - 9:00 PM',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 250,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          clinic.imageUrl,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 18,
                          left: 18,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                clinic.name,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text('${clinic.rating}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            const SizedBox(width: 4),
                            const Icon(Icons.star_rounded, color: AppColors.warningAmber),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primaryBlue),
                            const SizedBox(width: 6),
                            Text(
                              clinic.address,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _MiniStat(icon: Icons.people_alt_rounded, label: '${clinic.currentQueue} waiting'),
                            _MiniStat(icon: Icons.access_time_rounded, label: clinic.workingHours),
                            _MiniStat(icon: Icons.verified_rounded, label: clinic.openNow ? 'Open now' : 'Busy now'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F102A43),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Doctors',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                    child: SizedBox(
                      height: 220,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: const [
                          _DoctorCard(name: 'Dr. Hassan Nasser', specialty: 'Cardiology', nextAvailable: 'Next: 10:00 AM'),
                          _DoctorCard(name: 'Dr. Nora Al-Sayed', specialty: 'Interventional Cardiology', nextAvailable: 'Next: 11:30 AM'),
                          _DoctorCard(name: 'Dr. Rania Soliman', specialty: 'Cardiac Consultant', nextAvailable: 'Next: 1:00 PM'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F102A43),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: clinic.specialties
                          .map((specialty) => _ServiceChip(label: specialty))
                          .toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F102A43),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Working hours',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _WorkingHoursCard(workingHours: clinic.workingHours),
                        const SizedBox(height: 22),
                        _LiveQueueInfoCard(queue: clinic.currentQueue),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pushNamed('/book-appointment'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Book a Slot'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primaryBlue),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.name, required this.specialty, required this.nextAvailable});
  final String name;
  final String specialty;
  final String nextAvailable;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<ClinicProvider>().selectDoctor(
          doctorName: name,
          specialty: specialty,
          nextAvailable: nextAvailable,
        );
        Navigator.of(context).pushNamed('/book-appointment');
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 190,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: AppColors.primaryBlue, size: 34),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              specialty,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                nextAvailable,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _WorkingHoursRow extends StatelessWidget {
  const _WorkingHoursRow({required this.day, required this.time});
  final String day;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              day,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _WorkingHoursCard extends StatelessWidget {
  const _WorkingHoursCard({required this.workingHours});

  final String workingHours;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _WorkingHoursRow(day: 'Clinic hours', time: workingHours),
          const Divider(height: 20, color: AppColors.border),
          const _WorkingHoursRow(day: 'Assistant', time: 'Sara Al-Khalid'),
          const Divider(height: 20, color: AppColors.border),
          const _WorkingHoursRow(day: 'Status', time: 'Open today'),
        ],
      ),
    );
  }
}

class _LiveQueueInfoCard extends StatelessWidget {
  const _LiveQueueInfoCard({required this.queue});

  final int queue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_outline_rounded, color: AppColors.primaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Current live queue length: $queue patients waiting',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


