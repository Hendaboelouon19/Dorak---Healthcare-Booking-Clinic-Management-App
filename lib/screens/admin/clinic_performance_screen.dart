import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class ClinicPerformanceScreen extends StatelessWidget {
  const ClinicPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinic Performance')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _RangeChip(label: '7 Days'),
                  _RangeChip(label: '30 Days'),
                  _RangeChip(label: '90 Days'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(child: Text('Wait time trend chart')),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(child: _MiniStatCard(title: 'Avg. wait', value: '12 min')),
                SizedBox(width: 12),
                Expanded(child: _MiniStatCard(title: 'No-show', value: '8%')),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(child: Text('Peak-hours bar chart')),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({required this.label});
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
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
