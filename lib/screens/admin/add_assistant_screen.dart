import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../providers/clinic_provider.dart';

class AddAssistantScreen extends StatefulWidget {
  const AddAssistantScreen({super.key});

  @override
  State<AddAssistantScreen> createState() =>
      _AddAssistantScreenState();
}

class _AddAssistantScreenState
    extends State<AddAssistantScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedClinicId;
  bool _active = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final clinicProvider = context.read<ClinicProvider>();

    Future.microtask(() async {
      await clinicProvider.fetchAllClinicsForAdmin();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _addAssistant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final adminProvider = context.read<AdminProvider>();

    final success = await adminProvider.addAssistant(
      name: _nameController.text,
      email: _emailController.text,
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
          content: Text('Assistant added successfully.'),
        ),
      );

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            adminProvider.errorMessage ??
                'Could not add assistant.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clinicProvider = context.watch<ClinicProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Assistant'),
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
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the assistant name.';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter assistant email',
              ),
              validator: (value) {
                final email = value?.trim() ?? '';

                if (email.isEmpty) {
                  return 'Please enter the email.';
                }

                if (!email.contains('@')) {
                  return 'Please enter a valid email.';
                }

                return null;
              },
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
                if (value == null || value.trim().isEmpty) {
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
                onPressed: _isSaving ? null : _addAssistant,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Add Assistant',
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