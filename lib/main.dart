import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/appointment_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/clinic_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/queue_provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ClinicProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => QueueProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const DorakkApp(),
    ),
  );
}
