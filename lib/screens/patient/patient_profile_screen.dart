import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushReplacementNamed('/patient-home');
                  }
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                style: IconButton.styleFrom(padding: EdgeInsets.zero),
              ),
              const Expanded(
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 34)),
              const SizedBox(height: 16),
              Text(
                patient?.name ?? 'Hend Aboelouon',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                patient?.email ?? 'hend.aboelouon@example.com',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _ProfileField(label: 'Phone', value: patient?.phone ?? '01102177734'),
                    const SizedBox(height: 8),
                    const _ProfileField(label: 'Blood Type', value: 'O+'),
                    const SizedBox(height: 8),
                    const _ProfileField(label: 'Insurance', value: 'Premium Care'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ProfileItem(
                    icon: Icons.history_rounded,
                    label: 'Appointment History',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.appointmentHistory),
                  ),
                  _ProfileItem(
                    icon: Icons.tune_rounded,
                    label: 'Notifications Settings',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.patientNotifications),
                  ),
                  _ProfileItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help / Support',
                    onTap: () {},
                  ),
                  _ProfileItem(
  icon: Icons.logout_rounded,
  label: 'Log Out',
  onTap: () async {
    final authProvider = context.read<AuthProvider>();

    await authProvider.logout();

    if (!context.mounted) {
      return;
    }

    if (authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                'Could not log out.',
          ),
        ),
      );

      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  },
),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
