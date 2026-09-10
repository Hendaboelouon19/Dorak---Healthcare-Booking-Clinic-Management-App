import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'role_permission_screen.dart';
import 'notification_templates_screen.dart';
import 'general_app_settings_screen.dart';

class PlatformSettingsScreen extends StatelessWidget {
  const PlatformSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Platform Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // ============================================================
          // ROLE & PERMISSIONS
          // ============================================================

          _SettingsTile(
            title: 'Role & permission management',
            subtitle: 'Manage staff access levels',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RolePermissionScreen(),
                ),
              );
            },
          ),

          // ============================================================
          // NOTIFICATION TEMPLATES
          // ============================================================

          _SettingsTile(
            title: 'Notification templates',
            subtitle: 'Queue alerts & reminders',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const NotificationTemplatesScreen(),
                ),
              );
            },
          ),

          // ============================================================
          // GENERAL APP SETTINGS
          // ============================================================

          _SettingsTile(
            title: 'General app settings',
            subtitle: 'Global platform preferences',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const GeneralAppSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SETTINGS TILE
// ============================================================================

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.settings_applications_rounded,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}