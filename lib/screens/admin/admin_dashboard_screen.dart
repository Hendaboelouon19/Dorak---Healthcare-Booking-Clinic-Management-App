import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../theme/app_colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {

  @override
  void initState() {
    super.initState();

    final adminProvider = context.read<AdminProvider>();

    Future.microtask(() {
      adminProvider.loadDashboard();
    });
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    if (admin.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (admin.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(admin.errorMessage!),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),

      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Admin',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FirebaseAuth.instance.currentUser?.email ??
                          'admin@dorak.com',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.dashboard_rounded),
                title: const Text('Dashboard'),
                selected: true,
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),

              ListTile(
                leading: const Icon(Icons.business_rounded),
                title: const Text('Clinics Management'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(
                    '/clinics-management',
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.people_alt_rounded),
                title: const Text('Assistants Management'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(
                    '/assistants-management',
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.analytics_outlined),
                title: const Text('Clinic Performance'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(
                    '/clinic-performance',
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.settings_rounded),
                title: const Text('Platform Settings'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(
                    '/platform-settings',
                  );
                },
              ),

              const Spacer(),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: _logout,
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () {
          return context
              .read<AdminProvider>()
              .loadDashboard();
        },

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              // =================================================
              // PLATFORM OVERVIEW
              // =================================================

              const Text(
                'Platform overview',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // MAIN STATS
              // =================================================

              Row(
                children: [

                  _StatCard(
                    title: 'Total Clinics',
                    value: admin.totalClinics.toString(),
                    trend: '',
                  ),

                  const SizedBox(width: 12),

                  _StatCard(
                    title: 'Appointments',
                    value: admin.totalAppointments.toString(),
                    trend: '',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // =================================================
              // USERS + AVG WAIT
              // =================================================

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  _UsersCard(
                    totalUsers: admin.totalUsers,
                    patients: admin.patientsCount,
                    assistants: admin.assistantsCount,
                    admins: admin.adminsCount,
                  ),

                  const SizedBox(width: 12),

                  _StatCard(
                    title: 'Avg Wait',
                    value:
                        '${admin.averageWaitMinutes.toStringAsFixed(1)}m',
                    trend: '',
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // =================================================
              // USERS BY ROLE
              // =================================================

              const Text(
                'Users by Role',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 220,

                child: BarChart(
                  BarChartData(

                    // =================================================
                    // USERS TOOLTIP
                    // =================================================

                    barTouchData: BarTouchData(
                      enabled: true,

                      touchTooltipData:
                          BarTouchTooltipData(
                        getTooltipItem:
                            (group, groupIndex, rod, rodIndex) {

                          String role;

                          switch (groupIndex) {
                            case 0:
                              role = 'Patients';
                              break;

                            case 1:
                              role = 'Assistants';
                              break;

                            case 2:
                              role = 'Admins';
                              break;

                            default:
                              return null;
                          }

                          return BarTooltipItem(
                            '$role\n'
                            '${rod.toY.toInt()} users',
                            const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                    ),

                    gridData: const FlGridData(
                      show: false,
                    ),

                    borderData: FlBorderData(
                      show: false,
                    ),

                    maxY: _getUsersMaxY(admin),

                    titlesData: FlTitlesData(

                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),

                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),

                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,

                          getTitlesWidget:
                              (value, meta) {

                            switch (value.toInt()) {

                              case 0:
                                return const Text(
                                  'Patients',
                                  style: TextStyle(
                                    fontSize: 11,
                                  ),
                                );

                              case 1:
                                return const Text(
                                  'Assistants',
                                  style: TextStyle(
                                    fontSize: 11,
                                  ),
                                );

                              case 2:
                                return const Text(
                                  'Admins',
                                  style: TextStyle(
                                    fontSize: 11,
                                  ),
                                );

                              default:
                                return const SizedBox();
                            }
                          },
                        ),
                      ),
                    ),

                    barGroups: [

                      makeBarGroup(
                        0,
                        admin.patientsCount.toDouble(),
                      ),

                      makeBarGroup(
                        1,
                        admin.assistantsCount.toDouble(),
                      ),

                      makeBarGroup(
                        2,
                        admin.adminsCount.toDouble(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // =================================================
              // APPOINTMENTS BY CLINIC
              // =================================================

              const Text(
                'Appointments by Clinic',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 220,

                child: admin
                        .appointmentsByClinic
                        .isEmpty
                    ? const Center(
                        child: Text(
                          'No appointment data available',
                        ),
                      )
                    : BarChart(
                        BarChartData(

                          // =================================================
                          // CLINIC TOOLTIP
                          // =================================================

                          barTouchData:
                              BarTouchData(
                            enabled: true,

                            touchTooltipData:
                                BarTouchTooltipData(
                              getTooltipItem:
                                  (
                                    group,
                                    groupIndex,
                                    rod,
                                    rodIndex,
                                  ) {

                                final clinics = admin
                                    .appointmentsByClinic
                                    .entries
                                    .toList();

                                if (groupIndex < 0 ||
                                    groupIndex >=
                                        clinics.length) {
                                  return null;
                                }

                                final clinic =
                                    clinics[groupIndex];

                                return BarTooltipItem(
                                  '${clinic.key}\n'
                                  '${clinic.value} appointments',
                                  const TextStyle(
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                );
                              },
                            ),
                          ),

                          gridData: const FlGridData(
                            show: false,
                          ),

                          borderData: FlBorderData(
                            show: false,
                          ),

                          maxY: _getClinicMaxY(admin),

                          titlesData: FlTitlesData(

                            leftTitles:
                                const AxisTitles(
                              sideTitles:
                                  SideTitles(
                                showTitles: false,
                              ),
                            ),

                            topTitles:
                                const AxisTitles(
                              sideTitles:
                                  SideTitles(
                                showTitles: false,
                              ),
                            ),

                            rightTitles:
                                const AxisTitles(
                              sideTitles:
                                  SideTitles(
                                showTitles: false,
                              ),
                            ),

                            bottomTitles:
                                AxisTitles(
                              sideTitles:
                                  SideTitles(
                                showTitles: true,

                                reservedSize: 45,

                                getTitlesWidget:
                                    (value, meta) {

                                  final clinics = admin
                                      .appointmentsByClinic
                                      .keys
                                      .toList();

                                  final index =
                                      value.toInt();

                                  if (index < 0 ||
                                      index >=
                                          clinics.length) {
                                    return const SizedBox();
                                  }

                                  final name =
                                      clinics[index];

                                  return Padding(
                                    padding:
                                        const EdgeInsets
                                            .only(
                                      top: 8,
                                    ),

                                    child: Text(
                                      _shortenClinicName(
                                        name,
                                      ),

                                      style:
                                          const TextStyle(
                                        fontSize: 9,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          barGroups:
                              _buildClinicBars(admin),
                        ),
                      ),
              ),

              const SizedBox(height: 28),

              // =================================================
              // TOP CLINICS
              // =================================================

              const Text(
                'Top Clinics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              ..._buildTopClinics(admin),
            ],
          ),
        ),
      ),

      // =====================================================
      // BOTTOM NAVIGATION
      // =====================================================

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: 0,

        type: BottomNavigationBarType.fixed,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard_rounded,
            ),
            label: 'Dashboard',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.business_rounded,
            ),
            label: 'Clinics',
          ),

          // =================================================
          // PERFORMANCE
          // =================================================

          BottomNavigationBarItem(
            icon: Icon(
              Icons.analytics_outlined,
            ),
            label: 'Performance',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.people_alt_rounded,
            ),
            label: 'Staff',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_rounded,
            ),
            label: 'Settings',
          ),
        ],

        onTap: (index) {

          switch (index) {

            case 1:
              Navigator.of(context)
                  .pushNamed(
                '/clinics-management',
              );
              break;

            case 2:
              Navigator.of(context)
                  .pushNamed(
                '/clinic-performance',
              );
              break;

            case 3:
              Navigator.of(context)
                  .pushNamed(
                '/assistants-management',
              );
              break;

            case 4:
              Navigator.of(context)
                  .pushNamed(
                '/platform-settings',
              );
              break;
          }
        },
      ),
    );
  }

  // =========================================================
  // USERS MAX Y
  // =========================================================

  double _getUsersMaxY(
    AdminProvider admin,
  ) {
    final max = [
      admin.patientsCount,
      admin.assistantsCount,
      admin.adminsCount,
    ].reduce(
      (a, b) => a > b ? a : b,
    );

    if (max == 0) {
      return 5;
    }

    return max.toDouble() * 1.2;
  }

  // =========================================================
  // CLINIC MAX Y
  // =========================================================

  double _getClinicMaxY(
    AdminProvider admin,
  ) {
    if (admin.appointmentsByClinic.isEmpty) {
      return 5;
    }

    final max =
        admin.appointmentsByClinic.values.reduce(
      (a, b) => a > b ? a : b,
    );

    return max.toDouble() * 1.2;
  }

  // =========================================================
  // CLINIC BAR GROUPS
  // =========================================================

  List<BarChartGroupData> _buildClinicBars(
    AdminProvider admin,
  ) {
    final clinics =
        admin.appointmentsByClinic.entries.toList();

    return List.generate(
      clinics.length,
      (index) {
        return makeBarGroup(
          index,
          clinics[index].value.toDouble(),
        );
      },
    );
  }

  // =========================================================
  // TOP CLINICS
  // =========================================================

  List<Widget> _buildTopClinics(
    AdminProvider admin,
  ) {
    final clinics =
        admin.appointmentsByClinic.entries.toList();

    clinics.sort(
      (a, b) => b.value.compareTo(a.value),
    );

    final topClinics =
        clinics.take(5).toList();

    if (topClinics.isEmpty) {
      return [
        const Text(
          'No clinic data available',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ];
    }

    return List.generate(
      topClinics.length,
      (index) {
        final clinic =
            topClinics[index];

        return _ClinicListTile(
          rank: index + 1,
          name: clinic.key,
          volume:
              '${clinic.value} booked',
        );
      },
    );
  }

  // =========================================================
  // BAR
  // =========================================================

  BarChartGroupData makeBarGroup(
    int x,
    double y,
  ) {
    return BarChartGroupData(
      x: x,

      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primaryBlue,
          borderRadius:
              BorderRadius.circular(8),
          width: 24,
        ),
      ],
    );
  }
}

// =============================================================
// STAT CARD
// =============================================================

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.trend,
  });

  final String title;
  final String value;
  final String trend;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Expanded(
      child: Container(
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

            Text(
              title,
              style: const TextStyle(
                color:
                    AppColors.textSecondary,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            if (trend.isNotEmpty) ...[
              const SizedBox(height: 8),

              Text(
                trend,
                style: const TextStyle(
                  color:
                      AppColors.successGreen,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================
// USERS CARD
// =============================================================

class _UsersCard extends StatelessWidget {
  const _UsersCard({
    required this.totalUsers,
    required this.patients,
    required this.assistants,
    required this.admins,
  });

  final int totalUsers;
  final int patients;
  final int assistants;
  final int admins;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Expanded(
      child: Container(
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

            const Text(
              'Registered Users',
              style: TextStyle(
                color:
                    AppColors.textSecondary,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              totalUsers.toString(),
              style: const TextStyle(
                fontSize: 26,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Patients: $patients',
            ),

            Text(
              'Assistants: $assistants',
            ),

            Text(
              'Admins: $admins',
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// CLINIC LIST TILE
// =============================================================

class _ClinicListTile
    extends StatelessWidget {
  const _ClinicListTile({
    required this.rank,
    required this.name,
    required this.volume,
  });

  final int rank;
  final String name;
  final String volume;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      padding:
          const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: AppColors.border,
        ),
      ),

      child: Row(
        children: [

          CircleAvatar(
            child: Text(
              '$rank',
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              name,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),

          Text(
            volume,
            style:
                const TextStyle(
              color:
                  AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// SHORTEN CLINIC NAME
// =============================================================

String _shortenClinicName(
  String name,
) {
  if (name.length <= 12) {
    return name;
  }

  return '${name.substring(0, 12)}...';
}