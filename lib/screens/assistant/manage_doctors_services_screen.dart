import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class ManageDoctorsServicesScreen extends StatelessWidget {
  const ManageDoctorsServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctors & Services')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Align(alignment: Alignment.centerLeft, child: Text('Doctors', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
            const SizedBox(height: 12),
            const _DoctorManageRow(name: 'Dr. Hassan Nasser', specialty: 'Cardiology'),
            const _DoctorManageRow(name: 'Dr. Noor Badr', specialty: 'Pediatrics'),
            const SizedBox(height: 22),
            const Align(alignment: Alignment.centerLeft, child: Text('Services', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _ServiceTag(label: 'Consultation'),
                _ServiceTag(label: 'Diagnostics'),
                _ServiceTag(label: 'Vaccination'),
                _ServiceTag(label: 'Heart Care'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorManageRow extends StatelessWidget {
  const _DoctorManageRow({required this.name, required this.specialty});
  final String name;
  final String specialty;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(specialty, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
        ],
      ),
    );
  }
}

class _ServiceTag extends StatelessWidget {
  const _ServiceTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
