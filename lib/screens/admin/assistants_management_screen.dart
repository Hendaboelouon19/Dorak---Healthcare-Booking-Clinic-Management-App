import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AssistantsManagementScreen extends StatelessWidget {
  const AssistantsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assistants Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            _AssistantTile(name: 'Sara Al-Khalid', clinic: 'BloomCare Clinic', status: 'Active'),
            _AssistantTile(name: 'Mazen Ali', clinic: 'Smile Dental Center', status: 'Inactive'),
            _AssistantTile(name: 'Lina Hassan', clinic: 'CareNest Pediatrics', status: 'Active'),
          ],
        ),
      ),
    );
  }
}

class _AssistantTile extends StatelessWidget {
  const _AssistantTile({required this.name, required this.clinic, required this.status});
  final String name;
  final String clinic;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.person_outline_rounded)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(clinic, style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: status == 'Active' ? AppColors.successGreen.withValues(alpha: 0.12) : AppColors.warningAmber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(status, style: TextStyle(color: status == 'Active' ? AppColors.successGreen : AppColors.warningAmber, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
