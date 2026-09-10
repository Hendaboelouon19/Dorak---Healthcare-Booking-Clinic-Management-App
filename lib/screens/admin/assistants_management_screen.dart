import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../providers/clinic_provider.dart';
import '../../providers/admin_provider.dart';
import '../../routes/app_routes.dart';

class AssistantsManagementScreen extends StatefulWidget {
  const AssistantsManagementScreen({super.key});

  @override
  State<AssistantsManagementScreen> createState() =>
      _AssistantsManagementScreenState();
}

class _AssistantsManagementScreenState
    extends State<AssistantsManagementScreen> {

  @override
  void initState() {
    super.initState();

    final adminProvider = context.read<AdminProvider>();
    final clinicProvider = context.read<ClinicProvider>();

    Future.microtask(() async {
      await clinicProvider.fetchAllClinicsForAdmin();

      if (!mounted) return;

      await adminProvider.fetchAssistants();
    });
  }

  // =========================================================
  // OPEN ADD ASSISTANT
  // =========================================================

  Future<void> _openAddAssistant() async {
    await Navigator.of(context).pushNamed(
      '/add-assistant',
    );

    if (!mounted) return;

    await context.read<AdminProvider>().fetchAssistants();
  }

  // =========================================================
  // BACK
  // =========================================================

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final clinicProvider = context.watch<ClinicProvider>();

    // =========================================================
    // LOADING
    // =========================================================

    if (adminProvider.isLoading || clinicProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBack,
          ),
          title: const Text('Assistants Management'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // =========================================================
    // ERROR
    // =========================================================

    if (adminProvider.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBack,
          ),
          title: const Text('Assistants Management'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 50,
                ),

                const SizedBox(height: 16),

                Text(
                  adminProvider.errorMessage!,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () {
                    adminProvider.fetchAssistants();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // =========================================================
    // EMPTY STATE
    // =========================================================

    if (adminProvider.assistants.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBack,
          ),
          title: const Text('Assistants Management'),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: _openAddAssistant,
          child: const Icon(Icons.add),
        ),

        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline_rounded,
                size: 60,
              ),

              SizedBox(height: 16),

              Text(
                'No assistants available.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // =========================================================
    // MAIN SCREEN
    // =========================================================

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        title: const Text('Assistants Management'),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openAddAssistant,
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: adminProvider.assistants.length,
          itemBuilder: (context, index) {
            final assistant =
                adminProvider.assistants[index];

            final clinicId =
                assistant['clinicId'];

            String clinicName = 'Not assigned';

            if (clinicId != null) {
              for (final clinic in clinicProvider.clinics) {
                if (clinic.id == clinicId) {
                  clinicName = clinic.name;
                  break;
                }
              }
            }

            final isActive =
                assistant['active'] == true;

            return _AssistantTile(
              name: assistant['name'] ?? '',
              clinic: clinicName,
              status: isActive
                  ? 'Active'
                  : 'Inactive',
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.assistantEdit,
                  arguments: assistant,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ===============================================================
// ASSISTANT TILE
// ===============================================================

class _AssistantTile extends StatelessWidget {
  const _AssistantTile({
    required this.name,
    required this.clinic,
    required this.status,
    required this.onTap,
  });

  final String name;
  final String clinic;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const CircleAvatar(
                child: Icon(
                  Icons.person_outline_rounded,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      clinic,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: status == 'Active'
                      ? AppColors.successGreen
                          .withValues(alpha: 0.12)
                      : AppColors.warningAmber
                          .withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Active'
                        ? AppColors.successGreen
                        : AppColors.warningAmber,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}