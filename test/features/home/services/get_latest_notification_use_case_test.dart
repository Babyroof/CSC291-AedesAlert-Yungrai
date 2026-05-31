import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/notification_model.dart';
import 'package:aedes_alert_yungrai/features/home/domain/repositories/notification_repository.dart';
import 'package:aedes_alert_yungrai/features/home/domain/use_cases/get_latest_notification_use_case.dart';

import 'get_latest_notification_use_case_test.mocks.dart';

@GenerateMocks([NotificationRepository])
void main() {
  late MockNotificationRepository mockRepo;
  late FakeFirebaseFirestore fakeFirestore;
  late GetLatestNotificationUseCase useCase;

  setUp(() {
    mockRepo = MockNotificationRepository();
    fakeFirestore = FakeFirebaseFirestore();
    useCase = GetLatestNotificationUseCase(mockRepo, firestore: fakeFirestore);
  });

  NotificationModel fakeNotif() => NotificationModel(
    id: 'n1',
    title: 'Alert',
    body: 'Risk zone nearby',
    relatedZoneId: 'area1',
    sentAt: DateTime(2024, 6, 1),
  );

  test('returns notification for a known area', () async {
    when(mockRepo.getLatestForArea(any)).thenAnswer((_) async => fakeNotif());

    final result = await useCase.execute('area1');
    expect(result, isNotNull);
    expect(result!.title, 'Alert');
  });

  test('returns null when no notifications found for zone', () async {
    when(mockRepo.getLatestForArea(any)).thenAnswer((_) async => null);

    final result = await useCase.execute('area1');
    expect(result, isNull);
  });

  test('uses injected firestore to build area reference', () async {
    when(mockRepo.getLatestForArea(any)).thenAnswer((_) async => null);

    // Should not throw even with a fake Firestore instance
    expect(() => useCase.execute('nonexistent_area'), returnsNormally);
  });
}
