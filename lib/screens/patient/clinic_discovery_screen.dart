import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class ClinicDiscoveryScreen extends StatelessWidget {
  const ClinicDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final selectedCategory = args?['category'] as String?;

    final clinics = const [
      _ClinicListTile(
        name: 'Smile Dentals',
        specialties: 'Dentistry, Cosmetic Care',
        rating: '4.9',
        distance: '1.2 km',
        wait: '12 waiting',
        open: true,
        category: 'Dentist',
      ),
      _ClinicListTile(
        name: 'City Care Clinic',
        specialties: 'General, Dermatology',
        rating: '4.8',
        distance: '2.4 km',
        wait: '8 waiting',
        open: true,
        category: 'Cardiologist',
      ),
      _ClinicListTile(
        name: 'Carepoint Medical',
        specialties: 'Pediatrics, Cardio',
        rating: '4.7',
        distance: '3.1 km',
        wait: '5 waiting',
        open: false,
        category: 'Cardiologist',
      ),
      _ClinicListTile(
        name: 'NeuroWell Center',
        specialties: 'Neurology, Diagnostics',
        rating: '4.9',
        distance: '2.3 km',
        wait: '7 waiting',
        open: true,
        category: 'Neurologist',
      ),
    ];

    final filteredClinics = selectedCategory == null
        ? clinics
        : clinics.where((clinic) => clinic.category.toLowerCase() == selectedCategory.toLowerCase()).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushReplacementNamed('/patient-home');
                  }
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                style: IconButton.styleFrom(padding: EdgeInsets.zero),
              ),
              const Expanded(
                child: Text(
                  'Clinics near me',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/patient-notifications'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _FilterChip(label: 'Distance'),
                    _FilterChip(label: 'Rating'),
                    _FilterChip(label: 'Open Now'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredClinics.isEmpty
                  ? const Center(
                      child: Text(
                        'No clinics match this specialty.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : ListView(
                      children: filteredClinics,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _ClinicListTile extends StatelessWidget {
  const _ClinicListTile({
    required this.name,
    required this.specialties,
    required this.rating,
    required this.distance,
    required this.wait,
    required this.open,
    required this.category,
  });

  final String name;
  final String specialties;
  final String rating;
  final String distance;
  final String wait;
  final bool open;
  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed('/clinic-details'),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 110,
                height: 110,
                color: AppColors.primaryLight,
                child: const Icon(Icons.local_hospital_rounded, color: AppColors.primaryBlue, size: 44),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        open ? 'Open' : 'Busy',
                        style: TextStyle(
                          color: open ? AppColors.successGreen : AppColors.warningAmber,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(specialties, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.warningAmber, size: 18),
                      Text(' $rating', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text(distance, style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(wait, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
