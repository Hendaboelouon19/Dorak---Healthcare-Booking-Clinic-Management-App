import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class GeneralAppSettingsScreen extends StatefulWidget {
  const GeneralAppSettingsScreen({super.key});

  @override
  State<GeneralAppSettingsScreen> createState() =>
      _GeneralAppSettingsScreenState();
}

class _GeneralAppSettingsScreenState
    extends State<GeneralAppSettingsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController _appNameController =
      TextEditingController();

  final TextEditingController _appointmentDurationController =
      TextEditingController();

  final TextEditingController _maxQueueSizeController =
      TextEditingController();

  final TextEditingController _consultationTimeController =
      TextEditingController();

  bool _allowSameDayBooking = true;
  bool _allowCancellation = true;
  bool _maintenanceMode = false;

  bool _loading = true;
  bool _saving = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _appointmentDurationController.dispose();
    _maxQueueSizeController.dispose();
    _consultationTimeController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // LOAD SETTINGS
  // ==========================================================================

  Future<void> _loadSettings() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final doc = await _firestore
          .collection('platformSettings')
          .doc('general')
          .get();

      final data = doc.data();

      if (!mounted) return;

      if (data == null) {
        _appNameController.text = 'Dorak';
        _appointmentDurationController.text = '30';
        _maxQueueSizeController.text = '20';
        _consultationTimeController.text = '15';

        _allowSameDayBooking = true;
        _allowCancellation = true;
        _maintenanceMode = false;
      } else {
        _appNameController.text =
            data['appName']?.toString() ?? 'Dorak';

        _appointmentDurationController.text =
            data['appointmentDuration']?.toString() ?? '30';

        _maxQueueSizeController.text =
            data['maxQueueSize']?.toString() ?? '20';

        _consultationTimeController.text =
            data['defaultConsultationTime']?.toString() ?? '15';

        _allowSameDayBooking =
            data['allowSameDayBooking'] != false;

        _allowCancellation =
            data['allowCancellation'] != false;

        _maintenanceMode =
            data['maintenanceMode'] == true;
      }

      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage =
            'Failed to load general app settings.';
      });
    }
  }

  // ==========================================================================
  // SAVE SETTINGS
  // ==========================================================================

  Future<void> _saveSettings() async {
    final appName =
        _appNameController.text.trim();

    final appointmentDuration = int.tryParse(
      _appointmentDurationController.text.trim(),
    );

    final maxQueueSize = int.tryParse(
      _maxQueueSizeController.text.trim(),
    );

    final consultationTime = int.tryParse(
      _consultationTimeController.text.trim(),
    );

    if (appName.isEmpty) {
      _showMessage(
        'Please enter the app name.',
        isError: true,
      );
      return;
    }

    if (appointmentDuration == null ||
        appointmentDuration <= 0) {
      _showMessage(
        'Please enter a valid appointment duration.',
        isError: true,
      );
      return;
    }

    if (maxQueueSize == null ||
        maxQueueSize <= 0) {
      _showMessage(
        'Please enter a valid maximum queue size.',
        isError: true,
      );
      return;
    }

    if (consultationTime == null ||
        consultationTime <= 0) {
      _showMessage(
        'Please enter a valid consultation time.',
        isError: true,
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _firestore
          .collection('platformSettings')
          .doc('general')
          .set(
        {
          'appName': appName,
          'appointmentDuration':
              appointmentDuration,
          'maxQueueSize': maxQueueSize,
          'defaultConsultationTime':
              consultationTime,
          'allowSameDayBooking':
              _allowSameDayBooking,
          'allowCancellation':
              _allowCancellation,
          'maintenanceMode':
              _maintenanceMode,
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage(
        'General app settings saved successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage(
        'Failed to save general app settings.',
        isError: true,
      );
    }
  }

  // ==========================================================================
  // MESSAGE
  // ==========================================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red
            : AppColors.successGreen,
      ),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

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
        title: const Text(
          'General App Settings',
        ),
      ),
      body: _buildBody(),
    );
  }

  // ==========================================================================
  // BODY
  // ==========================================================================

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        30,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildIntroCard(),

          const SizedBox(height: 20),

          const Text(
            'Platform Information',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          _buildAppNameField(),

          const SizedBox(height: 24),

          const Text(
            'Queue Settings',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          _buildAppointmentDurationField(),

          const SizedBox(height: 12),

          _buildConsultationTimeField(),

          const SizedBox(height: 12),

          _buildMaxQueueSizeField(),

          const SizedBox(height: 24),

          const Text(
            'Booking Settings',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          _buildBookingSettings(),

          const SizedBox(height: 24),

          const Text(
            'Platform Status',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          _buildMaintenanceSetting(),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed:
                  _saving ? null : _saveSettings,
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.save_rounded,
                    ),
              label: Text(
                _saving
                    ? 'Saving...'
                    : 'Save Settings',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // INTRO CARD
  // ==========================================================================

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(
          alpha: 0.06,
        ),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.settings_suggest_rounded,
            color: AppColors.primaryBlue,
            size: 25,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Manage the global settings that control '
              'the QueueLess platform.',
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // APP NAME
  // ==========================================================================

  Widget _buildAppNameField() {
    return _SettingsCard(
      icon: Icons.apps_rounded,
      title: 'App Name',
      child: TextField(
        controller: _appNameController,
        decoration: const InputDecoration(
          labelText: 'Application Name',
          hintText: 'Dorak',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  // ==========================================================================
  // APPOINTMENT DURATION
  // ==========================================================================

  Widget _buildAppointmentDurationField() {
    return _SettingsCard(
      icon: Icons.schedule_rounded,
      title: 'Default Appointment Duration',
      child: TextField(
        controller:
            _appointmentDurationController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Duration in minutes',
          hintText: '30',
          suffixText: 'min',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  // ==========================================================================
  // CONSULTATION TIME
  // ==========================================================================

  Widget _buildConsultationTimeField() {
    return _SettingsCard(
      icon: Icons.timer_outlined,
      title: 'Default Consultation Time',
      child: TextField(
        controller:
            _consultationTimeController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText:
              'Estimated consultation time',
          hintText: '15',
          suffixText: 'min',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  // ==========================================================================
  // MAX QUEUE SIZE
  // ==========================================================================

  Widget _buildMaxQueueSizeField() {
    return _SettingsCard(
      icon: Icons.people_alt_rounded,
      title: 'Maximum Queue Size',
      child: TextField(
        controller:
            _maxQueueSizeController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText:
              'Maximum patients in queue',
          hintText: '20',
          suffixText: 'patients',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  // ==========================================================================
  // BOOKING SETTINGS
  // ==========================================================================

  Widget _buildBookingSettings() {
    return Container(
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
          SwitchListTile(
            title: const Text(
              'Allow same-day booking',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: const Text(
              'Patients can book appointments '
              'for today.',
            ),
            value: _allowSameDayBooking,
            onChanged: (value) {
              setState(() {
                _allowSameDayBooking = value;
              });
            },
          ),

          const Divider(height: 1),

          SwitchListTile(
            title: const Text(
              'Allow appointment cancellation',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: const Text(
              'Patients can cancel their '
              'appointments.',
            ),
            value: _allowCancellation,
            onChanged: (value) {
              setState(() {
                _allowCancellation = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // MAINTENANCE MODE
  // ==========================================================================

  Widget _buildMaintenanceSetting() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: _maintenanceMode
              ? Colors.orange.withValues(
                  alpha: 0.35,
                )
              : AppColors.border,
        ),
      ),
      child: SwitchListTile(
        title: const Text(
          'Maintenance Mode',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: const Text(
          'Temporarily disable platform access '
          'while maintenance is being performed.',
        ),
        value: _maintenanceMode,
        onChanged: (value) {
          setState(() {
            _maintenanceMode = value;
          });
        },
      ),
    );
  }

  // ==========================================================================
  // ERROR STATE
  // ==========================================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red,
            ),

            const SizedBox(height: 14),

            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 18),

            FilledButton.icon(
              onPressed: _loadSettings,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SETTINGS CARD
// ============================================================================

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primaryBlue,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          child,
        ],
      ),
    );
  }
}