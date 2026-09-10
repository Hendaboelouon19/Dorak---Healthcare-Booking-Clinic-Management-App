import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/clinic_provider.dart';
import '../../theme/app_colors.dart';

class AddClinicScreen extends StatefulWidget {
  const AddClinicScreen({super.key});

  @override
  State<AddClinicScreen> createState() =>
      _AddClinicScreenState();
}

class _AddClinicScreenState
    extends State<AddClinicScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final _addressController =
      TextEditingController();

  final _specialtiesController =
      TextEditingController();

  final _workingHoursController =
      TextEditingController();

  final _assistantController =
      TextEditingController();

  final _latitudeController =
      TextEditingController();

  final _longitudeController =
      TextEditingController();

  bool _active = true;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _specialtiesController.dispose();
    _workingHoursController.dispose();
    _assistantController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();

    super.dispose();
  }

  // =============================================================
  // ADD CLINIC
  // =============================================================

  Future<void> _addClinic() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider =
        context.read<ClinicProvider>();

    final specialties = _specialtiesController
        .text
        .split(',')
        .map((specialty) => specialty.trim())
        .where((specialty) => specialty.isNotEmpty)
        .toList();

    double? latitude =
        double.tryParse(
      _latitudeController.text.trim(),
    );

    double? longitude =
        double.tryParse(
      _longitudeController.text.trim(),
    );

    final success =
        await provider.addClinic(
      name: _nameController.text,
      address: _addressController.text,
      specialties: specialties,
      workingHours:
          _workingHoursController.text,
      assistantName:
          _assistantController.text,
      active: _active,
      latitude: latitude,
      longitude: longitude,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Clinic added successfully.',
          ),
          backgroundColor:
              AppColors.successGreen,
        ),
      );

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Could not add clinic.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<ClinicProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Clinic',
        ),
      ),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [

              // =================================================
              // CLINIC INFORMATION
              // =================================================

              const Text(
                'Clinic Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _nameController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Clinic name',
                  prefixIcon: Icon(
                    Icons
                        .local_hospital_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return
                        'Please enter clinic name.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _addressController,
                maxLines: 2,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Address',
                  prefixIcon: Icon(
                    Icons
                        .location_on_outlined,
                  ),
                  alignLabelWithHint:
                      true,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return
                        'Please enter address.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _specialtiesController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Specialties',
                  hintText:
                      'e.g. Cardiology, Pediatrics, Dentistry',
                  prefixIcon: Icon(
                    Icons
                        .medical_services_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return
                        'Please enter at least one specialty.';
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
                  prefixIcon: Icon(
                    Icons
                        .schedule_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return
                        'Please enter working hours.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _assistantController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Assigned assistant',
                  hintText:
                      'Optional',
                  prefixIcon: Icon(
                    Icons
                        .person_outline_rounded,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // =================================================
              // LOCATION
              // =================================================

              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Optional. Add latitude and longitude if available.',
                style: TextStyle(
                  color:
                      AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [

                  Expanded(
                    child: TextFormField(
                      controller:
                          _latitudeController,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Latitude',
                        prefixIcon: Icon(
                          Icons
                              .north_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: TextFormField(
                      controller:
                          _longitudeController,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Longitude',
                        prefixIcon: Icon(
                          Icons
                              .east_outlined,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // =================================================
              // STATUS
              // =================================================

              const Text(
                'Clinic Status',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              Card(
                margin: EdgeInsets.zero,
                child: SwitchListTile(
                  value: _active,

                  onChanged: (value) {
                    setState(() {
                      _active = value;
                    });
                  },

                  title: const Text(
                    'Clinic Active',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  subtitle: Text(
                    _active
                        ? 'This clinic will be active on the platform.'
                        : 'This clinic will be inactive on the platform.',
                  ),

                  secondary: Icon(
                    _active
                        ? Icons
                            .check_circle_outline
                        : Icons
                            .pause_circle_outline,
                    color: _active
                        ? AppColors
                            .successGreen
                        : AppColors
                            .warningAmber,
                  ),
                ),
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
                      child: const Text(
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
                              : _addClinic,
                      child:
                          provider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Add Clinic',
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
}