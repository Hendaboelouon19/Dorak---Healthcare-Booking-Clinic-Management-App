import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:dorak_app/app.dart';
import 'package:dorak_app/providers/appointment_provider.dart';
import 'package:dorak_app/providers/auth_provider.dart';
import 'package:dorak_app/providers/clinic_provider.dart';
import 'package:dorak_app/providers/notification_provider.dart';
import 'package:dorak_app/providers/queue_provider.dart';

void main() {
  testWidgets('Dorakk app loads the splash screen', (tester) async {
    await tester.pumpWidget(
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

    expect(find.text('Dorakk'), findsWidgets);
  });
}
