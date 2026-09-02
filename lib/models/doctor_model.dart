import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,

    // Old project/mock-data fields
    this.clinicId = '',
    this.avatar = '',
    this.fee = 0,
    this.availability = '',

    // New Firestore fields
    this.qualification = '',
    this.room = '',
    this.imageUrl = '',
    this.active = true,
    this.averageConsultationMinutes = 20,
    this.nextAvailable,
  });

  final String id;
  final String name;
  final String specialty;

  // ---------------- OLD COMPATIBILITY ----------------

  final String clinicId;
  final String avatar;

  // Object allows old mock data to use either:
  // 300
  // "300"
  // "MYR 300"
  final Object fee;

  final String availability;

  // ---------------- FIRESTORE ----------------

  final String qualification;
  final String room;
  final String imageUrl;

  final bool active;

  final int averageConsultationMinutes;

  final String? nextAvailable;

  factory DoctorModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw StateError(
        'Doctor document ${document.id} contains no data.',
      );
    }

    final firestoreImage =
        data['imageUrl'] as String? ?? '';

    final oldAvatar =
        data['avatar'] as String? ?? '';

    final firestoreAvailability =
        data['availability'] as String? ?? '';

    final next =
        data['nextAvailable'] as String?;

    return DoctorModel(
      id: document.id,

      name:
          data['name'] as String? ?? '',

      specialty:
          data['specialty'] as String? ?? '',

      clinicId:
          data['clinicId'] as String? ?? '',

      avatar: oldAvatar,

      fee:
          data['fee'] ?? 0,

      availability:
          firestoreAvailability,

      qualification:
          data['qualification'] as String? ?? '',

      room:
          data['room'] as String? ?? '',

      imageUrl: firestoreImage.isNotEmpty
          ? firestoreImage
          : oldAvatar,

      active:
          data['active'] as bool? ?? true,

      averageConsultationMinutes:
          (data['averageConsultationMinutes'] as num?)
                  ?.toInt() ??
              20,

      nextAvailable:
          next ?? firestoreAvailability,
    );
  }
}