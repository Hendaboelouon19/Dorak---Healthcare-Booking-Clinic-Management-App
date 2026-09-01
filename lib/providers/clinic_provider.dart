import 'package:flutter/foundation.dart';

import '../models/clinic_model.dart';
import 'mock_data.dart';

class ClinicProvider extends ChangeNotifier {
  List<ClinicModel> get clinics => MockData.clinics;

  ClinicModel? get selectedClinic => _selectedClinic;
  ClinicModel? _selectedClinic;

  String? selectedDoctorName;
  String? selectedDoctorSpecialty;
  String? selectedDoctorNextAvailable;

  void selectClinic(String clinicId) {
    _selectedClinic = MockData.clinics.firstWhere((clinic) => clinic.id == clinicId);
    notifyListeners();
  }

  void selectDoctor({
    required String doctorName,
    required String specialty,
    required String? nextAvailable,
  }) {
    selectedDoctorName = doctorName;
    selectedDoctorSpecialty = specialty;
    selectedDoctorNextAvailable = nextAvailable;
    notifyListeners();
  }
}
