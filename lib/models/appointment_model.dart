enum AppointmentStatus { booked, confirmed, inProgress, completed, noShow }

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
  });

  final String id;
  final String patientName;
  final String clinicName;
  final String doctorName;
  final DateTime date;
  final String timeWindow;
  final AppointmentStatus status;
  final int queueNumber;
}
