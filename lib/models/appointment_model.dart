import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus {
  booked,
  confirmed,
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

    // New real Firebase fields.
    this.patientId = '',
    this.clinicId = '',
    this.doctorId = '',
    this.slotId = '',
    this.doctorSpecialty = '',
    this.room = '',
  });

  final String id;

  final String patientId;
  final String patientName;

  final String clinicId;
  final String clinicName;

  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String room;

  final String slotId;

  final DateTime date;
  final String timeWindow;

  final AppointmentStatus status;

  // 0 means:
  // patient has booked but has NOT entered
  // the live queue yet.
  final int queueNumber;

  factory AppointmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw StateError(
        'Appointment ${document.id} contains no data.',
      );
    }

    final startAt = data['slotStartAt'];

    return AppointmentModel(
      id: document.id,

      patientId:
          data['patientId'] as String? ?? '',

      patientName:
          data['patientName'] as String? ?? '',

      clinicId:
          data['clinicId'] as String? ?? '',

      clinicName:
          data['clinicName'] as String? ?? '',

      doctorId:
          data['doctorId'] as String? ?? '',

      doctorName:
          data['doctorName'] as String? ?? '',

      doctorSpecialty:
          data['doctorSpecialty'] as String? ?? '',

      room:
          data['room'] as String? ?? '',

      slotId:
          data['slotId'] as String? ?? '',

      date: startAt is Timestamp
          ? startAt.toDate()
          : DateTime.now(),

      timeWindow:
          data['timeWindow'] as String? ?? '',

      status: _statusFromString(
        data['status'] as String? ?? 'booked',
      ),

      queueNumber:
          (data['queueNumber'] as num?)?.toInt() ?? 0,
    );
  }

  static AppointmentStatus _statusFromString(
    String value,
  ) {
    switch (value) {
      case 'confirmed':
        return AppointmentStatus.confirmed;

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