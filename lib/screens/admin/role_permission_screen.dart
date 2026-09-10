import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class RolePermissionScreen extends StatelessWidget {
  const RolePermissionScreen({super.key});

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
        title: const Text('Role & Permissions'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // ============================================================
          // INTRO
          // ============================================================

          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'View the access level and responsibilities for each role on the QueueLess platform.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // ADMIN ROLE
          // ============================================================

          _RoleCard(
            icon: Icons.admin_panel_settings_rounded,
            title: 'Admin',
            subtitle: 'Full platform access',
            permissions: const [
              'Manage clinics',
              'Manage assistants',
              'View platform-wide analytics',
              'View clinic performance',
              'Manage platform-level settings',
              'Manage role assignments',
            ],
          ),

          // ============================================================
          // ASSISTANT ROLE
          // ============================================================

          _RoleCard(
            icon: Icons.badge_rounded,
            title: 'Assistant',
            subtitle: 'Clinic-specific access',
            permissions: const [
              'Manage clinic appointments',
              'Approve patient arrivals',
              'Manage the live patient queue',
              'Announce doctor arrival',
              'Mark patients as no-show',
              'Open and close the clinic queue',
              'View clinic information',
            ],
          ),

          // ============================================================
          // PATIENT ROLE
          // ============================================================

          _RoleCard(
            icon: Icons.person_rounded,
            title: 'Patient',
            subtitle: 'Patient access',
            permissions: const [
              'Discover clinics',
              'Book appointments',
              'View personal appointments',
              'Track queue status',
              'Manage personal profile',
              'Receive queue notifications',
            ],
          ),

          const SizedBox(height: 8),

          // ============================================================
          // STAFF MANAGEMENT
          // ============================================================

          const Text(
            'Staff Management',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Manage assistant accounts and their access from the admin panel.',
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          _StaffManagementCard(
            onTap: () {
              Navigator.of(context).pushNamed(
                '/assistants-management',
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ============================================================================
// ROLE CARD
// ============================================================================

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.permissions,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> permissions;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================================
            // HEADER
            // ==========================================================

            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
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
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ==========================================================
            // RESPONSIBILITIES TITLE
            // ==========================================================

            const Text(
              'Responsibilities',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 9),

            // ==========================================================
            // RESPONSIBILITIES
            // ==========================================================

            ...permissions.map(
              (permission) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 18,
                        color: AppColors.successGreen,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          permission,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// STAFF MANAGEMENT CARD
// ============================================================================

class _StaffManagementCard extends StatelessWidget {
  const _StaffManagementCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
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
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.manage_accounts_rounded,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Staff',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'View, edit, activate, or deactivate assistant accounts.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}