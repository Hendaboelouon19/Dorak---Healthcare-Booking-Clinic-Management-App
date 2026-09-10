import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/clinic_provider.dart';
import '../../theme/app_colors.dart';

class ClinicEditScreen extends StatefulWidget {
  const ClinicEditScreen({super.key});

  @override
  State<ClinicEditScreen> createState() =>
      _ClinicEditScreenState();
}

class _ClinicEditScreenState
    extends State<ClinicEditScreen> {

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _workingHoursController;
  late final TextEditingController _assistantController;

  bool _active = true;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController();

    _addressController =
        TextEditingController();

    _workingHoursController =
        TextEditingController();

    _assistantController =
        TextEditingController();

    Future.microtask(() {
      _initializeClinic();
    });
  }

  // =============================================================
  // INITIALIZE
  // =============================================================

  Future<void> _initializeClinic() async {
    final provider =
        context.read<ClinicProvider>();

    final clinic =
        provider.selectedClinic;

    if (clinic == null) {
      return;
    }

    _nameController.text =
        clinic.name;

    _addressController.text =
        clinic.address;

    _workingHoursController.text =
        clinic.workingHours;

    _assistantController.text =
        clinic.assistantName;

    _active =
        clinic.active;

    if (mounted) {
      setState(() {
        _hasInitialized = true;
      });
    }

    // Load doctors belonging to this clinic.
    await provider.fetchDoctors();
  }

  // =============================================================
  // DISPOSE
  // =============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _workingHoursController.dispose();
    _assistantController.dispose();

    super.dispose();
  }

  // =============================================================
  // SAVE
  // =============================================================

  Future<void> _saveClinic() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider =
        context.read<ClinicProvider>();

    final clinic =
        provider.selectedClinic;

    if (clinic == null) {
      _showMessage(
        'No clinic selected.',
        isError: true,
      );

      return;
    }

    final success =
        await provider.updateClinic(
      clinicId: clinic.id,
      name: _nameController.text,
      address: _addressController.text,
      workingHours:
          _workingHoursController.text,
      assistantName:
          _assistantController.text,
      active: _active,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      _showMessage(
        'Clinic updated successfully.',
      );

      Navigator.of(context).pop();
    } else {
      _showMessage(
        provider.errorMessage ??
            'Could not update clinic.',
        isError: true,
      );
    }
  }

  // =============================================================
  // MESSAGE
  // =============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError
                ? Colors.red
                : AppColors.successGreen,
      ),
    );
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<ClinicProvider>();

    final clinic =
        provider.selectedClinic;

    if (clinic == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Clinic Edit',
          ),
        ),
        body: const Center(
          child: Text(
            'No clinic selected.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Clinic',
        ),
      ),

      body: !_hasInitialized
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,

              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,

                  children: [

                    // =================================================
                    // CLINIC HEADER
                    // =================================================

                    _ClinicHeader(
                      name: clinic.name,
                      isOpen: clinic.openNow,
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // CLINIC INFORMATION
                    // =================================================

                    const _SectionTitle(
                      title:
                          'Clinic Information',
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller:
                          _nameController,

                      textInputAction:
                          TextInputAction.next,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Clinic name',
                        prefixIcon:
                            Icon(
                          Icons
                              .local_hospital_outlined,
                        ),
                      ),

                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter clinic name.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller:
                          _addressController,

                      textInputAction:
                          TextInputAction.next,

                      maxLines: 2,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Address',
                        prefixIcon:
                            Icon(
                          Icons
                              .location_on_outlined,
                        ),
                        alignLabelWithHint:
                            true,
                      ),

                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter address.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller:
                          _workingHoursController,

                      textInputAction:
                          TextInputAction.next,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Working hours',
                        hintText:
                            'e.g. Mon-Sat · 9:00 AM - 9:00 PM',
                        prefixIcon:
                            Icon(
                          Icons
                              .schedule_outlined,
                        ),
                      ),

                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter working hours.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller:
                          _assistantController,

                      textInputAction:
                          TextInputAction.done,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Assigned assistant',
                        prefixIcon:
                            Icon(
                          Icons
                              .person_outline_rounded,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // STATUS
                    // =================================================

                    const _SectionTitle(
                      title:
                          'Clinic Status',
                    ),

                    const SizedBox(height: 12),

                    Card(
                      margin:
                          EdgeInsets.zero,

                      child: SwitchListTile(
                        value: _active,

                        onChanged: (value) {
                          setState(() {
                            _active = value;
                          });
                        },

                        title: const Text(
                          'Clinic Active',
                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        subtitle: Text(
                          _active
                              ? 'This clinic is active on the platform.'
                              : 'This clinic is inactive on the platform.',
                        ),

                        secondary: Icon(
                          _active
                              ? Icons
                                  .check_circle_outline
                              : Icons
                                  .pause_circle_outline,

                          color:
                              _active
                                  ? AppColors
                                      .successGreen
                                  : AppColors
                                      .warningAmber,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // CLINIC STATS
                    // =================================================

                    const _SectionTitle(
                      title:
                          'Clinic Overview',
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [

                        Expanded(
                          child:
                              _InfoCard(
                            icon:
                                Icons
                                    .people_outline_rounded,

                            title:
                                'Current Queue',

                            value:
                                '${clinic.currentQueue}',
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child:
                              _InfoCard(
                            icon:
                                Icons
                                    .star_outline_rounded,

                            title:
                                'Rating',

                            value:
                                clinic.rating
                                    .toStringAsFixed(
                                      1,
                                    ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // DOCTORS
                    // =================================================

                    Row(
                      children: [

                        const Expanded(
                          child:
                              _SectionTitle(
                            title:
                                'Doctors',
                          ),
                        ),

                        if (provider
                            .isLoadingDoctors)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _buildDoctors(
                      provider,
                    ),

                    const SizedBox(height: 32),

                    // =================================================
                    // ACTIONS
                    // =================================================

                    Row(
                      children: [

                        Expanded(
                          child:
                              OutlinedButton(
                            onPressed:
                                provider.isLoading
                                    ? null
                                    : () {
                                        Navigator.of(
                                          context,
                                        ).pop();
                                      },

                            child:
                                const Text(
                              'Cancel',
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child:
                              FilledButton(
                            onPressed:
                                provider.isLoading
                                    ? null
                                    : _saveClinic,

                            child:
                                provider.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth:
                                              2,
                                        ),
                                      )
                                    : const Text(
                                        'Save Changes',
                                      ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  // =============================================================
  // DOCTORS
  // =============================================================

  Widget _buildDoctors(
    ClinicProvider provider,
  ) {
    if (provider.isLoadingDoctors) {
      return const Center(
        child: Padding(
          padding:
              EdgeInsets.all(20),
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (provider.doctorErrorMessage != null) {
      return Card(
        child: Padding(
          padding:
              const EdgeInsets.all(16),

          child: Column(
            children: [

              const Icon(
                Icons.error_outline,
                size: 36,
              ),

              const SizedBox(height: 8),

              Text(
                provider
                    .doctorErrorMessage!,
                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed:
                    provider.fetchDoctors,

                child:
                    const Text(
                  'Try Again',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.doctors.isEmpty) {
      return Card(
        child: Padding(
          padding:
              const EdgeInsets.all(20),

          child: Column(
            children: [

              const Icon(
                Icons
                    .medical_services_outlined,
                size: 40,
              ),

              const SizedBox(height: 10),

              const Text(
                'No active doctors found.',
                style:
                    TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Doctors assigned to this clinic will appear here.',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  color:
                      AppColors
                          .textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children:
          provider.doctors.map(
        (doctor) {
          return Card(
            margin:
                const EdgeInsets.only(
              bottom: 10,
            ),

            child: ListTile(
              leading:
                  CircleAvatar(
                child: const Icon(
                  Icons
                      .medical_services_outlined,
                ),
              ),

              title: Text(
                doctor.name,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              subtitle: Text(
                doctor.specialty,
              ),

              trailing:
                  const Icon(
                Icons
                    .chevron_right_rounded,
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}

// ===============================================================
// CLINIC HEADER
// ===============================================================

class _ClinicHeader
    extends StatelessWidget {
  const _ClinicHeader({
    required this.name,
    required this.isOpen,
  });

  final String name;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        isOpen
            ? AppColors.successGreen
            : AppColors.warningAmber;

    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(20),

        color:
            Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
      ),

      child: Row(
        children: [

          CircleAvatar(
            radius: 28,

            child: const Icon(
              Icons
                  .local_hospital_rounded,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  name,
                  style:
                      const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [

                    Container(
                      width: 8,
                      height: 8,

                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color:
                            statusColor,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Text(
                      isOpen
                          ? 'Open now'
                          : 'Closed',

                      style:
                          TextStyle(
                        color:
                            statusColor,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
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
// SECTION TITLE
// ===============================================================

class _SectionTitle
    extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,

      style:
          const TextStyle(
        fontSize: 18,
        fontWeight:
            FontWeight.w800,
      ),
    );
  }
}

// ===============================================================
// INFO CARD
// ===============================================================

class _InfoCard
    extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          EdgeInsets.zero,

      child: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Icon(
              icon,
              size: 24,
            ),

            const SizedBox(height: 12),

            Text(
              value,
              style:
                  const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              title,
              style:
                  const TextStyle(
                color:
                    AppColors
                        .textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}