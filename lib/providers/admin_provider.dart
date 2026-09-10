import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  int _totalClinics = 0;

  int _totalUsers = 0;
  int _patientsCount = 0;
  int _assistantsCount = 0;
  int _adminsCount = 0;

  int _totalAppointments = 0;

  double _averageWaitMinutes = 0;

  double _noShowRate = 0;

  final Map<String, int> _appointmentsByClinic = {};

  final List<Map<String, dynamic>> _waitTimeTrend = [];

  final Map<int, int> _appointmentsByHour = {};

  final List<Map<String, dynamic>> _assistants = [];

  // =====================================================
  // CLINIC PERFORMANCE
  // =====================================================

  final List<Map<String, dynamic>> _clinicPerformance = [];

  // =====================================================
  // GETTERS
  // =====================================================

  int get totalClinics => _totalClinics;

  int get totalUsers => _totalUsers;

  int get patientsCount => _patientsCount;

  int get assistantsCount => _assistantsCount;

  int get adminsCount => _adminsCount;

  int get totalAppointments => _totalAppointments;

  double get averageWaitMinutes => _averageWaitMinutes;

  double get noShowRate => _noShowRate;

  Map<String, int> get appointmentsByClinic =>
      Map.unmodifiable(_appointmentsByClinic);

  List<Map<String, dynamic>> get waitTimeTrend =>
      List.unmodifiable(_waitTimeTrend);

  Map<int, int> get appointmentsByHour =>
      Map.unmodifiable(_appointmentsByHour);

  List<Map<String, dynamic>> get assistants =>
      List.unmodifiable(_assistants);

  List<Map<String, dynamic>> get clinicPerformance =>
      List.unmodifiable(_clinicPerformance);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // =====================================================
  // LOAD DASHBOARD
  // =====================================================

  Future<void> loadDashboard({
    int? days,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      // ===================================================
      // CLINICS
      // ===================================================

      final clinicsSnapshot =
          await _firestore.collection('clinics').get();

      _totalClinics = clinicsSnapshot.size;

      // Map clinicId -> clinicName
      final clinicNames = <String, String>{};

      for (final doc in clinicsSnapshot.docs) {
        final data = doc.data();

        final name =
            data['name']?.toString().trim() ?? '';

        clinicNames[doc.id] =
            name.isEmpty ? 'Unnamed Clinic' : name;
      }

      // ===================================================
      // USERS
      // ===================================================

      final usersSnapshot =
          await _firestore.collection('users').get();

      _totalUsers = usersSnapshot.size;

      _patientsCount = 0;
      _assistantsCount = 0;
      _adminsCount = 0;

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();

        final role =
            data['role']?.toString().toLowerCase();

        switch (role) {
          case 'patient':
            _patientsCount++;
            break;

          case 'assistant':
            _assistantsCount++;
            break;

          case 'admin':
            _adminsCount++;
            break;
        }
      }

      // ===================================================
      // APPOINTMENTS
      // ===================================================

      final appointmentsSnapshot =
          await _firestore.collection('appointments').get();

      _totalAppointments = appointmentsSnapshot.size;

      // ===================================================
      // DATE RANGE
      // ===================================================

      DateTime? startDate;

      if (days != null) {
        final now = DateTime.now();

        startDate = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(
          Duration(days: days - 1),
        );
      }

      // ===================================================
      // FILTERED APPOINTMENTS
      // ===================================================

      final filteredAppointments =
          <QueryDocumentSnapshot<Map<String, dynamic>>>[];

      for (final doc in appointmentsSnapshot.docs) {
        final data = doc.data();

        if (startDate == null) {
          filteredAppointments.add(doc);
          continue;
        }

        final slotStartAt = data['slotStartAt'];

        if (slotStartAt is Timestamp) {
          final appointmentDate =
              slotStartAt.toDate();

          if (!appointmentDate.isBefore(startDate)) {
            filteredAppointments.add(doc);
          }
        }
      }

      // ===================================================
      // APPOINTMENTS BY HOUR
      // ===================================================

      _appointmentsByHour.clear();

      for (final doc in filteredAppointments) {
        final data = doc.data();

        final slotStartAt = data['slotStartAt'];

        if (slotStartAt is Timestamp) {
          final hour =
              slotStartAt.toDate().hour;

          _appointmentsByHour[hour] =
              (_appointmentsByHour[hour] ?? 0) + 1;
        }
      }

      // ===================================================
      // NO-SHOW
      // ===================================================

      int noShowCount = 0;

      for (final doc in filteredAppointments) {
        final data = doc.data();

        final status =
            data['status']?.toString().trim() ?? '';

        if (status.toLowerCase() == 'noshow') {
          noShowCount++;
        }
      }

      final filteredAppointmentsCount =
          filteredAppointments.length;

      if (filteredAppointmentsCount > 0) {
        _noShowRate =
            (noShowCount / filteredAppointmentsCount) *
                100;
      } else {
        _noShowRate = 0;
      }

      // ===================================================
      // APPOINTMENTS BY CLINIC
      // ===================================================

      _appointmentsByClinic.clear();

      for (final doc in filteredAppointments) {
        final data = doc.data();

        final clinicId =
            data['clinicId']?.toString().trim();

        final clinicName =
            data['clinicName']?.toString().trim();

        String name = '';

        if (clinicId != null &&
            clinicId.isNotEmpty &&
            clinicNames.containsKey(clinicId)) {
          name = clinicNames[clinicId]!;
        } else if (clinicName != null &&
            clinicName.isNotEmpty) {
          name = clinicName;
        }

        if (name.isEmpty) {
          name = 'Unknown Clinic';
        }

        _appointmentsByClinic[name] =
            (_appointmentsByClinic[name] ?? 0) + 1;
      }

      // ===================================================
      // OVERALL WAIT TIME
      // ===================================================

      final waitTimes = <double>[];

      for (final doc in filteredAppointments) {
        final data = doc.data();

        final queueJoinedAt =
            data['queueJoinedAt'];

        final startedAt =
            data['startedAt'];

        if (queueJoinedAt is Timestamp &&
            startedAt is Timestamp) {
          final duration = startedAt
              .toDate()
              .difference(queueJoinedAt.toDate());

          final minutes =
              duration.inSeconds / 60;

          if (minutes >= 0) {
            waitTimes.add(minutes);
          }
        }
      }

      if (waitTimes.isNotEmpty) {
        _averageWaitMinutes =
            waitTimes.reduce(
                  (a, b) => a + b,
                ) /
                waitTimes.length;
      } else {
        _averageWaitMinutes = 0;
      }

      // ===================================================
      // WAIT TIME TREND
      // ===================================================

      _waitTimeTrend.clear();

      final dailyWaitTimes =
          <DateTime, List<double>>{};

      for (final doc in filteredAppointments) {
        final data = doc.data();

        final queueJoinedAt =
            data['queueJoinedAt'];

        final startedAt =
            data['startedAt'];

        if (queueJoinedAt is Timestamp &&
            startedAt is Timestamp) {
          final joinedDate =
              queueJoinedAt.toDate();

          final day = DateTime(
            joinedDate.year,
            joinedDate.month,
            joinedDate.day,
          );

          final duration = startedAt
              .toDate()
              .difference(joinedDate);

          final minutes =
              duration.inSeconds / 60;

          if (minutes >= 0) {
            dailyWaitTimes
                .putIfAbsent(day, () => [])
                .add(minutes);
          }
        }
      }

      final sortedDays =
          dailyWaitTimes.keys.toList()..sort();

      for (final day in sortedDays) {
        final times =
            dailyWaitTimes[day]!;

        final average =
            times.reduce(
                  (a, b) => a + b,
                ) /
                times.length;

        _waitTimeTrend.add({
          'day': day,
          'average': average,
        });
      }

      // ===================================================
      // CLINIC PERFORMANCE
      // ===================================================

      _clinicPerformance.clear();

      // First create a card for every clinic
      for (final clinicDoc
          in clinicsSnapshot.docs) {
        final clinicId = clinicDoc.id;

        final clinicData =
            clinicDoc.data();

        final clinicName =
            clinicData['name']
                    ?.toString()
                    .trim()
                    .isNotEmpty ==
                true
            ? clinicData['name']
                .toString()
                .trim()
            : 'Unnamed Clinic';

        _clinicPerformance.add({
          'clinicId': clinicId,
          'clinicName': clinicName,
          'appointments': 0,
          'averageWait': 0.0,
          'noShowRate': 0.0,
          'peakHour': null,
        });
      }

      // ===================================================
      // CALCULATE PERFORMANCE PER CLINIC
      // ===================================================

      for (int clinicIndex = 0;
          clinicIndex < _clinicPerformance.length;
          clinicIndex++) {
        final clinic =
            _clinicPerformance[clinicIndex];

        final clinicId =
            clinic['clinicId'].toString();

        final clinicAppointments =
            filteredAppointments.where((doc) {
          final data = doc.data();

          final appointmentClinicId =
              data['clinicId']?.toString().trim();

          return appointmentClinicId == clinicId;
        }).toList();

        // -----------------------------------------------
        // APPOINTMENTS COUNT
        // -----------------------------------------------

        final appointmentCount =
            clinicAppointments.length;

        // -----------------------------------------------
        // WAIT TIMES
        // -----------------------------------------------

        final clinicWaitTimes = <double>[];

        for (final appointment
            in clinicAppointments) {
          final data =
              appointment.data();

          final queueJoinedAt =
              data['queueJoinedAt'];

          final startedAt =
              data['startedAt'];

          if (queueJoinedAt is Timestamp &&
              startedAt is Timestamp) {
            final duration = startedAt
                .toDate()
                .difference(
                  queueJoinedAt.toDate(),
                );

            final minutes =
                duration.inSeconds / 60;

            if (minutes >= 0) {
              clinicWaitTimes.add(minutes);
            }
          }
        }

        double averageWait = 0;

        if (clinicWaitTimes.isNotEmpty) {
          averageWait =
              clinicWaitTimes.reduce(
                    (a, b) => a + b,
                  ) /
                  clinicWaitTimes.length;
        }

        // -----------------------------------------------
        // NO-SHOW RATE
        // -----------------------------------------------

        int clinicNoShowCount = 0;

        for (final appointment
            in clinicAppointments) {
          final data =
              appointment.data();

          final status =
              data['status']
                  ?.toString()
                  .trim()
                  .toLowerCase();

          if (status == 'noshow') {
            clinicNoShowCount++;
          }
        }

        double clinicNoShowRate = 0;

        if (appointmentCount > 0) {
          clinicNoShowRate =
              (clinicNoShowCount /
                      appointmentCount) *
                  100;
        }

        // -----------------------------------------------
        // PEAK HOUR
        // -----------------------------------------------

        final hourCounts =
            <int, int>{};

        for (final appointment
            in clinicAppointments) {
          final data =
              appointment.data();

          final slotStartAt =
              data['slotStartAt'];

          if (slotStartAt is Timestamp) {
            final hour =
                slotStartAt.toDate().hour;

            hourCounts[hour] =
                (hourCounts[hour] ?? 0) + 1;
          }
        }

        int? peakHour;

        if (hourCounts.isNotEmpty) {
          peakHour = hourCounts.entries
              .reduce(
                (a, b) =>
                    a.value >= b.value
                        ? a
                        : b,
              )
              .key;
        }

        // -----------------------------------------------
        // UPDATE CLINIC
        // -----------------------------------------------

        _clinicPerformance[clinicIndex] = {
          ...clinic,
          'appointments': appointmentCount,
          'averageWait': averageWait,
          'noShowRate': clinicNoShowRate,
          'peakHour': peakHour,
        };
      }
    } on FirebaseException catch (e) {
      debugPrint(
        'Admin Dashboard Firebase error: '
        '${e.code} - ${e.message}',
      );

      _errorMessage =
          'Could not load dashboard data.';
    } catch (e) {
      debugPrint(
        'Admin Dashboard error: $e',
      );

      _errorMessage =
          'Could not load dashboard data.';
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // =====================================================
  // FETCH ASSISTANTS
  // =====================================================

  Future<void> fetchAssistants() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final assistantsSnapshot =
          await _firestore
              .collection('users')
              .where(
                'role',
                isEqualTo: 'assistant',
              )
              .get();

      _assistants.clear();

      for (final doc
          in assistantsSnapshot.docs) {
        final data = doc.data();

        _assistants.add({
          'id': doc.id,
          'name':
              data['name']?.toString() ?? '',
          'email':
              data['email']?.toString() ?? '',
          'phone':
              data['phone']?.toString() ?? '',
          'clinicId':
              data['clinicId']?.toString(),
          'active':
              data['active'] as bool? ?? true,
        });
      }
    } on FirebaseException catch (e) {
      debugPrint(
        'Fetch assistants Firebase error: '
        '${e.code} - ${e.message}',
      );

      _errorMessage =
          'Could not load assistants.';
    } catch (e) {
      debugPrint(
        'Fetch assistants error: $e',
      );

      _errorMessage =
          'Could not load assistants.';
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // =====================================================
  // ADD ASSISTANT
  // =====================================================

  Future<bool> addAssistant({
    required String name,
    required String email,
    required String phone,
    String? clinicId,
    required bool active,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final assistantData =
          <String, dynamic>{
        'name': name.trim(),
        'email':
            email.trim().toLowerCase(),
        'phone': phone.trim(),
        'role': 'assistant',
        'clinicId': clinicId,
        'active': active,
        'avatarUrl': '',
        'createdAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      };

      final documentReference =
          await _firestore
              .collection('users')
              .add(assistantData);

      debugPrint(
        'Assistant added successfully: '
        '${documentReference.id}',
      );

      return true;
    } on FirebaseException catch (e) {
      debugPrint(
        'Add assistant Firebase error: '
        '${e.code} - ${e.message}',
      );

      _errorMessage =
          'Could not add assistant. Please try again.';

      return false;
    } catch (e) {
      debugPrint(
        'Add assistant error: $e',
      );

      _errorMessage =
          'Could not add assistant. Please try again.';

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // =====================================================
  // UPDATE ASSISTANT
  // =====================================================

  Future<bool> updateAssistant({
    required String assistantId,
    required String name,
    required String phone,
    String? clinicId,
    required bool active,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _firestore
          .collection('users')
          .doc(assistantId)
          .update({
        'name': name.trim(),
        'phone': phone.trim(),
        'clinicId': clinicId,
        'active': active,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      final index =
          _assistants.indexWhere(
        (assistant) =>
            assistant['id'] == assistantId,
      );

      if (index != -1) {
        _assistants[index] = {
          ..._assistants[index],
          'name': name.trim(),
          'phone': phone.trim(),
          'clinicId': clinicId,
          'active': active,
        };
      }

      debugPrint(
        'Assistant updated successfully: '
        '$assistantId',
      );

      return true;
    } on FirebaseException catch (e) {
      debugPrint(
        'Update assistant Firebase error: '
        '${e.code} - ${e.message}',
      );

      _errorMessage =
          'Could not update assistant. Please try again.';

      return false;
    } catch (e) {
      debugPrint(
        'Update assistant error: $e',
      );

      _errorMessage =
          'Could not update assistant. Please try again.';

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // =====================================================
  // CLEAR ERROR
  // =====================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }
}