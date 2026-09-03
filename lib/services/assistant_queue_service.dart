import 'package:cloud_firestore/cloud_firestore.dart';

class AssistantQueueService {
  AssistantQueueService({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ===========================================================
  // APPROVE ARRIVAL
  //
  // booked / confirmed
  //        ↓
  // inQueue
  //
  // Appointment update + notification are one transaction.
  // ===========================================================

  Future<void> approveArrival({
    required String appointmentId,
    required int queueNumber,
    required DateTime estimatedTurnAt,
  }) async {
    if (queueNumber < 1) {
      throw ArgumentError(
        'Queue number must be at least 1.',
      );
    }

    final appointmentRef =
        _firestore
            .collection('appointments')
            .doc(appointmentId);

    await _firestore.runTransaction(
      (transaction) async {
        // -----------------------------------------------------
        // READ APPOINTMENT
        // -----------------------------------------------------

        final appointmentSnapshot =
            await transaction.get(
          appointmentRef,
        );

        if (!appointmentSnapshot.exists) {
          throw StateError(
            'Appointment does not exist.',
          );
        }

        final appointmentData =
            appointmentSnapshot.data();

        if (appointmentData == null) {
          throw StateError(
            'Appointment contains no data.',
          );
        }

        final patientId =
            appointmentData['patientId']
                as String?;

        final status =
            appointmentData['status']
                    as String? ??
                '';

        if (patientId == null ||
            patientId.isEmpty) {
          throw StateError(
            'Appointment has no patient.',
          );
        }

        if (status != 'booked' &&
            status != 'confirmed') {
          throw StateError(
            'Only booked appointments can enter the queue.',
          );
        }

        // -----------------------------------------------------
        // NOTIFICATION REFERENCE
        //
        // IMPORTANT:
        // We do NOT transaction.get() this document.
        // Assistants do not need permission to read Patient
        // notifications.
        // -----------------------------------------------------

        final notificationRef =
            _firestore
                .collection('users')
                .doc(patientId)
                .collection(
                  'notifications',
                )
                .doc(
                  '${appointmentId}_arrivalApproved',
                );

        // -----------------------------------------------------
        // UPDATE APPOINTMENT
        // -----------------------------------------------------

        transaction.update(
          appointmentRef,
          {
            'status':
                'inQueue',

            'queueNumber':
                queueNumber,

            'arrivalApprovedAt':
                FieldValue.serverTimestamp(),

            'queueJoinedAt':
                FieldValue.serverTimestamp(),

            'estimatedTurnAt':
                Timestamp.fromDate(
              estimatedTurnAt,
            ),

            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );

        // -----------------------------------------------------
        // CREATE NOTIFICATION
        // -----------------------------------------------------

        transaction.set(
          notificationRef,
          {
            'title':
                'Arrival approved',

            'message':
                'You are now #$queueNumber in the live queue.',

            'type':
                'arrivalApproved',

            'appointmentId':
                appointmentId,

            'isRead':
                false,

            'createdAt':
                FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  // ===========================================================
  // UPDATE QUEUE POSITION
  //
  // Example:
  // #3 → #2 → #1
  //
  // When patient becomes #1:
  // create "You're next!" notification.
  // ===========================================================

  Future<void> updateQueuePosition({
    required String appointmentId,
    required int queueNumber,
    required DateTime estimatedTurnAt,
  }) async {
    if (queueNumber < 1) {
      throw ArgumentError(
        'Queue number must be at least 1.',
      );
    }

    final appointmentRef =
        _firestore
            .collection('appointments')
            .doc(appointmentId);

    await _firestore.runTransaction(
      (transaction) async {
        // -----------------------------------------------------
        // READ APPOINTMENT
        // -----------------------------------------------------

        final appointmentSnapshot =
            await transaction.get(
          appointmentRef,
        );

        if (!appointmentSnapshot.exists) {
          throw StateError(
            'Appointment does not exist.',
          );
        }

        final appointmentData =
            appointmentSnapshot.data();

        if (appointmentData == null) {
          throw StateError(
            'Appointment contains no data.',
          );
        }

        final patientId =
            appointmentData['patientId']
                as String?;

        final status =
            appointmentData['status']
                    as String? ??
                '';

        final previousQueueNumber =
            (appointmentData['queueNumber']
                    as num?)
                ?.toInt() ??
            0;

        if (patientId == null ||
            patientId.isEmpty) {
          throw StateError(
            'Appointment has no patient.',
          );
        }

        if (status != 'inQueue') {
          throw StateError(
            'Patient is not currently in the queue.',
          );
        }

        // -----------------------------------------------------
        // DID PATIENT BECOME #1?
        // -----------------------------------------------------

        final becameNext =
            previousQueueNumber != 1 &&
            queueNumber == 1;

        // -----------------------------------------------------
        // UPDATE APPOINTMENT
        // -----------------------------------------------------

        transaction.update(
          appointmentRef,
          {
            'queueNumber':
                queueNumber,

            'estimatedTurnAt':
                Timestamp.fromDate(
              estimatedTurnAt,
            ),

            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );

        // -----------------------------------------------------
        // CREATE "YOU'RE NEXT" ONLY WHEN MOVING TO #1
        // -----------------------------------------------------

        if (becameNext) {
          final notificationRef =
              _firestore
                  .collection('users')
                  .doc(patientId)
                  .collection(
                    'notifications',
                  )
                  .doc(
                    '${appointmentId}_turnApproaching',
                  );

          transaction.set(
            notificationRef,
            {
              'title':
                  "You're next!",

              'message':
                  "You're now first in the queue. "
                  'Please stay nearby and be ready.',

              'type':
                  'turnApproaching',

              'appointmentId':
                  appointmentId,

              'isRead':
                  false,

              'createdAt':
                  FieldValue.serverTimestamp(),
            },
          );
        }
      },
    );
  }

  // ===========================================================
  // START APPOINTMENT
  //
  // inQueue
  //    ↓
  // inProgress
  //
  // Creates "It's your turn!" notification.
  // ===========================================================

  Future<void> startAppointment({
    required String appointmentId,
  }) async {
    final appointmentRef =
        _firestore
            .collection('appointments')
            .doc(appointmentId);

    await _firestore.runTransaction(
      (transaction) async {
        // -----------------------------------------------------
        // READ APPOINTMENT
        // -----------------------------------------------------

        final appointmentSnapshot =
            await transaction.get(
          appointmentRef,
        );

        if (!appointmentSnapshot.exists) {
          throw StateError(
            'Appointment does not exist.',
          );
        }

        final appointmentData =
            appointmentSnapshot.data();

        if (appointmentData == null) {
          throw StateError(
            'Appointment contains no data.',
          );
        }

        final patientId =
            appointmentData['patientId']
                as String?;

        final doctorName =
            appointmentData['doctorName']
                    as String? ??
                'The doctor';

        final status =
            appointmentData['status']
                    as String? ??
                '';

        if (patientId == null ||
            patientId.isEmpty) {
          throw StateError(
            'Appointment has no patient.',
          );
        }

        if (status != 'inQueue') {
          throw StateError(
            'Patient must be in the queue first.',
          );
        }

        final notificationRef =
            _firestore
                .collection('users')
                .doc(patientId)
                .collection(
                  'notifications',
                )
                .doc(
                  '${appointmentId}_doctorReady',
                );

        // -----------------------------------------------------
        // UPDATE APPOINTMENT
        // -----------------------------------------------------

        transaction.update(
          appointmentRef,
          {
            'status':
                'inProgress',

            'startedAt':
                FieldValue.serverTimestamp(),

            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );

        // -----------------------------------------------------
        // NOTIFICATION
        // -----------------------------------------------------

        transaction.set(
          notificationRef,
          {
            'title':
                "It's your turn!",

            'message':
                '$doctorName is ready for you now.',

            'type':
                'doctorArrived',

            'appointmentId':
                appointmentId,

            'isRead':
                false,

            'createdAt':
                FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }
}