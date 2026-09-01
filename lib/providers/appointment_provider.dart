import 'package:flutter/foundation.dart';

import '../models/appointment_model.dart';
import 'mock_data.dart';

class AppointmentProvider extends ChangeNotifier {
  List<AppointmentModel> get appointments => MockData.appointments;

  AppointmentModel? selectedAppointment;

  Future<void> bookAppointment({
    required String patientName,
    required String clinicName,
    required String doctorName,
    required DateTime date,
    required String timeWindow,
    required int queueNumber,
  }) async {
    selectedAppointment = AppointmentModel(
      id: 'app_${DateTime.now().millisecondsSinceEpoch}',
      patientName: patientName,
      clinicName: clinicName,
      doctorName: doctorName,
      date: date,
      timeWindow: timeWindow,
      status: AppointmentStatus.confirmed,
      queueNumber: queueNumber,
    );
    notifyListeners();
  }
}
