import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../providers/clinic_provider.dart';

class AssistantEditScreen extends StatefulWidget {
  const AssistantEditScreen({
    super.key,
    required this.assistant,
  });

  final Map<String, dynamic> assistant;

  @override
  State<AssistantEditScreen> createState() =>
      _AssistantEditScreenState();
}

class _AssistantEditScreenState
    extends State<AssistantEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  String? _selectedClinicId;
  late bool _active;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.assistant['name']?.toString() ?? '',
    );

    _phoneController = TextEditingController(
      text: widget.assistant['phone']?.toString() ?? '',
    );

    _selectedClinicId =
        widget.assistant['clinicId']?.toString();

    _active = widget.assistant['active'] == true;

    final clinicProvider = context.read<ClinicProvider>();

    Future.microtask(() async {
      await clinicProvider.fetchAllClinicsForAdmin();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final adminProvider = context.read<AdminProvider>();

    final success = await adminProvider.updateAssistant(
      assistantId: widget.assistant['id'].toString(),
      name: _nameController.text,
      phone: _phoneController.text,
      clinicId: _selectedClinicId,
      active: _active,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Assistant updated successfully.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            adminProvider.errorMessage ??
                'Could not update assistant.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clinicProvider = context.watch<ClinicProvider>();

    final email =
        widget.assistant['email']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Assistant'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Assistant Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter assistant name',
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter the assistant name.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: email,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: 'Enter assistant phone',
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter the phone number.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectedClinicId,
              decoration: const InputDecoration(
                labelText: 'Clinic',
              ),
              items: clinicProvider.clinics.map((clinic) {
                return DropdownMenuItem<String>(
                  value: clinic.id,
                  child: Text(clinic.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClinicId = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a clinic.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Active Assistant',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              value: _active,
              onChanged: (value) {
                setState(() {
                  _active = value;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed:
                    _isSaving ? null : _saveChanges,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: _isSaving
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}