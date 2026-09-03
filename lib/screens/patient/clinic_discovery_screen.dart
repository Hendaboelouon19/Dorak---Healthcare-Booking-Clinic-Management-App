import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/clinic_model.dart';
import '../../providers/clinic_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

enum _ClinicSort {
  distance,
  rating,
}

class ClinicDiscoveryScreen
    extends StatefulWidget {
  const ClinicDiscoveryScreen({
    super.key,
  });

  @override
  State<ClinicDiscoveryScreen>
      createState() =>
          _ClinicDiscoveryScreenState();
}

class _ClinicDiscoveryScreenState
    extends State<ClinicDiscoveryScreen> {
  final TextEditingController
      _searchController =
      TextEditingController();

  String _searchQuery = '';

  bool _openNowOnly = false;

  _ClinicSort _sort =
      _ClinicSort.distance;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        context
            .read<ClinicProvider>()
            .fetchClinics();
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  String _normalizedCategory(
    String category,
  ) {
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
    var result =
        List<ClinicModel>.from(
      clinics,
    );

    // =========================================================
    // CATEGORY
    // =========================================================

    if (selectedCategory != null) {
      final target =
          _normalizedCategory(
        selectedCategory,
      );

      result = result.where(
        (clinic) {
          return clinic.specialties.any(
            (specialty) =>
                specialty
                    .toLowerCase()
                    .contains(
                      target,
                    ),
          );
        },
      ).toList();
    }

    // =========================================================
    // SEARCH
    // =========================================================

    final query =
        _searchQuery
            .trim()
            .toLowerCase();

    if (query.isNotEmpty) {
      result = result.where(
        (clinic) {
          final specialties =
              clinic.specialties
                  .join(' ')
                  .toLowerCase();

          return clinic.name
                  .toLowerCase()
                  .contains(query) ||
              clinic.address
                  .toLowerCase()
                  .contains(query) ||
              specialties.contains(
                query,
              );
        },
      ).toList();
    }

    // =========================================================
    // OPEN NOW
    // =========================================================

    if (_openNowOnly) {
      result = result
          .where(
            (clinic) =>
                clinic.openNow,
          )
          .toList();
    }

    // =========================================================
    // SORT
    // =========================================================

    switch (_sort) {
      case _ClinicSort.distance:
        result.sort(
          (a, b) {
            final aDistance =
                a.distanceKm;

            final bDistance =
                b.distanceKm;

            if (aDistance == null &&
                bDistance == null) {
              return 0;
            }

            if (aDistance == null) {
              return 1;
            }

            if (bDistance == null) {
              return -1;
            }

            return aDistance.compareTo(
              bDistance,
            );
          },
        );
        break;

      case _ClinicSort.rating:
        result.sort(
          (a, b) =>
              b.rating.compareTo(
            a.rating,
          ),
        );
        break;
    }

    return result;
  }

  void _openClinic(
    BuildContext context,
    ClinicModel clinic,
  ) {
    context
        .read<ClinicProvider>()
        .selectClinic(
          clinic.id,
        );

    Navigator.of(context).pushNamed(
      AppRoutes.clinicDetails,
    );
  }

  Future<void> _selectDistance(
    ClinicProvider provider,
  ) async {
    setState(() {
      _sort =
          _ClinicSort.distance;
    });

    if (!provider.hasCurrentLocation) {
      await provider.refreshLocation();
    }
  }

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
      _openNowOnly = false;
      _sort =
          _ClinicSort.distance;
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final args =
        ModalRoute.of(context)
                ?.settings
                .arguments
            as Map<String, dynamic>?;

    final selectedCategory =
        args?['category']
            as String?;

    final clinicProvider =
        context.watch<
            ClinicProvider>();

    final filteredClinics =
        _filterClinics(
      clinicProvider.clinics,
      selectedCategory,
    );

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
                icon:
                    const Icon(
                  Icons
                      .arrow_back_ios_new_rounded,
                  color: AppColors
                      .textPrimary,
                ),
                style:
                    IconButton.styleFrom(
                  padding:
                      EdgeInsets.zero,
                ),
              ),

              Expanded(
                child: Text(
                  selectedCategory ==
                          null
                      ? 'Clinics near me'
                      : '$selectedCategory clinics',
                  style:
                      const TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.w800,
                    color: AppColors
                        .textPrimary,
                  ),
                ),
              ),

              IconButton(
                tooltip:
                    'Clear filters',
                onPressed:
                    _clearFilters,
                icon:
                    const Icon(
                  Icons
                      .filter_alt_off_rounded,
                  color: AppColors
                      .textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Column(
          children: [
            // =================================================
            // SEARCH
            // =================================================

            TextField(
              controller:
                  _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery =
                      value;
                });
              },
              decoration:
                  InputDecoration(
                hintText:
                    'Search clinics, specialties or address',
                prefixIcon:
                    const Icon(
                  Icons
                      .search_rounded,
                ),
                suffixIcon:
                    _searchQuery
                            .isEmpty
                        ? null
                        : IconButton(
                            onPressed:
                                () {
                              _searchController
                                  .clear();

                              setState(() {
                                _searchQuery =
                                    '';
                              });
                            },
                            icon:
                                const Icon(
                              Icons
                                  .close_rounded,
                            ),
                          ),
                filled: true,
                fillColor:
                    AppColors.surface,
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  borderSide:
                      const BorderSide(
                    color:
                        AppColors.border,
                  ),
                ),
                enabledBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  borderSide:
                      const BorderSide(
                    color:
                        AppColors.border,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // =================================================
            // LOCATION MESSAGE
            // =================================================

            if (clinicProvider.isLocating)
              const _LocationBanner(
                icon:
                    Icons.my_location_rounded,
                text:
                    'Getting your location...',
                loading:
                    true,
              )
            else if (clinicProvider
                    .locationMessage !=
                null)
              _LocationBanner(
                icon:
                    Icons.location_off_rounded,
                text:
                    clinicProvider
                        .locationMessage!,
                actionText:
                    'Retry',
                onAction: () {
                  clinicProvider
                      .refreshLocation();
                },
              )
            else if (clinicProvider
                .hasCurrentLocation)
              const _LocationBanner(
                icon:
                    Icons.location_on_rounded,
                text:
                    'Clinics are sorted using your current location.',
              ),

            if (clinicProvider.isLocating ||
                clinicProvider
                        .locationMessage !=
                    null ||
                clinicProvider
                    .hasCurrentLocation)
              const SizedBox(
                height: 12,
              ),

            // =================================================
            // FILTERS
            // =================================================

            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                border: Border.all(
                  color:
                      AppColors.border,
                ),
              ),
              child: SizedBox(
                height: 42,
                child:
                    SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label:
                            'Distance',
                        selected:
                            _sort ==
                                _ClinicSort
                                    .distance,
                        onTap: () {
                          _selectDistance(
                            clinicProvider,
                          );
                        },
                      ),
                      _FilterChip(
                        label:
                            'Rating',
                        selected:
                            _sort ==
                                _ClinicSort
                                    .rating,
                        onTap: () {
                          setState(() {
                            _sort =
                                _ClinicSort
                                    .rating;
                          });
                        },
                      ),
                      _FilterChip(
                        label:
                            'Open Now',
                        selected:
                            _openNowOnly,
                        onTap: () {
                          setState(() {
                            _openNowOnly =
                                !_openNowOnly;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // =================================================
            // CONTENT
            // =================================================

            Expanded(
              child:
                  _buildContent(
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
    if (provider.isLoading &&
        provider.clinics.isEmpty) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage !=
        null) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(
            24,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons
                    .error_outline_rounded,
                size: 48,
                color: AppColors
                    .textSecondary,
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                provider
                    .errorMessage!,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color: AppColors
                      .textSecondary,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              FilledButton(
                onPressed:
                    provider
                        .fetchClinics,
                child:
                    const Text(
                  'Try again',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (clinics.isEmpty) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(
            24,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons
                    .search_off_rounded,
                size: 48,
                color: AppColors
                    .textSecondary,
              ),

              const SizedBox(
                height: 12,
              ),

              const Text(
                'No clinics match your filters.',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  color: AppColors
                      .textSecondary,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              TextButton(
                onPressed:
                    _clearFilters,
                child:
                    const Text(
                  'Clear filters',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
          provider.fetchClinics,
      child:
          ListView.separated(
        physics:
            const AlwaysScrollableScrollPhysics(),
        itemCount:
            clinics.length,
        separatorBuilder:
            (_, _) =>
                const SizedBox(
          height: 14,
        ),
        itemBuilder:
            (context, index) {
          final clinic =
              clinics[index];

          return _ClinicListTile(
            clinic:
                clinic,
            onTap: () {
              _openClinic(
                context,
                clinic,
              );
            },
          );
        },
      ),
    );
  }
}

// ===============================================================
// LOCATION BANNER
// ===============================================================

class _LocationBanner
    extends StatelessWidget {
  const _LocationBanner({
    required this.icon,
    required this.text,
    this.loading = false,
    this.actionText,
    this.onAction,
  });

  final IconData icon;
  final String text;

  final bool loading;

  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.primaryLight,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child: Row(
        children: [
          if (loading)
            const SizedBox(
              width: 18,
              height: 18,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          else
            Icon(
              icon,
              size: 19,
              color:
                  AppColors.primaryBlue,
            ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              text,
              style:
                  const TextStyle(
                fontSize: 12,
                color: AppColors
                    .textSecondary,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          if (actionText !=
                  null &&
              onAction !=
                  null)
            TextButton(
              onPressed:
                  onAction,
              child: Text(
                actionText!,
              ),
            ),
        ],
      ),
    );
  }
}

// ===============================================================
// FILTER CHIP
// ===============================================================

class _FilterChip
    extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        right: 10,
      ),
      child: InkWell(
        onTap:
            onTap,
        borderRadius:
            BorderRadius.circular(
          999,
        ),
        child: AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 180,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          alignment:
              Alignment.center,
          decoration:
              BoxDecoration(
            color: selected
                ? AppColors
                    .primaryBlue
                : AppColors
                    .surface,
            borderRadius:
                BorderRadius.circular(
              999,
            ),
            border: Border.all(
              color: selected
                  ? AppColors
                      .primaryBlue
                  : AppColors
                      .border,
            ),
          ),
          child: Text(
            label,
            style:
                TextStyle(
              fontWeight:
                  FontWeight.w700,
              color: selected
                  ? Colors.white
                  : AppColors
                      .textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// CLINIC TILE
// ===============================================================

class _ClinicListTile
    extends StatelessWidget {
  const _ClinicListTile({
    required this.clinic,
    required this.onTap,
  });

  final ClinicModel clinic;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color:
          AppColors.surface,
      borderRadius:
          BorderRadius.circular(
        20,
      ),
      child: InkWell(
        onTap:
            onTap,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        child: Container(
          padding:
              const EdgeInsets.all(
            12,
          ),
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            border: Border.all(
              color:
                  AppColors.border,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
                child: SizedBox(
                  width: 110,
                  height: 110,
                  child: clinic
                          .imageUrl
                          .isNotEmpty
                      ? Image.network(
                          clinic
                              .imageUrl,
                          fit:
                              BoxFit.cover,
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

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            clinic.name,
                            maxLines:
                                1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              fontSize:
                                  18,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ),

                        Text(
                          clinic.openNow
                              ? 'Open'
                              : 'Closed',
                          style:
                              TextStyle(
                            color: clinic
                                    .openNow
                                ? AppColors
                                    .successGreen
                                : AppColors
                                    .warningAmber,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      clinic.specialties
                          .join(', '),
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        color: AppColors
                            .textSecondary,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .star_rounded,
                          color: AppColors
                              .warningAmber,
                          size: 18,
                        ),

                        const SizedBox(
                          width: 4,
                        ),

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

                        const Spacer(),

                        const Icon(
                          Icons
                              .location_on_rounded,
                          size: 14,
                          color: AppColors
                              .textSecondary,
                        ),

                        const SizedBox(
                          width: 3,
                        ),

                        Text(
                          clinic.distance,
                          style:
                              const TextStyle(
                            color: AppColors
                                .textSecondary,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            clinic.address,
                            maxLines:
                                1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              fontSize:
                                  11,
                              color: AppColors
                                  .textSecondary,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal:
                                10,
                            vertical:
                                6,
                          ),
                          decoration:
                              BoxDecoration(
                            color: AppColors
                                .primaryLight,
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
                                  FontWeight
                                      .w700,
                              color: AppColors
                                  .primaryBlue,
                            ),
                          ),
                        ),
                      ],
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
  Widget build(
    BuildContext context,
  ) {
    return Container(
      color:
          AppColors.primaryLight,
      alignment:
          Alignment.center,
      child:
          const Icon(
        Icons
            .local_hospital_rounded,
        color:
            AppColors.primaryBlue,
        size: 44,
      ),
    );
  }
}