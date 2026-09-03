import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus {
  booked,
  confirmed,
  inQueue,
  inProgress,
  completed,
  noShow,
}

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.patientName,
    required this.clinicName,
    required this.doctorName,
    required this.date,
    required this.timeWindow,
    required this.status,
    required this.queueNumber,

    // Firebase fields
    this.patientId = '',
    this.clinicId = '',
    this.doctorId = '',
    this.slotId = '',
    this.doctorSpecialty = '',
    this.room = '',

    // Queue timing
    this.estimatedTurnAt,
    this.queueJoinedAt,
    this.arrivalApprovedAt,
  });

  final String id;

  // ===========================================================
  // PATIENT
  // ===========================================================

  final String patientId;
  final String patientName;

  // ===========================================================
  // CLINIC
  // ===========================================================

  final String clinicId;
  final String clinicName;

  // ===========================================================
  // DOCTOR
  // ===========================================================

  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String room;

  // ===========================================================
  // SLOT
  // ===========================================================

  final String slotId;

  final DateTime date;
  final String timeWindow;

  // ===========================================================
  // STATUS
  // ===========================================================

  final AppointmentStatus status;

  // 0 means:
  // booked but patient has not entered the live queue yet.
  final int queueNumber;

  // ===========================================================
  // LIVE QUEUE TIMESTAMPS
  // ===========================================================

  final DateTime? estimatedTurnAt;
  final DateTime? queueJoinedAt;
  final DateTime? arrivalApprovedAt;

  // ===========================================================
  // FIRESTORE
  // ===========================================================

  factory AppointmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw StateError(
        'Appointment ${document.id} contains no data.',
      );
    }

    final slotStartAtValue =
        data['slotStartAt'];

    final estimatedTurnAtValue =
        data['estimatedTurnAt'];

    final queueJoinedAtValue =
        data['queueJoinedAt'];

    final arrivalApprovedAtValue =
        data['arrivalApprovedAt'];

    return AppointmentModel(
      id: document.id,

      // PATIENT
      patientId:
          data['patientId'] as String? ?? '',

      patientName:
          data['patientName'] as String? ?? '',

      // CLINIC
      clinicId:
          data['clinicId'] as String? ?? '',

      clinicName:
          data['clinicName'] as String? ?? '',

      // DOCTOR
      doctorId:
          data['doctorId'] as String? ?? '',

      doctorName:
          data['doctorName'] as String? ?? '',

      doctorSpecialty:
          data['doctorSpecialty'] as String? ?? '',

      room:
          data['room'] as String? ?? '',

      // SLOT
      slotId:
          data['slotId'] as String? ?? '',

      date: slotStartAtValue is Timestamp
          ? slotStartAtValue.toDate()
          : DateTime.now(),

      timeWindow:
          data['timeWindow'] as String? ?? '',

      // STATUS
      status: _statusFromString(
        data['status'] as String? ?? 'booked',
      ),

      queueNumber:
          (data['queueNumber'] as num?)?.toInt() ?? 0,

      // LIVE QUEUE
      estimatedTurnAt:
          estimatedTurnAtValue is Timestamp
              ? estimatedTurnAtValue.toDate()
              : null,

      queueJoinedAt:
          queueJoinedAtValue is Timestamp
              ? queueJoinedAtValue.toDate()
              : null,

      arrivalApprovedAt:
          arrivalApprovedAtValue is Timestamp
              ? arrivalApprovedAtValue.toDate()
              : null,
    );
  }

  // ===========================================================
  // STATUS PARSER
  // ===========================================================

  static AppointmentStatus _statusFromString(
    String value,
  ) {
    switch (value.trim()) {
      case 'confirmed':
        return AppointmentStatus.confirmed;

      case 'inQueue':
        return AppointmentStatus.inQueue;

      case 'inProgress':
        return AppointmentStatus.inProgress;

      case 'completed':
        return AppointmentStatus.completed;

      case 'noShow':
        return AppointmentStatus.noShow;

      case 'booked':
      default:
        return AppointmentStatus.booked;
    }
  }
}