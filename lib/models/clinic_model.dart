import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicModel {
  const ClinicModel({
    required this.id,
    required this.name,
    required this.address,
    required this.specialties,
    required this.rating,
    required this.distance,
    required this.imageUrl,
    required this.openNow,
    required this.currentQueue,
    required this.assistantName,
    required this.workingHours,

    // New Firebase fields, but optional for compatibility
    this.active = true,
    this.latitude = 0,
    this.longitude = 0,
  });

  final String id;
  final String name;
  final String address;
  final List<String> specialties;

  final double rating;

  // Temporary.
  // Later calculated using patient's real location.
  final String distance;

  final String imageUrl;

  final bool openNow;
  final bool active;

  final int currentQueue;

  final String assistantName;
  final String workingHours;

  final double latitude;
  final double longitude;

  factory ClinicModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw StateError(
        'Clinic document ${document.id} contains no data.',
      );
    }

    final location = data['location'];

    double latitude = 0;
    double longitude = 0;

    if (location is GeoPoint) {
      latitude = location.latitude;
      longitude = location.longitude;
    }

    final rawSpecialties = data['specialties'];

    final specialties = rawSpecialties is List
        ? rawSpecialties
            .map((item) => item.toString())
            .toList()
        : <String>[];

    return ClinicModel(
      id: document.id,

      name: data['name'] as String? ?? '',

      address: data['address'] as String? ?? '',

      specialties: specialties,

      rating:
          (data['rating'] as num?)?.toDouble() ?? 0,

      distance: '—',

      imageUrl:
          data['imageUrl'] as String? ?? '',

      openNow:
          data['isOpen'] as bool? ?? false,

      active:
          data['active'] as bool? ?? true,

      currentQueue:
          (data['currentQueue'] as num?)?.toInt() ?? 0,

      assistantName:
          data['assistantName'] as String? ?? '',

      workingHours:
          data['workingHours'] as String? ?? '',

      latitude: latitude,

      longitude: longitude,
    );
  }
}