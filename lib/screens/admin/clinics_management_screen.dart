import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../providers/clinic_provider.dart';
import '../../theme/app_colors.dart';
import '../../routes/app_routes.dart';

class ClinicsManagementScreen extends StatefulWidget {
  const ClinicsManagementScreen({super.key});

  @override
  State<ClinicsManagementScreen> createState() =>
      _ClinicsManagementScreenState();
}

class _ClinicsManagementScreenState
    extends State<ClinicsManagementScreen> {
  @override
  void initState() {
    super.initState();

    final clinicProvider = context.read<ClinicProvider>();
    final adminProvider = context.read<AdminProvider>();

    Future.microtask(() async {
      await clinicProvider.fetchAllClinicsForAdmin();

      if (!mounted) return;

      await adminProvider.loadDashboard();
    });
  }

  // ===========================================================
  // OPEN ADD CLINIC
  // ===========================================================

  Future<void> _openAddClinic() async {
    await Navigator.of(context).pushNamed(
      AppRoutes.addClinic,
    );

    if (!mounted) return;

    final clinicProvider = context.read<ClinicProvider>();
    final adminProvider = context.read<AdminProvider>();

    // Refresh clinics immediately after returning
    await clinicProvider.fetchAllClinicsForAdmin();

    if (!mounted) return;

    // Refresh appointment counts and dashboard data
    await adminProvider.loadDashboard();
  }

  // ===========================================================
  // BACK
  // ===========================================================

  void _goBack() {
    Navigator.of(context).pop();
  }

  // ===========================================================
  // APP BAR
  // ===========================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _goBack,
      ),
      title: const Text(
        'Clinics Management',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clinicProvider =
        context.watch<ClinicProvider>();

    final adminProvider =
        context.watch<AdminProvider>();

    // ===========================================================
    // LOADING
    // ===========================================================

    if (clinicProvider.isLoading ||
        adminProvider.isLoading) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ===========================================================
    // ERROR
    // ===========================================================

    if (clinicProvider.errorMessage != null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: _ErrorState(
          message: clinicProvider.errorMessage!,
          onRetry: () async {
            await clinicProvider
                .fetchAllClinicsForAdmin();

            if (!mounted) return;

            await adminProvider.loadDashboard();
          },
        ),
      );
    }

    // ===========================================================
    // EMPTY
    // ===========================================================

    if (clinicProvider.clinics.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        floatingActionButton:
            _buildAddButton(),
        body: RefreshIndicator(
          onRefresh: () async {
            await clinicProvider
                .fetchAllClinicsForAdmin();

            if (!mounted) return;

            await adminProvider.loadDashboard();
          },
          child: ListView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 180),
              Center(
                child: Text(
                  'No clinics available.',
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ===========================================================
    // MAIN SCREEN
    // ===========================================================

    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton:
          _buildAddButton(),
      body: RefreshIndicator(
        onRefresh: () async {
          await clinicProvider
              .fetchAllClinicsForAdmin();

          if (!mounted) return;

          await adminProvider.loadDashboard();
        },
        child: ListView.builder(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.all(16),
          itemCount:
              clinicProvider.clinics.length,
          itemBuilder:
              (context, index) {
            final clinic =
                clinicProvider.clinics[index];

            final appointmentCount =
                adminProvider
                        .appointmentsByClinic[
                    clinic.name] ??
                    0;

            return _ClinicRow(
              name: clinic.name,
              assistant:
                  clinic.assistantName
                          .trim()
                      .isEmpty
                  ? 'Not assigned'
                  : clinic.assistantName,
              status:
                  clinic.active
                      ? 'Active'
                      : 'Inactive',
              isOpen:
                  clinic.openNow,
              appointments:
                  appointmentCount,
              currentQueue:
                  clinic.currentQueue,
              onTap: () {
                clinicProvider
                    .selectClinic(
                  clinic.id,
                );

                Navigator.of(context)
                    .pushNamed(
                  '/clinic-edit',
                );
              },
            );
          },
        ),
      ),
    );
  }

  // =============================================================
  // ADD BUTTON
  // =============================================================

  Widget _buildAddButton() {
    return FloatingActionButton(
      onPressed: _openAddClinic,
      child: const Icon(
        Icons.add,
      ),
    );
  }
}

// ===============================================================
// CLINIC ROW
// ===============================================================

class _ClinicRow extends StatelessWidget {
  const _ClinicRow({
    required this.name,
    required this.assistant,
    required this.status,
    required this.isOpen,
    required this.appointments,
    required this.currentQueue,
    required this.onTap,
  });

  final String name;
  final String assistant;
  final String status;
  final bool isOpen;
  final int appointments;
  final int currentQueue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        status == 'Active'
            ? AppColors.successGreen
            : AppColors.warningAmber;

    final openColor =
        isOpen
            ? AppColors.successGreen
            : AppColors.warningAmber;

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(20),
        child: Padding(
          padding:
              const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // =================================================
              // TOP ROW
              // =================================================

              Row(
                children: [
                  // Clinic Icon
                  CircleAvatar(
                    child: const Icon(
                      Icons.local_hospital_rounded,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Name
                  Expanded(
                    child: Text(
                      name,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  // Active / Inactive
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color: statusColor
                          .withValues(
                        alpha: 0.12,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        999,
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // =================================================
              // ASSISTANT
              // =================================================

              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 18,
                    color:
                        AppColors.textSecondary,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Assistant: $assistant',
                      style:
                          const TextStyle(
                        color:
                            AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // =================================================
              // APPOINTMENTS
              // =================================================

              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color:
                        AppColors.textSecondary,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '$appointments appointments',
                    style:
                        const TextStyle(
                      color:
                          AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // =================================================
              // QUEUE + OPEN STATUS
              // =================================================

              Row(
                children: [
                  const Icon(
                    Icons.people_outline_rounded,
                    size: 18,
                    color:
                        AppColors.textSecondary,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Queue: $currentQueue',
                    style:
                        const TextStyle(
                      color:
                          AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),

                  // Open / Closed
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration:
                        BoxDecoration(
                      color: openColor
                          .withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        999,
                      ),
                    ),
                    child: Text(
                      isOpen
                          ? 'Open'
                          : 'Closed',
                      style: TextStyle(
                        color: openColor,
                        fontWeight:
                            FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
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

// ===============================================================
// ERROR STATE
// ===============================================================

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 50,
            ),

            const SizedBox(height: 16),

            Text(
              message,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: onRetry,
              child:
                  const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}