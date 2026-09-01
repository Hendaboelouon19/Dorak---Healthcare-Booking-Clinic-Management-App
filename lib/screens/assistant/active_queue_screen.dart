import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/queue_provider.dart';
import '../../theme/app_colors.dart';

class ActiveQueueScreen extends StatelessWidget {
  const ActiveQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<QueueProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Active Queue')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Now Serving', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  queue.position.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.read<QueueProvider>().callNextPatient(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Call Next Patient'),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Queue list', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _QueueListRow(name: 'Aisha Rahman', position: 2, wait: '12 min'),
                  _QueueListRow(name: 'Yousef Haddad', position: 3, wait: '18 min'),
                  _QueueListRow(name: 'Nadia Kamal', position: 4, wait: '25 min'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueListRow extends StatelessWidget {
  const _QueueListRow({required this.name, required this.position, required this.wait});
  final String name;
  final int position;
  final String wait;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(position.toString(), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryBlue))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700))),
          Text(wait, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
