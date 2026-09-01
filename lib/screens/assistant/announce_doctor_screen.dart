import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AnnounceDoctorScreen extends StatelessWidget {
  const AnnounceDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Arrival')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 52, child: Icon(Icons.person, size: 42)),
            const SizedBox(height: 16),
            const Text('Dr. Hassan Nasser', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Cardiology', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notified 14 patients'))),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Announce Doctor Has Arrived'),
              ),
            ),
            const SizedBox(height: 20),
            const Align(alignment: Alignment.centerLeft, child: Text('Today’s announcements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  _AnnouncementItem(time: '9:15 AM', message: 'Dr. Rania Soliman arrived.'),
                  _AnnouncementItem(time: '10:40 AM', message: 'Dr. Hassan Nasser arrived.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementItem extends StatelessWidget {
  const _AnnouncementItem({required this.time, required this.message});
  final String time;
  final String message;

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
          const Icon(Icons.check_circle_rounded, color: AppColors.successGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
