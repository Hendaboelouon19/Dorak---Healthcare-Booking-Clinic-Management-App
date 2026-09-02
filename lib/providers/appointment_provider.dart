import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/appointment_model.dart';
import 'mock_data.dart';

class AppointmentProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final List<AppointmentModel> _realAppointments = [];

  AppointmentModel? selectedAppointment;

  bool _isBooking = false;
  bool _isLoadingAppointments = false;

  String? _errorMessage;
  String? _appointmentsErrorMessage;

  // =========================================================
  // GETTERS
  // =========================================================

  bool get isBooking =>
      _isBooking;

  bool get isLoadingAppointments =>
      _isLoadingAppointments;

  String? get errorMessage =>
      _errorMessage;

  String? get appointmentsErrorMessage =>
      _appointmentsErrorMessage;

  List<AppointmentModel> get realAppointments =>
      List.unmodifiable(
        _realAppointments,
      );

  // TEMPORARY compatibility with PatientHomeScreen.
  //
  // We'll remove MockData from here when we migrate
  // Patient Home in the next phase.
  List<AppointmentModel> get appointments =>
      List.unmodifiable([
        ..._realAppointments,
        ...MockData.appointments,
      ]);

  // =========================================================
  // FETCH PATIENT APPOINTMENTS
  // =========================================================

  Future<void> fetchAppointments() async {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      _realAppointments.clear();

      _appointmentsErrorMessage =
          'You must be logged in.';

      notifyListeners();
      return;
    }

    _isLoadingAppointments = true;
    _appointmentsErrorMessage = null;

    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where(
            'patientId',
            isEqualTo: firebaseUser.uid,
          )
          .get();

      final loaded = snapshot.docs
          .map(
            (document) =>
                AppointmentModel.fromFirestore(
              document,
            ),
          )
          .toList();

      // Newest appointment first.
      loaded.sort(
        (a, b) =>
            b.date.compareTo(a.date),
      );

      _realAppointments
        ..clear()
        ..addAll(loaded);

      // Refresh selected appointment with the
      // latest Firestore version if it exists.
      if (selectedAppointment != null) {
        final selectedId =
            selectedAppointment!.id;

        AppointmentModel? refreshed;

        for (final appointment
            in _realAppointments) {
          if (appointment.id ==
              selectedId) {
            refreshed = appointment;
            break;
          }
        }

        if (refreshed != null) {
          selectedAppointment =
              refreshed;
        }
      }

      debugPrint(
        'Loaded ${_realAppointments.length} '
        'appointments for patient.',
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'Appointment fetch Firebase error: '
        '${e.code} - ${e.message}',
      );

      _appointmentsErrorMessage =
          'Could not load appointments.';
    } catch (e) {
      debugPrint(
        'Appointment fetch error: $e',
      );

      _appointmentsErrorMessage =
          'Could not load appointments.';
    } finally {
      _isLoadingAppointments =
          false;

      notifyListeners();
    }
  }

  // =========================================================
  // SELECT APPOINTMENT
  // =========================================================

  void selectAppointment(
    AppointmentModel appointment,
  ) {
    selectedAppointment =
        appointment;

    notifyListeners();
  }

  // =========================================================
  // BOOK APPOINTMENT
  // =========================================================

  Future<bool> bookAppointment({
    required String clinicId,
    required String clinicName,
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    required String room,
    required String slotId,
  }) async {
    if (_isBooking) {
      return false;
    }

    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser == null) {
      _errorMessage =
          'You must be logged in to book an appointment.';

      notifyListeners();
      return false;
    }

    _isBooking = true;
    _errorMessage = null;

    notifyListeners();

    try {
      // -------------------------------------------------------
      // PATIENT
      // -------------------------------------------------------

      final userSnapshot =
          await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .get();

      final patientName =
          userSnapshot.data()?['name']
                  as String? ??
              firebaseUser.displayName ??
              firebaseUser.email ??
              'Patient';

      // -------------------------------------------------------
      // REFERENCES
      // -------------------------------------------------------

      final slotReference =
          _firestore
              .collection('clinics')
              .doc(clinicId)
              .collection('doctors')
              .doc(doctorId)
              .collection('slots')
              .doc(slotId);

      final appointmentReference =
          _firestore
              .collection('appointments')
              .doc();

      DateTime? confirmedStartAt;
      DateTime? confirmedEndAt;

      // -------------------------------------------------------
      // ATOMIC BOOKING
      // -------------------------------------------------------

      await _firestore.runTransaction(
        (transaction) async {
          final slotSnapshot =
              await transaction.get(
            slotReference,
          );

          if (!slotSnapshot.exists) {
            throw const _SlotUnavailableException(
              'This appointment slot no longer exists.',
            );
          }

          final slotData =
              slotSnapshot.data();

          if (slotData == null) {
            throw const _SlotUnavailableException(
              'This appointment slot is unavailable.',
            );
          }

          final active =
              slotData['active'] == true;

          final status =
              slotData['status']
                      as String? ??
                  '';

          if (!active ||
              status != 'available') {
            throw const _SlotUnavailableException(
              'Someone else has already booked this slot.',
            );
          }

          final startTimestamp =
              slotData['startAt'];

          final endTimestamp =
              slotData['endAt'];

          if (startTimestamp
                  is! Timestamp ||
              endTimestamp
                  is! Timestamp) {
            throw const _SlotUnavailableException(
              'This appointment slot has invalid timing.',
            );
          }

          confirmedStartAt =
              startTimestamp.toDate();

          confirmedEndAt =
              endTimestamp.toDate();

          if (!confirmedStartAt!
              .isAfter(DateTime.now())) {
            throw const _SlotUnavailableException(
              'This appointment slot has already passed.',
            );
          }

          final timeWindow =
              '${DateFormat('h:mm a').format(confirmedStartAt!)}'
              ' - '
              '${DateFormat('h:mm a').format(confirmedEndAt!)}';

          // ---------------------------------------------
          // CREATE APPOINTMENT
          // ---------------------------------------------

          transaction.set(
            appointmentReference,
            {
              'patientId':
                  firebaseUser.uid,

              'patientName':
                  patientName,

              'clinicId':
                  clinicId,

              'clinicName':
                  clinicName,

              'doctorId':
                  doctorId,

              'doctorName':
                  doctorName,

              'doctorSpecialty':
                  doctorSpecialty,

              'room':
                  room,

              'slotId':
                  slotId,

              'slotStartAt':
                  startTimestamp,

              'slotEndAt':
                  endTimestamp,

              'timeWindow':
                  timeWindow,

              'status':
                  'booked',

              // Patient has NOT entered queue yet.
              'queueNumber':
                  0,

              'createdAt':
                  FieldValue.serverTimestamp(),

              'updatedAt':
                  FieldValue.serverTimestamp(),
            },
          );

          // ---------------------------------------------
          // RESERVE SLOT
          // ---------------------------------------------

          transaction.update(
            slotReference,
            {
              'status':
                  'booked',

              'bookedBy':
                  firebaseUser.uid,

              'appointmentId':
                  appointmentReference.id,

              'bookedAt':
                  FieldValue.serverTimestamp(),
            },
          );
        },
      );

      final startAt =
          confirmedStartAt;

      final endAt =
          confirmedEndAt;

      if (startAt == null ||
          endAt == null) {
        throw StateError(
          'Booking completed without valid timing.',
        );
      }

      final timeWindow =
          '${DateFormat('h:mm a').format(startAt)}'
          ' - '
          '${DateFormat('h:mm a').format(endAt)}';

      final appointment =
          AppointmentModel(
        id:
            appointmentReference.id,

        patientId:
            firebaseUser.uid,

        patientName:
            patientName,

        clinicId:
            clinicId,

        clinicName:
            clinicName,

        doctorId:
            doctorId,

        doctorName:
            doctorName,

        doctorSpecialty:
            doctorSpecialty,

        room:
            room,

        slotId:
            slotId,

        date:
            startAt,

        timeWindow:
            timeWindow,

        status:
            AppointmentStatus.booked,

        queueNumber:
            0,
      );

      selectedAppointment =
          appointment;

      _realAppointments.insert(
        0,
        appointment,
      );

      debugPrint(
        'Appointment booked: '
        '${appointment.id}',
      );

      return true;
    } on _SlotUnavailableException catch (e) {
      _errorMessage =
          e.message;

      return false;
    } on FirebaseException catch (e) {
      debugPrint(
        'Booking Firebase error: '
        '${e.code} - ${e.message}',
      );

      if (e.code ==
          'permission-denied') {
        _errorMessage =
            'Booking permission was denied.';
      } else {
        _errorMessage =
            'Could not book appointment. Please try again.';
      }

      return false;
    } catch (e) {
      debugPrint(
        'Booking error: $e',
      );

      _errorMessage =
          'Could not book appointment. Please try again.';

      return false;
    } finally {
      _isBooking = false;

      notifyListeners();
    }
  }
}

class _SlotUnavailableException
    implements Exception {
  const _SlotUnavailableException(
    this.message,
  );

  final String message;
}