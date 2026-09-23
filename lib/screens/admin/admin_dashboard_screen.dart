import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Platform overview', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            const Row(
              children: [
                _StatCard(title: 'Total Clinics', value: '18', trend: '+12%'),
                SizedBox(width: 12),
                _StatCard(title: 'Appointments', value: '1,420', trend: '+8%'),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                _StatCard(title: 'Active Users', value: '24.8k', trend: '+15%'),
                SizedBox(width: 12),
                _StatCard(title: 'Avg Wait', value: '12m', trend: '-2m'),
              ],
            ),
            const SizedBox(height: 22),
            const Text('Top clinics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const _ClinicListTile(name: 'BloomCare Clinic', volume: '320 booked'),
            const _ClinicListTile(name: 'CareNest Pediatrics', volume: '280 booked'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.business_rounded), label: 'Clinics'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Staff'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.of(context).pushNamed('/clinics-management');
              break;
            case 2:
              Navigator.of(context).pushNamed('/assistants-management');
              break;
            case 3:
              Navigator.of(context).pushNamed('/platform-settings');
              break;
          }
        },
      ),
    );
  }

}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.trend});
  final String title;
  final String value;
  final String trend;

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
            Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(trend, style: const TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _ClinicListTile extends StatelessWidget {
  const _ClinicListTile({required this.name, required this.volume});
  final String name;
  final String volume;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.local_hospital_rounded)),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700))),
          Text(volume, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
