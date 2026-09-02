import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/clinic_model.dart';
import '../models/doctor_model.dart';
import '../models/doctor_slot_model.dart';

class ClinicProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final List<ClinicModel> _clinics = [];
  final List<DoctorModel> _doctors = [];
  final List<DoctorSlotModel> _slots = [];

  ClinicModel? _selectedClinic;
  DoctorModel? _selectedDoctor;
  DoctorSlotModel? _selectedSlot;

  bool _isLoading = false;
  bool _isLoadingDoctors = false;
  bool _isLoadingSlots = false;

  String? _errorMessage;
  String? _doctorErrorMessage;
  String? _slotErrorMessage;

  // Compatibility with older booking code
  String? selectedDoctorName;
  String? selectedDoctorSpecialty;
  String? selectedDoctorNextAvailable;

  // =========================================================
  // GETTERS
  // =========================================================

  List<ClinicModel> get clinics =>
      List.unmodifiable(_clinics);

  List<DoctorModel> get doctors =>
      List.unmodifiable(_doctors);

  List<DoctorSlotModel> get slots =>
      List.unmodifiable(_slots);

  ClinicModel? get selectedClinic =>
      _selectedClinic;

  DoctorModel? get selectedDoctor =>
      _selectedDoctor;

  DoctorSlotModel? get selectedSlot =>
      _selectedSlot;

  bool get isLoading => _isLoading;

  bool get isLoadingDoctors =>
      _isLoadingDoctors;

  bool get isLoadingSlots =>
      _isLoadingSlots;

  String? get errorMessage =>
      _errorMessage;

  String? get doctorErrorMessage =>
      _doctorErrorMessage;

  String? get slotErrorMessage =>
      _slotErrorMessage;

  // =========================================================
  // FETCH CLINICS
  // =========================================================

  Future<void> fetchClinics() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('clinics')
          .where(
            'active',
            isEqualTo: true,
          )
          .where(
            'approvalStatus',
            isEqualTo: 'approved',
          )
          .get();

      final loadedClinics = snapshot.docs
          .map(
            (document) =>
                ClinicModel.fromFirestore(document),
          )
          .toList();

      _clinics
        ..clear()
        ..addAll(loadedClinics);

      debugPrint(
        'Loaded ${_clinics.length} approved clinics.',
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'Clinic Firestore error: '
        '${e.code} - ${e.message}',
      );

      _errorMessage =
          'Could not load clinics. Please try again.';
    } catch (e) {
      debugPrint(
        'Clinic loading error: $e',
      );

      _errorMessage =
          'Could not load clinics. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // SELECT CLINIC
  // =========================================================

  void selectClinic(String clinicId) {
    try {
      _selectedClinic = _clinics.firstWhere(
        (clinic) => clinic.id == clinicId,
      );

      _doctors.clear();
      _slots.clear();

      _selectedDoctor = null;
      _selectedSlot = null;

      selectedDoctorName = null;
      selectedDoctorSpecialty = null;
      selectedDoctorNextAvailable = null;

      _doctorErrorMessage = null;
      _slotErrorMessage = null;

      notifyListeners();
    } catch (_) {
      debugPrint(
        'Clinic not found: $clinicId',
      );
    }
  }

  // =========================================================
  // FETCH DOCTORS
  // =========================================================

  Future<void> fetchDoctors() async {
    final clinic = _selectedClinic;

    if (clinic == null) {
      _doctorErrorMessage =
          'No clinic selected.';

      notifyListeners();
      return;
    }

    _isLoadingDoctors = true;
    _doctorErrorMessage = null;

    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('clinics')
          .doc(clinic.id)
          .collection('doctors')
          .where(
            'active',
            isEqualTo: true,
          )
          .get();

      final loadedDoctors = snapshot.docs
          .map(
            (document) =>
                DoctorModel.fromFirestore(document),
          )
          .toList();

      _doctors
        ..clear()
        ..addAll(loadedDoctors);

      debugPrint(
        'Loaded ${_doctors.length} doctors '
        'for ${clinic.name}.',
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'Doctor Firestore error: '
        '${e.code} - ${e.message}',
      );

      _doctorErrorMessage =
          'Could not load doctors. Please try again.';
    } catch (e) {
      debugPrint(
        'Doctor loading error: $e',
      );

      _doctorErrorMessage =
          'Could not load doctors. Please try again.';
    } finally {
      _isLoadingDoctors = false;
      notifyListeners();
    }
  }

  // =========================================================
  // SELECT DOCTOR
  // =========================================================

  void selectDoctorModel(
    DoctorModel doctor,
  ) {
    _selectedDoctor = doctor;

    selectedDoctorName = doctor.name;
    selectedDoctorSpecialty =
        doctor.specialty;

    selectedDoctorNextAvailable =
        doctor.nextAvailable ??
        (doctor.availability.isNotEmpty
            ? doctor.availability
            : null);

    // Doctor changed → clear old slots.
    _slots.clear();
    _selectedSlot = null;
    _slotErrorMessage = null;

    notifyListeners();
  }

  // Keep temporarily for older screens.
  void selectDoctor({
    required String doctorName,
    required String specialty,
    required String? nextAvailable,
  }) {
    selectedDoctorName =
        doctorName;

    selectedDoctorSpecialty =
        specialty;

    selectedDoctorNextAvailable =
        nextAvailable;

    try {
      _selectedDoctor = _doctors.firstWhere(
        (doctor) =>
            doctor.name == doctorName,
      );
    } catch (_) {
      _selectedDoctor = null;
    }

    _slots.clear();
    _selectedSlot = null;

    notifyListeners();
  }

  // =========================================================
  // FETCH AVAILABLE SLOTS
  // =========================================================

  Future<void> fetchSlots() async {
    final clinic = _selectedClinic;
    final doctor = _selectedDoctor;

    if (clinic == null || doctor == null) {
      _slotErrorMessage =
          'Please select a doctor first.';

      notifyListeners();
      return;
    }

    _isLoadingSlots = true;
    _slotErrorMessage = null;

    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('clinics')
          .doc(clinic.id)
          .collection('doctors')
          .doc(doctor.id)
          .collection('slots')
          .where(
            'active',
            isEqualTo: true,
          )
          .get();

      final now = DateTime.now();

      final loadedSlots = snapshot.docs
          .map(
            (document) =>
                DoctorSlotModel.fromFirestore(
              document,
            ),
          )
          .where(
            (slot) =>
                slot.status == 'available' &&
                slot.startAt.isAfter(now),
          )
          .toList();

      loadedSlots.sort(
        (a, b) =>
            a.startAt.compareTo(b.startAt),
      );

      _slots
        ..clear()
        ..addAll(loadedSlots);

      _selectedSlot = null;

      debugPrint(
        'Loaded ${_slots.length} available slots '
        'for ${doctor.name}.',
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'Slot Firestore error: '
        '${e.code} - ${e.message}',
      );

      _slotErrorMessage =
          'Could not load appointment slots.';
    } catch (e) {
      debugPrint(
        'Slot loading error: $e',
      );

      _slotErrorMessage =
          'Could not load appointment slots.';
    } finally {
      _isLoadingSlots = false;
      notifyListeners();
    }
  }

  // =========================================================
  // SELECT SLOT
  // =========================================================

  void selectSlot(
    DoctorSlotModel slot,
  ) {
    _selectedSlot = slot;

    notifyListeners();
  }

  // =========================================================
  // CLEAR
  // =========================================================

  void clearSelection() {
    _selectedClinic = null;
    _selectedDoctor = null;
    _selectedSlot = null;

    _doctors.clear();
    _slots.clear();

    selectedDoctorName = null;
    selectedDoctorSpecialty = null;
    selectedDoctorNextAvailable = null;

    _errorMessage = null;
    _doctorErrorMessage = null;
    _slotErrorMessage = null;

    notifyListeners();
  }
}