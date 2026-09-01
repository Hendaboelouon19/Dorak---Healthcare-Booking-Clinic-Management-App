import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AssistantDashboardScreen extends StatelessWidget {
  const AssistantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BloomCare Clinic'),
        actions: [
          Switch(value: true, onChanged: (_) {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today, 15 May', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 18),
            Row(
              children: const [
                _MetricCard(label: 'Total booked', value: '42'),
                SizedBox(width: 12),
                _MetricCard(label: 'Checked-in', value: '18'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                _MetricCard(label: 'No-shows', value: '3'),
                SizedBox(width: 12),
                _MetricCard(label: 'Waiting', value: '12'),
              ],
            ),
            const SizedBox(height: 22),
            const Text('Today’s appointments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            const _AppointmentRow(name: 'Aisha Rahman', time: '9:15 AM', status: 'Approved'),
            const _AppointmentRow(name: 'Yousef Haddad', time: '9:45 AM', status: 'Pending'),
            const _AppointmentRow(name: 'Nadia Kamal', time: '10:00 AM', status: 'No-show'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Arrival'),
          BottomNavigationBarItem(icon: Icon(Icons.format_list_numbered_rounded), label: 'Queue'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_information_rounded), label: 'Doctors'),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.of(context).pushNamed('/arrival-approval');
              break;
            case 2:
              Navigator.of(context).pushNamed('/active-queue');
              break;
            case 3:
              Navigator.of(context).pushNamed('/manage-doctors');
              break;
          }
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({required this.name, required this.time, required this.status});
  final String name;
  final String time;
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Approved' => AppColors.successGreen,
      'Pending' => AppColors.warningAmber,
      'No-show' => AppColors.dangerRed,
      _ => AppColors.primaryBlue,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          TextButton(onPressed: () {}, child: const Text('Approve')),
        ],
      ),
    );
  }
}
