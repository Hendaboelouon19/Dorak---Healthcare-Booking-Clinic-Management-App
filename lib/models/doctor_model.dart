class DoctorModel {
  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatar,
    required this.fee,
    required this.availability,
  });

  final String id;
  final String name;
  final String specialty;
  final String avatar;
  final double fee;
  final String availability;
}
