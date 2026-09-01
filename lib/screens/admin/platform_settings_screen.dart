import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class PlatformSettingsScreen extends StatelessWidget {
  const PlatformSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Platform Settings')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: const [
          _SettingsTile(title: 'Role & permission management', subtitle: 'Manage staff access levels'),
          _SettingsTile(title: 'Notification templates', subtitle: 'Queue alerts & reminders'),
          _SettingsTile(title: 'General app settings', subtitle: 'Global platform preferences'),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.settings_applications_rounded, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
