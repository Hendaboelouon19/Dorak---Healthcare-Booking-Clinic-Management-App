import '../models/appointment_model.dart';
import '../models/clinic_model.dart';
import '../models/doctor_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

class MockData {
  static final List<ClinicModel> clinics = [
    ClinicModel(
      id: 'clinic_1',
      name: 'BloomCare Clinic',
      address: '15 Al Noor Street, Jeddah',
      specialties: ['Cardiology', 'Heart Diagnostics', 'Preventive Care'],
      rating: 4.8,
      distance: '2.3 km',
      imageUrl: 'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=800&q=80',
      openNow: true,
      currentQueue: 12,
      assistantName: 'Sara Al-Khalid',
      workingHours: 'Mon-Sat · 9:00 AM - 9:00 PM',
    ),
    ClinicModel(
      id: 'clinic_2',
      name: 'Heartline Center',
      address: '8 Palm Avenue, Jeddah',
      specialties: ['Cardiology', 'ECG', 'Cardiac Rehab'],
      rating: 4.9,
      distance: '1.8 km',
      imageUrl: 'https://images.unsplash.com/photo-1584515933487-779824d29309?auto=format&fit=crop&w=800&q=80',
      openNow: true,
      currentQueue: 6,
      assistantName: 'Mazen Ali',
      workingHours: 'Sun-Thu · 8:00 AM - 7:00 PM',
    ),
    ClinicModel(
      id: 'clinic_3',
      name: 'CareNest Cardio',
      address: '42 Red Sea Road, Jeddah',
      specialties: ['Cardiology', 'Echocardiography', 'Follow-up Care'],
      rating: 4.9,
      distance: '3.1 km',
      imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=800&q=80',
      openNow: true,
      currentQueue: 7,
      assistantName: 'Lina Hassan',
      workingHours: 'Mon-Sun · 8:30 AM - 8:30 PM',
    ),
  ];

  static final List<DoctorModel> doctors = [
    const DoctorModel(
      id: 'doctor_1',
      name: 'Dr. Hassan Nasser',
      specialty: 'Cardiologist',
      avatar: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=300&q=80',
      fee: 180,
      availability: 'Today · 10:00 AM - 1:00 PM',
    ),
    const DoctorModel(
      id: 'doctor_2',
      name: 'Dr. Nora Al-Sayed',
      specialty: 'Interventional Cardiologist',
      avatar: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=300&q=80',
      fee: 210,
      availability: 'Today · 11:30 AM - 2:30 PM',
    ),
    const DoctorModel(
      id: 'doctor_3',
      name: 'Dr. Rania Soliman',
      specialty: 'Cardiac Consultant',
      avatar: 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?auto=format&fit=crop&w=300&q=80',
      fee: 170,
      availability: 'Today · 9:00 AM - 12:00 PM',
    ),
    const DoctorModel(
      id: 'doctor_4',
      name: 'Dr. Samir Yusuf',
      specialty: 'Cardiac Surgeon',
      avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      fee: 240,
      availability: 'Today · 2:00 PM - 5:00 PM',
    ),
  ];

  static final List<AppointmentModel> appointments = [
    AppointmentModel(
      id: 'app_1',
      patientName: 'Hend Aboelouon',
      clinicName: 'BloomCare Clinic',
      doctorName: 'Dr. Hassan Nasser',
      date: DateTime.now().add(const Duration(days: 1)),
      timeWindow: '10:00 AM - 10:30 AM',
      status: AppointmentStatus.confirmed,
      queueNumber: 4,
    ),
    AppointmentModel(
      id: 'app_2',
      patientName: 'Aisha Rahman',
      clinicName: 'Smile Dental Center',
      doctorName: 'Dr. Rana Omar',
      date: DateTime.now(),
      timeWindow: '9:15 AM - 9:45 AM',
      status: AppointmentStatus.inProgress,
      queueNumber: 1,
    ),
    AppointmentModel(
      id: 'app_3',
      patientName: 'Yousef Haddad',
      clinicName: 'CareNest Pediatrics',
      doctorName: 'Dr. Noor Badr',
      date: DateTime.now().subtract(const Duration(days: 2)),
      timeWindow: '11:00 AM - 11:30 AM',
      status: AppointmentStatus.completed,
      queueNumber: 3,
    ),
    AppointmentModel(
      id: 'app_4',
      patientName: 'Nadia Kamal',
      clinicName: 'BloomCare Clinic',
      doctorName: 'Dr. Rania Soliman',
      date: DateTime.now().subtract(const Duration(days: 6)),
      timeWindow: '2:00 PM - 2:30 PM',
      status: AppointmentStatus.noShow,
      queueNumber: 8,
    ),
    AppointmentModel(
      id: 'app_5',
      patientName: 'Omar Ali',
      clinicName: 'BloomCare Clinic',
      doctorName: 'Dr. Hassan Nasser',
      date: DateTime.now().add(const Duration(days: 3)),
      timeWindow: '1:00 PM - 1:30 PM',
      status: AppointmentStatus.booked,
      queueNumber: 6,
    ),
  ];

  static final List<NotificationModel> notifications = [
    const NotificationModel(
      id: 'n1',
      title: 'Booking confirmed',
      message: 'Your appointment with Dr. Hassan Nasser is confirmed.',
      timestamp: null,
      type: NotificationType.bookingConfirmed,
      isUnread: true,
    ),
    const NotificationModel(
      id: 'n2',
      title: 'Turn approaching',
      message: 'You are 2 patients away from being called.',
      timestamp: null,
      type: NotificationType.turnApproaching,
      isUnread: true,
    ),
    const NotificationModel(
      id: 'n3',
      title: 'Doctor arrived',
      message: 'Dr. Noor Badr has arrived at CareNest Pediatrics.',
      timestamp: null,
      type: NotificationType.doctorArrived,
      isUnread: false,
    ),
    const NotificationModel(
      id: 'n4',
      title: 'Arrival approved',
      message: 'Your arrival has been approved by the clinic assistant.',
      timestamp: null,
      type: NotificationType.arrivalApproved,
      isUnread: false,
    ),
  ];

  static final List<UserModel> users = [
    const UserModel(
      id: 'u1',
      name: 'Hend Aboelouon',
      email: 'hend.aboelouon@example.com',
      role: UserRole.patient,
      phone: '01102177734',
      avatarUrl: '',
    ),
    const UserModel(
      id: 'u2',
      name: 'Sara Al-Khalid',
      email: 'sara@example.com',
      role: UserRole.assistant,
      phone: '01100000000',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
    ),
    const UserModel(
      id: 'u3',
      name: 'Platform Admin',
      email: 'admin@dorakk.com',
      role: UserRole.admin,
      phone: '01111111111',
      avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=300&q=80',
    ),
  ];
}
