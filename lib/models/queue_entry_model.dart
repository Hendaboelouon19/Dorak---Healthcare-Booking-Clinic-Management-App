class QueueEntryModel {
  const QueueEntryModel({
    required this.patientName,
    required this.position,
    required this.waitMinutes,
    required this.scheduledTime,
    required this.status,
  });

  final String patientName;
  final int position;
  final int waitMinutes;
  final String scheduledTime;
  final String status;
}
