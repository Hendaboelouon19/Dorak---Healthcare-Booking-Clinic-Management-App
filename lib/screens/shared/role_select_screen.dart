import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Select a role')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Dorakk UI Test Roles',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            _RoleCard(
              title: 'Patient',
              subtitle: 'Book appointments and track queue status',
              color: AppColors.primaryBlue,
              onTap: () {
                auth.setRole(UserRole.patient);
                Navigator.of(context).pushReplacementNamed('/patient-home');
              },
            ),
            const SizedBox(height: 16),
            _RoleCard(
              title: 'Assistant',
              subtitle: 'Approve arrivals and manage the clinic queue',
              color: AppColors.successGreen,
              onTap: () {
                auth.setRole(UserRole.assistant);
                Navigator.of(context).pushReplacementNamed('/assistant-dashboard');
              },
            ),
            const SizedBox(height: 16),
            _RoleCard(
              title: 'Admin',
              subtitle: 'Monitor clinics, staff, and platform insights',
              color: AppColors.warningAmber,
              onTap: () {
                auth.setRole(UserRole.admin);
                Navigator.of(context).pushReplacementNamed('/admin-dashboard');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
