import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({
    super.key,
  });

  Future<void> _logout(
    BuildContext context,
  ) async {
    final shouldLogout =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Log out?',
          ),
          content: const Text(
            'Are you sure you want to log out of Dorak?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(true);
              },
              child: const Text(
                'Log Out',
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true ||
        !context.mounted) {
      return;
    }

    final authProvider =
        context.read<AuthProvider>();

    await authProvider.logout();

    if (!context.mounted) {
      return;
    }

    if (authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                'Could not log out.',
          ),
        ),
      );

      return;
    }

    Navigator.of(context)
        .pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final authProvider =
        context.watch<AuthProvider>();

    final patient =
        authProvider.currentUser;

    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        backgroundColor:
            AppColors.background,
        elevation: 0,
        automaticallyImplyLeading:
            false,
        titleSpacing: 0,
        title: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (Navigator.canPop(
                    context,
                  )) {
                    Navigator.of(context)
                        .pop();
                  } else {
                    Navigator.of(context)
                        .pushReplacementNamed(
                      AppRoutes.patientHome,
                    );
                  }
                },
                icon: const Icon(
                  Icons
                      .arrow_back_ios_new_rounded,
                  color:
                      AppColors.textPrimary,
                ),
                style:
                    IconButton.styleFrom(
                  padding:
                      EdgeInsets.zero,
                ),
              ),
              const Expanded(
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: patient == null
            ? _EmptyProfile(
                isLoading:
                    authProvider.isLoading,
              )
            : _ProfileContent(
                patient: patient,
                isLoggingOut:
                    authProvider.isLoading,
                onLogout: () {
                  _logout(context);
                },
              ),
      ),
    );
  }
}

// ===============================================================
// PROFILE CONTENT
// ===============================================================

class _ProfileContent
    extends StatelessWidget {
  const _ProfileContent({
    required this.patient,
    required this.isLoggingOut,
    required this.onLogout,
  });

  final UserModel patient;

  final bool isLoggingOut;

  final VoidCallback onLogout;

  @override
  Widget build(
    BuildContext context,
  ) {
    final avatarUrl =
        patient.avatarUrl?.trim() ?? '';

    final phone =
        patient.phone.trim();

    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        28,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          // =====================================================
          // AVATAR
          // =====================================================

          Container(
            padding:
                const EdgeInsets.all(
              4,
            ),
            decoration:
                BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    AppColors.primaryBlue,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 46,
              backgroundColor:
                  AppColors.primaryLight,
              backgroundImage:
                  avatarUrl.isNotEmpty
                      ? NetworkImage(
                          avatarUrl,
                        )
                      : null,
              child: avatarUrl.isEmpty
                  ? const Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: AppColors
                          .primaryBlue,
                    )
                  : null,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          // =====================================================
          // REAL NAME
          // =====================================================

          Text(
            patient.name.trim().isEmpty
                ? 'Patient'
                : patient.name,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 28,
              fontWeight:
                  FontWeight.w800,
              color:
                  AppColors.textPrimary,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          // =====================================================
          // REAL EMAIL
          // =====================================================

          Text(
            patient.email.trim().isEmpty
                ? 'Email not provided'
                : patient.email,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  AppColors.textSecondary,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          // =====================================================
          // ACCOUNT INFORMATION
          // =====================================================

          _ProfileSection(
            title:
                'Account Information',
            child: Column(
              children: [
                _ProfileField(
                  icon:
                      Icons.email_outlined,
                  label:
                      'Email',
                  value: patient
                          .email
                          .trim()
                          .isEmpty
                      ? 'Not provided'
                      : patient.email,
                ),

                const SizedBox(
                  height: 10,
                ),

                _ProfileField(
                  icon:
                      Icons.phone_outlined,
                  label:
                      'Phone',
                  value:
                      phone.isEmpty
                          ? 'Not provided'
                          : phone,
                ),

                const SizedBox(
                  height: 10,
                ),

                const _ProfileField(
                  icon:
                      Icons.badge_outlined,
                  label:
                      'Account type',
                  value:
                      'Patient',
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          // =====================================================
          // PATIENT ACTIONS
          // =====================================================

          _ProfileItem(
            icon:
                Icons.history_rounded,
            label:
                'Appointment History',
            subtitle:
                'View your bookings and previous appointments',
            onTap: () {
              Navigator.of(context)
                  .pushNamed(
                AppRoutes
                    .appointmentHistory,
              );
            },
          ),

          _ProfileItem(
            icon:
                Icons
                    .notifications_none_rounded,
            label:
                'Notifications',
            subtitle:
                'View appointment and queue alerts',
            onTap: () {
              Navigator.of(context)
                  .pushNamed(
                AppRoutes
                    .patientNotifications,
              );
            },
          ),

          const SizedBox(
            height: 10,
          ),

          // =====================================================
          // LOGOUT
          // =====================================================

          SizedBox(
            width:
                double.infinity,
            child:
                OutlinedButton.icon(
              onPressed:
                  isLoggingOut
                      ? null
                      : onLogout,
              icon: isLoggingOut
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth:
                            2,
                      ),
                    )
                  : const Icon(
                      Icons
                          .logout_rounded,
                    ),
              label: Text(
                isLoggingOut
                    ? 'Logging out...'
                    : 'Log Out',
              ),
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    AppColors.dangerRed,
                side:
                    const BorderSide(
                  color:
                      AppColors.dangerRed,
                ),
                minimumSize:
                    const Size.fromHeight(
                  52,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// PROFILE SECTION
// ===============================================================

class _ProfileSection
    extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color:
              AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w800,
              color:
                  AppColors.textPrimary,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          child,
        ],
      ),
    );
  }
}

// ===============================================================
// PROFILE FIELD
// ===============================================================

class _ProfileField
    extends StatelessWidget {
  const _ProfileField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        14,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color:
              AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration:
                BoxDecoration(
              color:
                  AppColors.primaryLight,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              icon,
              size: 19,
              color:
                  AppColors.primaryBlue,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color: AppColors
                        .textSecondary,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  value,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                    color: AppColors
                        .textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// PROFILE ACTION
// ===============================================================

class _ProfileItem
    extends StatelessWidget {
  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color:
              AppColors.border,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Container(
          width: 42,
          height: 42,
          decoration:
              BoxDecoration(
            color:
                AppColors.primaryLight,
            borderRadius:
                BorderRadius.circular(
              13,
            ),
          ),
          child: Icon(
            icon,
            color:
                AppColors.primaryBlue,
          ),
        ),
        title: Text(
          label,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style:
              const TextStyle(
            color:
                AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing:
            const Icon(
          Icons
              .chevron_right_rounded,
        ),
        onTap:
            onTap,
      ),
    );
  }
}

// ===============================================================
// NO PROFILE
// ===============================================================

class _EmptyProfile
    extends StatelessWidget {
  const _EmptyProfile({
    required this.isLoading,
  });

  final bool isLoading;

  @override
  Widget build(
    BuildContext context,
  ) {
    if (isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    return const Center(
      child: Padding(
        padding:
            EdgeInsets.all(
          24,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .person_off_outlined,
              size: 54,
              color:
                  AppColors.textSecondary,
            ),

            SizedBox(
              height: 14,
            ),

            Text(
              'Could not load your profile.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w700,
                color: AppColors
                    .textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}