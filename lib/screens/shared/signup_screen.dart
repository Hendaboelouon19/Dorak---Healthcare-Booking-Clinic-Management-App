import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() =>
      _SignupScreenState();
}

class _SignupScreenState
    extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _phoneController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider =
        context.read<AuthProvider>();

    final success =
        await authProvider.registerPatient(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(
        AppRoutes.patientHome,
        (route) => false,
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          authProvider.errorMessage ??
              'Could not create account.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
        context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create account',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Join Dorak',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller:
                      _nameController,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText: 'Full name',
                  ),
                  validator: (value) {
                    if (value == null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Please enter your name.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller:
                      _emailController,
                  keyboardType:
                      TextInputType
                          .emailAddress,
                  textInputAction:
                      TextInputAction.next,
                  autocorrect: false,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Email address',
                  ),
                  validator: (value) {
                    final email =
                        value?.trim() ?? '';

                    if (email.isEmpty) {
                      return 'Please enter your email.';
                    }

                    if (!email
                        .contains('@')) {
                      return 'Please enter a valid email.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller:
                      _phoneController,
                  keyboardType:
                      TextInputType.phone,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Phone number',
                  ),
                  validator: (value) {
                    if (value == null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Please enter your phone number.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller:
                      _passwordController,
                  obscureText:
                      _obscurePassword,
                  textInputAction:
                      TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!authProvider
                        .isLoading) {
                      _signup();
                    }
                  },
                  decoration:
                      InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons
                                .visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Please enter a password.';
                    }

                    if (value.length < 6) {
                      return 'Password must be at least 6 characters.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                FilledButton(
                  onPressed:
                      authProvider.isLoading
                          ? null
                          : _signup,
                  child:
                      authProvider.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Text(
                              'Sign up',
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}