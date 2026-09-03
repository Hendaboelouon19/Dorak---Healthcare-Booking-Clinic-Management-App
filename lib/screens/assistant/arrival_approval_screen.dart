import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/assistant_queue_service.dart';
import '../../theme/app_colors.dart';

class ArrivalApprovalScreen extends StatefulWidget {
  const ArrivalApprovalScreen({
    super.key,
  });

  @override
  State<ArrivalApprovalScreen> createState() =>
      _ArrivalApprovalScreenState();
}

class _ArrivalApprovalScreenState
    extends State<ArrivalApprovalScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final AssistantQueueService _queueService =
      AssistantQueueService();

  final Set<String> _busyAppointments = {};

  List<_ArrivalAppointment> _appointments = [];

  bool _isLoading = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadAppointments();
  }

  // ===========================================================
  // LOAD REAL APPOINTMENTS
  // ===========================================================

  Future<void> _loadAppointments() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
            'You must be logged in as an assistant.';
      });

      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // =======================================================
      // 1. LOAD CLINICS OWNED BY THIS ASSISTANT
      // =======================================================

      final clinicSnapshot =
          await _firestore
              .collection('clinics')
              .where(
                'createdByAssistantId',
                isEqualTo: user.uid,
              )
              .get();

      final loadedAppointments =
          <_ArrivalAppointment>[];

      // =======================================================
      // 2. LOAD APPOINTMENTS FROM EACH OWNED CLINIC
      // =======================================================

      for (final clinicDocument
          in clinicSnapshot.docs) {
        final appointmentSnapshot =
            await _firestore
                .collection('appointments')
                .where(
                  'clinicId',
                  isEqualTo: clinicDocument.id,
                )
                .get();

        for (final document
            in appointmentSnapshot.docs) {
          final data = document.data();

          final status =
              data['status'] as String? ?? '';

          // Arrival approval is only for appointments
          // that have not entered the live queue yet.
          if (status != 'booked' &&
              status != 'confirmed') {
            continue;
          }

          final slotStartValue =
              data['slotStartAt'];

          if (slotStartValue is! Timestamp) {
            continue;
          }

          loadedAppointments.add(
            _ArrivalAppointment(
              id: document.id,

              patientName:
                  data['patientName']
                          as String? ??
                      'Patient',

              clinicId:
                  data['clinicId']
                          as String? ??
                      clinicDocument.id,

              clinicName:
                  data['clinicName']
                          as String? ??
                      'Clinic',

              doctorId:
                  data['doctorId']
                          as String? ??
                      '',

              doctorName:
                  data['doctorName']
                          as String? ??
                      'Doctor',

              scheduledAt:
                  slotStartValue.toDate(),

              timeWindow:
                  data['timeWindow']
                          as String? ??
                      DateFormat('h:mm a').format(
                        slotStartValue.toDate(),
                      ),

              status: status,
            ),
          );
        }
      }

      // Oldest / nearest appointment first.
      loadedAppointments.sort(
        (a, b) =>
            a.scheduledAt.compareTo(
          b.scheduledAt,
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _appointments = loadedAppointments;
        _isLoading = false;
      });
    } on FirebaseException catch (e) {
      debugPrint(
        'Arrival approval Firebase error: '
        '${e.code} - ${e.message}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;

        if (e.code == 'permission-denied') {
          _errorMessage =
              'Permission denied. Check the Assistant role '
              'and createdByAssistantId on the clinic.';
        } else {
          _errorMessage =
              'Could not load appointments.';
        }
      });
    } catch (e) {
      debugPrint(
        'Arrival approval load error: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Could not load appointments.';
      });
    }
  }

  // ===========================================================
  // APPROVE ARRIVAL
  // ===========================================================

  Future<void> _approveArrival(
    _ArrivalAppointment appointment,
  ) async {
    if (_busyAppointments.contains(
      appointment.id,
    )) {
      return;
    }

    setState(() {
      _busyAppointments.add(
        appointment.id,
      );
    });

    try {
      // =======================================================
      // FIND CURRENT QUEUE FOR THIS DOCTOR
      // =======================================================

      final clinicAppointments =
          await _firestore
              .collection('appointments')
              .where(
                'clinicId',
                isEqualTo:
                    appointment.clinicId,
              )
              .get();

      int highestQueueNumber = 0;

      for (final document
          in clinicAppointments.docs) {
        final data = document.data();

        final status =
            data['status'] as String? ?? '';

        final doctorId =
            data['doctorId'] as String? ?? '';

        if (status != 'inQueue' ||
            doctorId != appointment.doctorId) {
          continue;
        }

        final queueNumber =
            (data['queueNumber'] as num?)
                    ?.toInt() ??
                0;

        if (queueNumber >
            highestQueueNumber) {
          highestQueueNumber =
              queueNumber;
        }
      }

      final newQueueNumber =
          highestQueueNumber + 1;

      // =======================================================
      // GET DOCTOR'S AVERAGE CONSULTATION TIME
      // =======================================================

      int consultationMinutes = 20;

      if (appointment.doctorId.isNotEmpty) {
        final doctorSnapshot =
            await _firestore
                .collection('clinics')
                .doc(appointment.clinicId)
                .collection('doctors')
                .doc(appointment.doctorId)
                .get();

        final doctorData =
            doctorSnapshot.data();

        consultationMinutes =
            (doctorData?[
                        'averageConsultationMinutes']
                    as num?)
                ?.toInt() ??
            20;
      }

      if (consultationMinutes < 1) {
        consultationMinutes = 20;
      }

      // =======================================================
      // ESTIMATED TURN
      // =======================================================

      final estimatedTurnAt =
          DateTime.now().add(
        Duration(
          minutes:
              consultationMinutes *
                  newQueueNumber,
        ),
      );

      if (!mounted) {
        return;
      }

      // =======================================================
      // CONFIRM
      // =======================================================

      final confirmed =
          await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              'Approve arrival?',
            ),
            content: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.patientName,
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  'Queue number: #$newQueueNumber',
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  'Estimated turn: '
                  '${DateFormat('h:mm a').format(estimatedTurnAt)}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop(false);
                },
                child: const Text(
                  'Cancel',
                ),
              ),

              FilledButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop(true);
                },
                child: const Text(
                  'Approve',
                ),
              ),
            ],
          );
        },
      );

      if (confirmed != true) {
        return;
      }

      // =======================================================
      // REAL TRANSACTION
      //
      // appointment -> inQueue
      // +
      // arrivalApproved notification
      // =======================================================

      await _queueService.approveArrival(
        appointmentId:
            appointment.id,
        queueNumber:
            newQueueNumber,
        estimatedTurnAt:
            estimatedTurnAt,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '${appointment.patientName} '
            'was added to queue #$newQueueNumber.',
          ),
          backgroundColor:
              AppColors.successGreen,
        ),
      );

      await _loadAppointments();
    } on FirebaseException catch (e) {
      debugPrint(
        'Approve arrival Firebase error: '
        '${e.code} - ${e.message}',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'permission-denied'
                ? 'Permission denied. Check Firestore rules.'
                : 'Could not approve arrival.',
          ),
          backgroundColor:
              AppColors.dangerRed,
        ),
      );
    } catch (e) {
      debugPrint(
        'Approve arrival error: $e',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Bad state: ',
                  '',
                ),
          ),
          backgroundColor:
              AppColors.dangerRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyAppointments.remove(
            appointment.id,
          );
        });
      }
    }
  }

  // ===========================================================
  // MARK NO-SHOW
  // ===========================================================

  Future<void> _markNoShow(
    _ArrivalAppointment appointment,
  ) async {
    if (_busyAppointments.contains(
      appointment.id,
    )) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Mark as no-show?',
          ),
          content: Text(
            '${appointment.patientName} '
            'will be marked as a no-show.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),

            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    AppColors.dangerRed,
              ),
              child: const Text(
                'Mark No-show',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _busyAppointments.add(
        appointment.id,
      );
    });

    try {
      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .update({
        'status':
            'noShow',

        'noShowAt':
            FieldValue.serverTimestamp(),

        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '${appointment.patientName} '
            'was marked as no-show.',
          ),
        ),
      );

      await _loadAppointments();
    } on FirebaseException catch (e) {
      debugPrint(
        'No-show Firebase error: '
        '${e.code} - ${e.message}',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'permission-denied'
                ? 'Permission denied. Check Firestore rules.'
                : 'Could not mark patient as no-show.',
          ),
          backgroundColor:
              AppColors.dangerRed,
        ),
      );
    } catch (e) {
      debugPrint(
        'No-show error: $e',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Could not mark patient as no-show.',
          ),
          backgroundColor:
              AppColors.dangerRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyAppointments.remove(
            appointment.id,
          );
        });
      }
    }
  }

  // ===========================================================
  // UI
  // ===========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        backgroundColor:
            AppColors.background,
        elevation: 0,
        title:
            const Text(
          'Arrival Approval',
          style:
              TextStyle(
            fontWeight:
                FontWeight.w800,
            color:
                AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                _isLoading
                    ? null
                    : _loadAppointments,
            icon:
                const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),

      body:
          RefreshIndicator(
        onRefresh:
            _loadAppointments,
        child:
            _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading &&
        _appointments.isEmpty) {
      return  ListView(
        physics:
            AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 320,
            child: Center(
              child:
                  CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null &&
        _appointments.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(
          24,
        ),
        children: [
          const SizedBox(
            height: 100,
          ),

          const Icon(
            Icons
                .error_outline_rounded,
            size: 56,
            color:
                AppColors.dangerRed,
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            _errorMessage!,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 16,
              color: AppColors
                  .textSecondary,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          FilledButton(
            onPressed:
                _loadAppointments,
            child:
                const Text(
              'Try Again',
            ),
          ),
        ],
      );
    }

    if (_appointments.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(
          24,
        ),
        children: const [
          SizedBox(
            height: 120,
          ),

          Icon(
            Icons
                .how_to_reg_rounded,
            size: 64,
            color:
                AppColors.textSecondary,
          ),

          SizedBox(
            height: 16,
          ),

          Text(
            'No arrivals waiting for approval',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.w800,
              color: AppColors
                  .textPrimary,
            ),
          ),

          SizedBox(
            height: 8,
          ),

          Text(
            'Booked patients will appear here before they enter the live queue.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color: AppColors
                  .textSecondary,
              height: 1.5,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding:
          const EdgeInsets.all(
        18,
      ),
      itemCount:
          _appointments.length,
      itemBuilder:
          (context, index) {
        final appointment =
            _appointments[index];

        final busy =
            _busyAppointments
                .contains(
          appointment.id,
        );

        return _PatientApprovalCard(
          appointment:
              appointment,
          busy:
              busy,
          onApprove:
              () {
            _approveArrival(
              appointment,
            );
          },
          onNoShow:
              () {
            _markNoShow(
              appointment,
            );
          },
        );
      },
    );
  }
}

// ===============================================================
// PATIENT CARD
// ===============================================================

class _PatientApprovalCard
    extends StatelessWidget {
  const _PatientApprovalCard({
    required this.appointment,
    required this.busy,
    required this.onApprove,
    required this.onNoShow,
  });

  final _ArrivalAppointment appointment;

  final bool busy;

  final VoidCallback onApprove;
  final VoidCallback onNoShow;

  @override
  Widget build(
    BuildContext context,
  ) {
    final arrivalStatus =
        _arrivalStatus(
      appointment.scheduledAt,
    );

    final late =
        arrivalStatus.startsWith(
      'Late',
    );

    final statusColor =
        late
            ? AppColors.warningAmber
            : AppColors.successGreen;

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      elevation: 0,
      color:
          AppColors.surface,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        side:
            const BorderSide(
          color:
              AppColors.border,
        ),
      ),
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child:
            LayoutBuilder(
          builder:
              (context, constraints) {
            final compact =
                constraints.maxWidth <
                    560;

            final patientInfo =
                Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 24,
                  child:
                      Icon(
                    Icons.person,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        appointment
                            .patientName,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight
                                  .w800,
                          fontSize: 18,
                          color: AppColors
                              .textPrimary,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        appointment
                            .clinicName,
                        style:
                            const TextStyle(
                          color: AppColors
                              .textSecondary,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),

                      const SizedBox(
                        height: 2,
                      ),

                      Text(
                        appointment
                            .doctorName,
                        style:
                            const TextStyle(
                          color: AppColors
                              .textSecondary,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        'Scheduled: '
                        '${appointment.timeWindow}',
                        style:
                            const TextStyle(
                          color: AppColors
                              .textSecondary,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              statusColor
                                  .withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            999,
                          ),
                        ),
                        child:
                            Text(
                          arrivalStatus,
                          style:
                              TextStyle(
                            color:
                                statusColor,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final buttons =
                Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                SizedBox(
                  width:
                      double.infinity,
                  child:
                      FilledButton(
                    onPressed:
                        busy
                            ? null
                            : onApprove,
                    style:
                        FilledButton.styleFrom(
                      backgroundColor:
                          AppColors
                              .successGreen,
                    ),
                    child:
                        busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Text(
                                'Approve Arrival',
                              ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  child:
                      OutlinedButton(
                    onPressed:
                        busy
                            ? null
                            : onNoShow,
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          AppColors
                              .dangerRed,
                      side:
                          const BorderSide(
                        color:
                            AppColors
                                .dangerRed,
                      ),
                    ),
                    child:
                        const Text(
                      'Mark No-show',
                    ),
                  ),
                ),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  patientInfo,

                  const SizedBox(
                    height: 16,
                  ),

                  buttons,
                ],
              );
            }

            return Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                Expanded(
                  child:
                      patientInfo,
                ),

                const SizedBox(
                  width: 16,
                ),

                SizedBox(
                  width: 180,
                  child:
                      buttons,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _arrivalStatus(
    DateTime scheduledAt,
  ) {
    final difference =
        DateTime.now()
            .difference(
      scheduledAt,
    )
            .inMinutes;

    if (difference < -5) {
      return 'Upcoming';
    }

    if (difference <= 5) {
      return 'On time';
    }

    return 'Late $difference min';
  }
}

// ===============================================================
// LOCAL VIEW MODEL
// ===============================================================

class _ArrivalAppointment {
  const _ArrivalAppointment({
    required this.id,
    required this.patientName,
    required this.clinicId,
    required this.clinicName,
    required this.doctorId,
    required this.doctorName,
    required this.scheduledAt,
    required this.timeWindow,
    required this.status,
  });

  final String id;

  final String patientName;

  final String clinicId;
  final String clinicName;

  final String doctorId;
  final String doctorName;

  final DateTime scheduledAt;

  final String timeWindow;

  final String status;
}