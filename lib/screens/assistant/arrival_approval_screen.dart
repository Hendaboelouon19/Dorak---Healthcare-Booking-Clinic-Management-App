import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class ArrivalApprovalScreen extends StatelessWidget {
  const ArrivalApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arrival Approval')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: const [
          _PatientApprovalCard(name: 'Aisha Rahman', time: '9:15 AM', status: 'On time'),
          _PatientApprovalCard(name: 'Yousef Haddad', time: '9:30 AM', status: 'Late 8 min'),
          _PatientApprovalCard(name: 'Nadia Kamal', time: '9:45 AM', status: 'On time'),
        ],
      ),
    );
  }
}

class _PatientApprovalCard extends StatelessWidget {
  const _PatientApprovalCard({required this.name, required this.time, required this.status});
  final String name;
  final String time;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(radius: 24, child: Icon(Icons.person)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text('Scheduled: $time', style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: status.contains('Late') ? AppColors.warningAmber.withValues(alpha: 0.12) : AppColors.successGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(status, style: TextStyle(color: status.contains('Late') ? AppColors.warningAmber : AppColors.successGreen, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(backgroundColor: AppColors.successGreen),
                  child: const Text('Approve Arrival'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.dangerRed, side: const BorderSide(color: AppColors.dangerRed)),
                  child: const Text('Mark No-show'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
