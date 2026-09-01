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
  });

  final String id;
  final String name;
  final String address;
  final List<String> specialties;
  final double rating;
  final String distance;
  final String imageUrl;
  final bool openNow;
  final int currentQueue;
  final String assistantName;
  final String workingHours;
}
