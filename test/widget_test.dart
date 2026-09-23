import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:dorak_app/app.dart';
import 'package:dorak_app/models/doctor_model.dart';
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

  test('fallback slots are generated when doctor slots are empty', () {
    final slots = ClinicProvider.buildFallbackSlotsForDoctor(
      const DoctorModel(
        id: 'doctor-1',
        name: 'Dr. Hend Aboelouon',
        specialty: 'Cardiology',
      ),
    );

    expect(slots, isNotEmpty);
    expect(slots.length >= 5, isTrue);
    expect(slots.every((slot) => slot.status == 'available'), isTrue);
  });

  test('demo fallback slots are treated as valid booking slots', () {
    final slotId = 'fallback-doctor-1-0-9';

    expect(AppointmentProvider.isFallbackSlot(slotId), isTrue);
    expect(AppointmentProvider.parseFallbackSlotStartAt(slotId), isNotNull);
    expect(AppointmentProvider.isFallbackSlot('slot-123'), isFalse);
  });
}
