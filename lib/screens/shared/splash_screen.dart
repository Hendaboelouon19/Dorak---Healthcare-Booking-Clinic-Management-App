import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(
      0.0,
      0.55,
      curve: Curves.easeOutBack,
    ),
  );

  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(
      0.0,
      0.4,
      curve: Curves.easeOut,
    ),
  );

  late final Animation<double> _wordmarkFade = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(
      0.35,
      0.65,
      curve: Curves.easeOut,
    ),
  );

  late final Animation<double> _taglineFade = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(
      0.55,
      0.8,
      curve: Curves.easeOut,
    ),
  );

  late final Animation<double> _buttonFade = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(
      0.75,
      1.0,
      curve: Curves.easeOut,
    ),
  );

  bool _isCheckingSession = false;

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_isCheckingSession) {
      return;
    }

    setState(() {
      _isCheckingSession = true;
    });

    final authProvider = context.read<AuthProvider>();

    final restored = await authProvider.restoreSession();

    if (!mounted) {
      return;
    }

    if (!restored) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.login,
      );

      return;
    }

    switch (authProvider.currentRole) {
      case UserRole.patient:
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.patientHome,
        );
        break;

      case UserRole.assistant:
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.assistantDashboard,
        );
        break;

      case UserRole.admin:
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.adminDashboard,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlueDark,
              AppColors.primaryBlue,
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -80,
              right: -60,
              child: _Glow(
                size: 220,
                opacity: 0.10,
              ),
            ),

            const Positioned(
              bottom: -100,
              left: -70,
              child: _Glow(
                size: 260,
                opacity: 0.08,
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: AnimatedBuilder(
                          animation: _pulse,
                          builder: (context, child) {
                            final t = _pulse.value;

                            final ringScale =
                                1.0 + (t * 0.35);

                            final ringOpacity =
                                (1.0 - t)
                                        .clamp(0.0, 1.0) *
                                    0.5;

                            return SizedBox(
                              width: 190,
                              height: 190,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Transform.scale(
                                    scale: ringScale,
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: ringOpacity,
                                          ),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),

                                  child!,
                                ],
                              ),
                            );
                          },
                          child: Container(
                            width: 148,
                            height: 148,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 30,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/logo/dowrak_logo_transparent.svg',
                                width: 78,
                                height: 78,
                                semanticsLabel: 'Dorak logo',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    FadeTransition(
                      opacity: _wordmarkFade,
                      child: const Text(
                        'Dorak',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    FadeTransition(
                      opacity: _taglineFade,
                      child: const Text(
                        'Smart clinic queue &\nappointment management',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    ),

                    const Spacer(flex: 4),

                    FadeTransition(
                      opacity: _buttonFade,
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed:
                              _isCheckingSession ? null : _continue,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor:
                                AppColors.primaryBlueDark,
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(18),
                            ),
                          ),
                          child: _isCheckingSession
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        AppColors.primaryBlueDark,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({
    required this.size,
    required this.opacity,
  });

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(
          alpha: opacity,
        ),
      ),
    );
  }
}