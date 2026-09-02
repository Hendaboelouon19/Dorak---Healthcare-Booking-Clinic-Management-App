import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/clinic_model.dart';
import '../../providers/clinic_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

class ClinicDiscoveryScreen extends StatefulWidget {
  const ClinicDiscoveryScreen({super.key});

  @override
  State<ClinicDiscoveryScreen> createState() =>
      _ClinicDiscoveryScreenState();
}

class _ClinicDiscoveryScreenState
    extends State<ClinicDiscoveryScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClinicProvider>().fetchClinics();
    });
  }

  String _normalizedCategory(String category) {
    switch (category.toLowerCase()) {
      case 'cardiologist':
        return 'cardio';

      case 'neurologist':
        return 'neuro';

      case 'orthopedist':
        return 'ortho';

      case 'dentist':
        return 'dent';

      case 'pulmo':
        return 'pulmo';

      default:
        return category.toLowerCase();
    }
  }

  List<ClinicModel> _filterClinics(
    List<ClinicModel> clinics,
    String? selectedCategory,
  ) {
    if (selectedCategory == null) {
      return clinics;
    }

    final target =
        _normalizedCategory(selectedCategory);

    return clinics.where((clinic) {
      return clinic.specialties.any(
        (specialty) => specialty
            .toLowerCase()
            .contains(target),
      );
    }).toList();
  }

  void _openClinic(
    BuildContext context,
    ClinicModel clinic,
  ) {
    context
        .read<ClinicProvider>()
        .selectClinic(clinic.id);

    Navigator.of(context).pushNamed(
      AppRoutes.clinicDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?;

    final selectedCategory =
        args?['category'] as String?;

    final clinicProvider =
        context.watch<ClinicProvider>();

    final filteredClinics = _filterClinics(
      clinicProvider.clinics,
      selectedCategory,
    );

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context)
                        .pushReplacementNamed(
                      AppRoutes.patientHome,
                    );
                  }
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                ),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
              ),

              Expanded(
                child: Text(
                  selectedCategory == null
                      ? 'Clinics near me'
                      : '$selectedCategory clinics',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
              ),

              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------------- FILTERS ----------------

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: const SizedBox(
                height: 42,
                child: SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Distance',
                      ),
                      _FilterChip(
                        label: 'Rating',
                      ),
                      _FilterChip(
                        label: 'Open Now',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ---------------- CONTENT ----------------

            Expanded(
              child: _buildContent(
                clinicProvider,
                filteredClinics,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    ClinicProvider provider,
    List<ClinicModel> clinics,
  ) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.textSecondary,
              ),

              const SizedBox(height: 12),

              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color:
                      AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 16),

              FilledButton(
                onPressed:
                    provider.fetchClinics,
                child: const Text(
                  'Try again',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (clinics.isEmpty) {
      return const Center(
        child: Text(
          'No clinics available.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.fetchClinics,
      child: ListView.separated(
        physics:
            const AlwaysScrollableScrollPhysics(),
        itemCount: clinics.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final clinic = clinics[index];

          return _ClinicListTile(
            clinic: clinic,
            onTap: () =>
                _openClinic(
              context,
              clinic,
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(right: 10),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      alignment: Alignment.center,
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
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ClinicListTile
    extends StatelessWidget {
  const _ClinicListTile({
    required this.clinic,
    required this.onTap,
  });

  final ClinicModel clinic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius:
          BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(20),
        child: Container(
          padding:
              const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              // ---------------- IMAGE ----------------

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(16),
                child: SizedBox(
                  width: 110,
                  height: 110,
                  child:
                      clinic.imageUrl.isNotEmpty
                          ? Image.network(
                              clinic.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const _ClinicPlaceholder();
                              },
                            )
                          : const _ClinicPlaceholder(),
                ),
              ),

              const SizedBox(width: 14),

              // ---------------- DETAILS ----------------

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            clinic.name,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),

                        Text(
                          clinic.openNow
                              ? 'Open'
                              : 'Closed',
                          style: TextStyle(
                            color: clinic.openNow
                                ? AppColors
                                    .successGreen
                                : AppColors
                                    .warningAmber,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      clinic.specialties.join(
                        ', ',
                      ),
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:
                            AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors
                              .warningAmber,
                          size: 18,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          clinic.rating
                              .toStringAsFixed(1),
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const Spacer(),

                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: AppColors
                              .textSecondary,
                        ),

                        const SizedBox(width: 3),

                        Text(
                          clinic.distance,
                          style:
                              const TextStyle(
                            color: AppColors
                                .textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            AppColors.primaryLight,
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Text(
                        '${clinic.currentQueue} waiting',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w700,
                          color:
                              AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClinicPlaceholder
    extends StatelessWidget {
  const _ClinicPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_hospital_rounded,
        color: AppColors.primaryBlue,
        size: 44,
      ),
    );
  }
}