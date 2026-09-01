import 'package:flutter/material.dart';

import 'routes/app_routes.dart';

// Shared screens
import 'screens/shared/splash_screen.dart' as splash;
import 'screens/shared/role_select_screen.dart' as role_select;
import 'screens/shared/login_screen.dart' as login;
import 'screens/shared/signup_screen.dart' as signup;

// Patient screens
import 'screens/patient/patient_home_screen.dart';
import 'screens/patient/clinic_discovery_screen.dart';
import 'screens/patient/clinic_details_screen.dart';
import 'screens/patient/book_appointment_screen.dart';
import 'screens/patient/booking_confirmation_screen.dart';
import 'screens/patient/live_queue_screen.dart';
import 'screens/patient/appointment_history_screen.dart';
import 'screens/patient/notifications_screen.dart';
import 'screens/patient/patient_profile_screen.dart';

// Assistant screens
import 'screens/assistant/assistant_dashboard_screen.dart';
import 'screens/assistant/arrival_approval_screen.dart';
import 'screens/assistant/active_queue_screen.dart';
import 'screens/assistant/announce_doctor_screen.dart';
import 'screens/assistant/manage_doctors_services_screen.dart';

// Admin screens
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/clinics_management_screen.dart';
import 'screens/admin/clinic_edit_screen.dart';
import 'screens/admin/assistants_management_screen.dart';
import 'screens/admin/clinic_performance_screen.dart';
import 'screens/admin/platform_settings_screen.dart';

// Theme
import 'theme/app_theme.dart';

class DorakkApp extends StatelessWidget {
  const DorakkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dorak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      initialRoute: AppRoutes.splash,

      routes: {
        // ---------------- SHARED / AUTH ----------------

        AppRoutes.splash: (_) => splash.SplashScreen(),

        // Keeping this route registered for now,
        // but Splash should NOT navigate to it anymore.
        AppRoutes.roleSelect: (_) =>
            const role_select.RoleSelectScreen(),

        AppRoutes.login: (_) =>
            const login.LoginScreen(),

        AppRoutes.signup: (_) =>
            const signup.SignupScreen(),

        // ---------------- PATIENT ----------------

        AppRoutes.patientHome: (_) =>
            const PatientHomeScreen(),

        AppRoutes.clinicDiscovery: (_) =>
            const ClinicDiscoveryScreen(),

        AppRoutes.clinicDetails: (_) =>
            const ClinicDetailsScreen(),

        AppRoutes.bookAppointment: (_) =>
            const BookAppointmentScreen(),

        AppRoutes.bookingConfirmation: (_) =>
            const BookingConfirmationScreen(),

        AppRoutes.liveQueue: (_) =>
            const LiveQueueScreen(),

        AppRoutes.appointmentHistory: (_) =>
            const AppointmentHistoryScreen(),

        AppRoutes.patientNotifications: (_) =>
            const NotificationsScreen(),

        AppRoutes.patientProfile: (_) =>
            const PatientProfileScreen(),

        // ---------------- ASSISTANT ----------------

        AppRoutes.assistantDashboard: (_) =>
            const AssistantDashboardScreen(),

        AppRoutes.arrivalApproval: (_) =>
            const ArrivalApprovalScreen(),

        AppRoutes.activeQueue: (_) =>
            const ActiveQueueScreen(),

        AppRoutes.announceDoctor: (_) =>
            const AnnounceDoctorScreen(),

        AppRoutes.manageDoctors: (_) =>
            const ManageDoctorsServicesScreen(),

        // ---------------- ADMIN ----------------

        AppRoutes.adminDashboard: (_) =>
            const AdminDashboardScreen(),

        AppRoutes.clinicsManagement: (_) =>
            const ClinicsManagementScreen(),

        AppRoutes.clinicEdit: (_) =>
            const ClinicEditScreen(),

        AppRoutes.assistantsManagement: (_) =>
            const AssistantsManagementScreen(),

        AppRoutes.clinicPerformance: (_) =>
            const ClinicPerformanceScreen(),

        AppRoutes.platformSettings: (_) =>
            const PlatformSettingsScreen(),
      },
    );
  }
}