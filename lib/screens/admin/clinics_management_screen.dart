import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class ClinicsManagementScreen extends StatelessWidget {
  const ClinicsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinics Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            _ClinicRow(name: 'BloomCare Clinic', assistant: 'Sara Al-Khalid', status: 'Open', appointments: '42 today'),
            _ClinicRow(name: 'Smile Dental Center', assistant: 'Mazen Ali', status: 'Closed', appointments: '18 today'),
            _ClinicRow(name: 'CareNest Pediatrics', assistant: 'Lina Hassan', status: 'Open', appointments: '31 today'),
          ],
        ),
      ),
    );
  }
}

class _ClinicRow extends StatelessWidget {
  const _ClinicRow({required this.name, required this.assistant, required this.status, required this.appointments});
  final String name;
  final String assistant;
  final String status;
  final String appointments;

  @override
  Widget build(BuildContext context) {
    final isOpen = status == 'Open';
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed('/clinic-edit'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const CircleAvatar(child: Icon(Icons.local_hospital_rounded)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('Assistant: $assistant', style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Text(appointments, style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isOpen ? AppColors.successGreen.withValues(alpha: 0.12) : AppColors.warningAmber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(status, style: TextStyle(color: isOpen ? AppColors.successGreen : AppColors.warningAmber, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
