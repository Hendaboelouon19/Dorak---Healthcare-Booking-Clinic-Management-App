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
    this.active = true,
    this.latitude = 0,
    this.longitude = 0,
    this.distanceKm,
  });

  final String id;

  final String name;
  final String address;

  final List<String> specialties;

  final double rating;

  /// Human-readable value shown in the UI:
  /// 750 m
  /// 1.4 km
  /// —
  final String distance;

  /// Numeric distance used for sorting/filtering.
  final double? distanceKm;

  final String imageUrl;

  final bool openNow;
  final bool active;

  final int currentQueue;

  final String assistantName;
  final String workingHours;

  final double latitude;
  final double longitude;

  bool get hasLocation {
    return latitude != 0 || longitude != 0;
  }

  ClinicModel copyWithDistance(
    double? kilometers,
  ) {
    return ClinicModel(
      id: id,
      name: name,
      address: address,
      specialties: specialties,
      rating: rating,
      distance: _formatDistance(
        kilometers,
      ),
      imageUrl: imageUrl,
      openNow: openNow,
      currentQueue: currentQueue,
      assistantName: assistantName,
      workingHours: workingHours,
      active: active,
      latitude: latitude,
      longitude: longitude,
      distanceKm: kilometers,
    );
  }

  static String _formatDistance(
    double? kilometers,
  ) {
    if (kilometers == null) {
      return '—';
    }

    if (kilometers < 1) {
      final meters =
          (kilometers * 1000).round();

      return '$meters m';
    }

    if (kilometers < 10) {
      return '${kilometers.toStringAsFixed(1)} km';
    }

    return '${kilometers.toStringAsFixed(0)} km';
  }

  factory ClinicModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw StateError(
        'Clinic document ${document.id} contains no data.',
      );
    }

    final location =
        data['location'];

    double latitude = 0;
    double longitude = 0;

    if (location is GeoPoint) {
      latitude =
          location.latitude;

      longitude =
          location.longitude;
    }

    final rawSpecialties =
        data['specialties'];

    final specialties =
        rawSpecialties is List
            ? rawSpecialties
                .map(
                  (item) =>
                      item.toString(),
                )
                .toList()
            : <String>[];

    return ClinicModel(
      id: document.id,

      name:
          data['name'] as String? ??
              '',

      address:
          data['address'] as String? ??
              '',

      specialties:
          specialties,

      rating:
          (data['rating'] as num?)
                  ?.toDouble() ??
              0,

      distance:
          '—',

      distanceKm:
          null,

      imageUrl:
          data['imageUrl'] as String? ??
              '',

      openNow:
          data['isOpen'] as bool? ??
              false,

      active:
          data['active'] as bool? ??
              true,

      currentQueue:
          (data['currentQueue'] as num?)
                  ?.toInt() ??
              0,

      assistantName:
          data['assistantName']
                  as String? ??
              '',

      workingHours:
          data['workingHours']
                  as String? ??
              '',

      latitude:
          latitude,

      longitude:
          longitude,
    );
  }
}