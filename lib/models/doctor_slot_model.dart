import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorSlotModel {
  const DoctorSlotModel({
    required this.id,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.active,
  });

  final String id;
  final DateTime startAt;
  final DateTime endAt;
  final String status;
  final bool active;

  bool get isAvailable =>
      active &&
      status == 'available' &&
      startAt.isAfter(DateTime.now());

  factory DoctorSlotModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw StateError(
        'Slot document ${document.id} contains no data.',
      );
    }

    final startTimestamp = data['startAt'];
    final endTimestamp = data['endAt'];

    if (startTimestamp is! Timestamp ||
        endTimestamp is! Timestamp) {
      throw StateError(
        'Slot ${document.id} has invalid timestamps.',
      );
    }

    return DoctorSlotModel(
      id: document.id,
      startAt: startTimestamp.toDate(),
      endAt: endTimestamp.toDate(),
      status: data['status'] as String? ?? 'available',
      active: data['active'] as bool? ?? true,
    );
  }
}