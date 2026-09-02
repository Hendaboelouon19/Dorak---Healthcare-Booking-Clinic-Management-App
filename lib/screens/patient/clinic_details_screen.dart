import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/doctor_model.dart';
import '../../providers/clinic_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

class ClinicDetailsScreen extends StatefulWidget {
  const ClinicDetailsScreen({super.key});

  @override
  State<ClinicDetailsScreen> createState() =>
      _ClinicDetailsScreenState();
}

class _ClinicDetailsScreenState
    extends State<ClinicDetailsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<ClinicProvider>().fetchDoctors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final clinicProvider =
        context.watch<ClinicProvider>();

    final clinic =
        clinicProvider.selectedClinic;

    if (clinic == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text(
            'Clinic',
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_hospital_outlined,
                  size: 56,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Clinic information is unavailable.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Go back',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                bottom: 110,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // CLINIC IMAGE
                  // =================================================

                  SizedBox(
                    height: 250,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (clinic.imageUrl.isNotEmpty)
                          Image.network(
                            clinic.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const _ClinicHeroPlaceholder();
                            },
                          )
                        else
                          const _ClinicHeroPlaceholder(),

                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin:
                                  Alignment.topCenter,
                              end:
                                  Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(
                                  alpha: 0.55,
                                ),
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                          top: 18,
                          left: 18,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pop();
                            },
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration:
                                  BoxDecoration(
                                color: Colors.white
                                    .withValues(
                                  alpha: 0.20,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(14),
                                border: Border.all(
                                  color: Colors.white
                                      .withValues(
                                    alpha: 0.40,
                                  ),
                                ),
                              ),
                              child: const Icon(
                                Icons
                                    .arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =================================================
                  // CLINIC INFORMATION
                  // =================================================

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                clinic.name,
                                style:
                                    const TextStyle(
                                  fontSize: 30,
                                  fontWeight:
                                      FontWeight.w800,
                                  color: AppColors
                                      .textPrimary,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Row(
                              children: [
                                Text(
                                  clinic.rating
                                      .toStringAsFixed(
                                    1,
                                  ),
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors
                                      .warningAmber,
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 18,
                              color:
                                  AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                clinic.address,
                                style:
                                    const TextStyle(
                                  color: AppColors
                                      .textSecondary,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _MiniStat(
                              icon: Icons
                                  .people_alt_rounded,
                              label:
                                  '${clinic.currentQueue} waiting',
                            ),

                            _MiniStat(
                              icon:
                                  Icons.access_time_rounded,
                              label:
                                  clinic.workingHours,
                            ),

                            _MiniStat(
                              icon:
                                  Icons.verified_rounded,
                              label: clinic.openNow
                                  ? 'Open now'
                                  : 'Closed',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // =================================================
                  // SERVICES
                  // =================================================

                  const _SectionTitle(
                    title: 'Services',
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      10,
                    ),
                    child: clinic.specialties.isEmpty
                        ? const Text(
                            'No services added yet.',
                            style: TextStyle(
                              color: AppColors
                                  .textSecondary,
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 10,
                            children: clinic.specialties
                                .map(
                                  (specialty) =>
                                      _ServiceChip(
                                    label:
                                        specialty,
                                  ),
                                )
                                .toList(),
                          ),
                  ),

                  // =================================================
                  // DOCTORS
                  // =================================================

                  const _SectionTitle(
                    title: 'Doctors',
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: _buildDoctors(
                      clinicProvider,
                    ),
                  ),

                  // =================================================
                  // CLINIC INFORMATION
                  // =================================================

                  const _SectionTitle(
                    title: 'Clinic information',
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      22,
                    ),
                    child: Container(
                      padding:
                          const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            label:
                                'Working hours',
                            value: clinic
                                    .workingHours
                                    .isEmpty
                                ? 'Not available'
                                : clinic
                                    .workingHours,
                          ),

                          const Divider(
                            height: 24,
                            color:
                                AppColors.border,
                          ),

                          _InfoRow(
                            label: 'Assistant',
                            value: clinic
                                    .assistantName
                                    .isEmpty
                                ? 'Not assigned'
                                : clinic
                                    .assistantName,
                          ),

                          const Divider(
                            height: 24,
                            color:
                                AppColors.border,
                          ),

                          _InfoRow(
                            label: 'Status',
                            value:
                                clinic.openNow
                                    ? 'Open today'
                                    : 'Closed',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // =================================================
                  // QUEUE
                  // =================================================

                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      24,
                    ),
                    child: _LiveQueueInfoCard(
                      queue:
                          clinic.currentQueue,
                    ),
                  ),
                ],
              ),
            ),

            // =====================================================
            // BOOK BUTTON
            // =====================================================

            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: FilledButton(
                onPressed:
                    clinicProvider.selectedDoctor ==
                            null
                        ? null
                        : () {
                            Navigator.of(context)
                                .pushNamed(
                              AppRoutes
                                  .bookAppointment,
                            );
                          },
                style:
                    FilledButton.styleFrom(
                  backgroundColor:
                      AppColors.primaryBlue,
                  disabledBackgroundColor:
                      AppColors.primaryBlue
                          .withValues(
                    alpha: 0.40,
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),
                child: Text(
                  clinicProvider.selectedDoctor ==
                          null
                      ? 'Choose a Doctor to Book'
                      : 'Book with ${clinicProvider.selectedDoctor!.name}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // DOCTORS STATE
  // =============================================================

  Widget _buildDoctors(
    ClinicProvider provider,
  ) {
    if (provider.isLoadingDoctors) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.doctorErrorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Text(
              provider.doctorErrorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color:
                    AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed:
                  provider.fetchDoctors,
              child: const Text(
                'Try again',
              ),
            ),
          ],
        ),
      );
    }

    if (provider.doctors.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: const Text(
          'No doctors are currently available.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color:
                AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return SizedBox(
      height: 235,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.doctors.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final doctor =
              provider.doctors[index];

          final selected =
              provider.selectedDoctor?.id ==
                  doctor.id;

          return _DoctorCard(
            doctor: doctor,
            selected: selected,
            onTap: () {
              context
                  .read<ClinicProvider>()
                  .selectDoctorModel(
                    doctor,
                  );
            },
          );
        },
      ),
    );
  }
}

// ===============================================================
// DOCTOR CARD
// ===============================================================

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.doctor,
    required this.selected,
    required this.onTap,
  });

  final DoctorModel doctor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(18),
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryLight
              : AppColors.surface,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.primaryBlue
                : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 31,
              backgroundColor:
                  AppColors.primaryLight,
              backgroundImage:
                  doctor.imageUrl.isNotEmpty
                      ? NetworkImage(
                          doctor.imageUrl,
                        )
                      : null,
              child: doctor.imageUrl.isEmpty
                  ? const Icon(
                      Icons.person,
                      size: 34,
                      color:
                          AppColors.primaryBlue,
                    )
                  : null,
            ),

            const SizedBox(height: 12),

            Text(
              doctor.name,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color:
                    AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              doctor.specialty,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color:
                    AppColors.textSecondary,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              doctor.qualification,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color:
                    AppColors.textSecondary,
              ),
            ),

            const Spacer(),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                vertical: 7,
                horizontal: 8,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryBlue
                    : AppColors.primaryLight,
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
              child: Text(
                selected
                    ? 'Selected'
                    : doctor.room.isEmpty
                        ? 'Select doctor'
                        : doctor.room,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : AppColors.primaryBlue,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// OTHER WIDGETS
// ===============================================================

class _ClinicHeroPlaceholder
    extends StatelessWidget {
  const _ClinicHeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_hospital_rounded,
        size: 72,
        color: AppColors.primaryBlue,
      ),
    );
  }
}

class _SectionTitle
    extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        10,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius:
            BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color:
                  AppColors.primaryBlue,
              fontSize: 11,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceChip
    extends StatelessWidget {
  const _ServiceChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color:
              AppColors.textPrimary,
          fontWeight:
              FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoRow
    extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color:
                  AppColors.textPrimary,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color:
                  AppColors.textSecondary,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _LiveQueueInfoCard
    extends StatelessWidget {
  const _LiveQueueInfoCard({
    required this.queue,
  });

  final int queue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue
            .withValues(
          alpha: 0.08,
        ),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.people_outline_rounded,
            color:
                AppColors.primaryBlue,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              queue == 0
                  ? 'No patients are currently waiting.'
                  : '$queue patients are currently waiting.',
              style: const TextStyle(
                fontWeight:
                    FontWeight.w700,
                color:
                    AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}