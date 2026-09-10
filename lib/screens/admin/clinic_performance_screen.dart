import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/admin_provider.dart';
import '../../theme/app_colors.dart';

class ClinicPerformanceScreen extends StatefulWidget {
  const ClinicPerformanceScreen({super.key});

  @override
  State<ClinicPerformanceScreen> createState() =>
      _ClinicPerformanceScreenState();
}

class _ClinicPerformanceScreenState
    extends State<ClinicPerformanceScreen> {
  int _selectedDays = 7;

  String? _selectedClinicId;

  @override
  void initState() {
    super.initState();

    final adminProvider = context.read<AdminProvider>();

    Future.microtask(() {
      adminProvider.loadDashboard(
        days: _selectedDays,
      );
    });
  }

  // =====================================================
  // CHANGE DAYS
  // =====================================================

  Future<void> _changeDays(int days) async {
    setState(() {
      _selectedDays = days;
    });

    await context.read<AdminProvider>().loadDashboard(
          days: days,
        );
  }

  // =====================================================
  // FORMAT HOUR
  // =====================================================

  String _formatHour(int? hour) {
    if (hour == null) {
      return '--';
    }

    final period = hour >= 12 ? 'PM' : 'AM';

    int displayHour = hour % 12;

    if (displayHour == 0) {
      displayHour = 12;
    }

    return '$displayHour $period';
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    // ===================================================
    // LOADING
    // ===================================================

    if (adminProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'Clinic Performance',
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ===================================================
    // ERROR
    // ===================================================

    if (adminProvider.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'Clinic Performance',
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              adminProvider.errorMessage!,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // ===================================================
    // CLINICS
    // ===================================================

    final clinics = adminProvider.clinicPerformance;

    Map<String, dynamic>? selectedClinic;

    if (_selectedClinicId != null) {
      for (final clinic in clinics) {
        if (clinic['clinicId'] == _selectedClinicId) {
          selectedClinic = clinic;
          break;
        }
      }
    }

    // ===================================================
    // WAIT TIME TREND
    // ===================================================

    final trendData = adminProvider.waitTimeTrend;

    final filteredTrend = trendData.length > _selectedDays
        ? trendData.sublist(
            trendData.length - _selectedDays,
          )
        : trendData;

    // ===================================================
    // MAIN SCREEN
    // ===================================================

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Clinic Performance',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =================================================
            // PERFORMANCE PERIOD
            // =================================================

            const Text(
              'Performance Period',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _RangeChip(
                    label: '7 Days',
                    selected: _selectedDays == 7,
                    onTap: () {
                      _changeDays(7);
                    },
                  ),
                  _RangeChip(
                    label: '30 Days',
                    selected: _selectedDays == 30,
                    onTap: () {
                      _changeDays(30);
                    },
                  ),
                  _RangeChip(
                    label: '90 Days',
                    selected: _selectedDays == 90,
                    onTap: () {
                      _changeDays(90);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =================================================
            // CLINIC SELECTOR
            // =================================================

            const Text(
              'Clinic',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _selectedClinicId,
                  isExpanded: true,
                  hint: const Text(
                    'All Clinics',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        'All Clinics',
                      ),
                    ),
                    ...clinics.map(
                      (clinic) {
                        return DropdownMenuItem<String?>(
                          value: clinic['clinicId'] as String,
                          child: Text(
                            clinic['clinicName'],
                          ),
                        );
                      },
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedClinicId = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // =================================================
            // CLINIC PERFORMANCE CARDS
            // =================================================

            if (selectedClinic != null)
              _ClinicPerformanceCard(
                clinic: selectedClinic,
                formatHour: _formatHour,
              )
            else if (clinics.isEmpty)
              const _EmptyCard(
                text: 'No clinic data available.',
              )
            else
              Column(
                children: [
                  for (final clinic in clinics) ...[
                    _ClinicPerformanceCard(
                      clinic: clinic,
                      formatHour: _formatHour,
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),

            const SizedBox(height: 10),

            // =================================================
            // OVERALL PERFORMANCE
            // =================================================

            if (selectedClinic == null) ...[
              const Text(
                'Overall Performance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _MiniStatCard(
                      title: 'Avg. wait',
                      value:
                          '${adminProvider.averageWaitMinutes.toStringAsFixed(1)} min',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStatCard(
                      title: 'No-show',
                      value:
                          '${adminProvider.noShowRate.toStringAsFixed(1)}%',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // =================================================
              // WAIT TIME TREND
              // =================================================

              const Text(
                'Wait Time Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                height: 240,
                padding: const EdgeInsets.fromLTRB(
                  12,
                  16,
                  20,
                  12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: filteredTrend.isEmpty
                    ? const Center(
                        child: Text(
                          'No wait time data available.',
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          minY: 0,
                          gridData: const FlGridData(
                            show: true,
                          ),
                          titlesData: const FlTitlesData(
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                for (
                                  int i = 0;
                                  i < filteredTrend.length;
                                  i++
                                )
                                  FlSpot(
                                    i.toDouble(),
                                    (
                                      filteredTrend[i]['average']
                                          as num
                                    ).toDouble(),
                                  ),
                              ],
                              isCurved: true,
                              barWidth: 3,
                              dotData: const FlDotData(
                                show: true,
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 24),

              // =================================================
              // PEAK HOURS
              // =================================================

              const Text(
                'Peak Hours',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                height: 240,
                padding: const EdgeInsets.fromLTRB(
                  12,
                  16,
                  20,
                  12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: adminProvider
                        .appointmentsByHour
                        .isEmpty
                    ? const Center(
                        child: Text(
                          'No peak-hours data available.',
                        ),
                      )
                    : BarChart(
                        BarChartData(
                          minY: 0,
                          gridData: const FlGridData(
                            show: true,
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          titlesData: const FlTitlesData(
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                              ),
                            ),
                          ),
                          barGroups: adminProvider
                              .appointmentsByHour.entries
                              .map(
                                (entry) =>
                                    BarChartGroupData(
                                  x: entry.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value.toDouble(),
                                      width: 12,
                                      borderRadius:
                                          BorderRadius.circular(
                                        4,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// CLINIC PERFORMANCE CARD
// =========================================================

class _ClinicPerformanceCard extends StatelessWidget {
  const _ClinicPerformanceCard({
    required this.clinic,
    required this.formatHour,
  });

  final Map<String, dynamic> clinic;
  final String Function(int?) formatHour;

  @override
  Widget build(BuildContext context) {
    final clinicName =
        clinic['clinicName']?.toString() ??
            'Unnamed Clinic';

    final appointments =
        (clinic['appointments'] as num?)?.toInt() ?? 0;

    final averageWait =
        (clinic['averageWait'] as num?)?.toDouble() ?? 0;

    final noShowRate =
        (clinic['noShowRate'] as num?)?.toDouble() ?? 0;

    final peakHour = clinic['peakHour'] as int?;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            clinicName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _ClinicMetric(
                  title: 'Appointments',
                  value: appointments.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ClinicMetric(
                  title: 'Avg. Wait',
                  value: averageWait > 0
                      ? '${averageWait.toStringAsFixed(1)}m'
                      : '--',
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _ClinicMetric(
                  title: 'No-show',
                  value:
                      '${noShowRate.toStringAsFixed(1)}%',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ClinicMetric(
                  title: 'Peak Hour',
                  value: formatHour(peakHour),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =========================================================
// CLINIC METRIC
// =========================================================

class _ClinicMetric extends StatelessWidget {
  const _ClinicMetric({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// RANGE CHIP
// =========================================================

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(
          right: 10,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.textPrimary
                : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// =========================================================
// MINI STAT CARD
// =========================================================

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// EMPTY CARD
// =========================================================

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}