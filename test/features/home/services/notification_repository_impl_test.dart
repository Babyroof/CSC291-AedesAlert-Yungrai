import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/features/home/services/notification_repository_impl.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late NotificationRepositoryImpl repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = NotificationRepositoryImpl(fakeFirestore);
  });

  test('returns null when no notifications exist for area', () async {
    final areaRef = fakeFirestore.collection('areas').doc('area1');
    final result = await repository.getLatestForArea(areaRef);
    expect(result, isNull);
  });

  test('returns the most recent notification for area', () async {
    final areaRef = fakeFirestore.collection('areas').doc('area1');

    await fakeFirestore.collection('notifications').add({
      'title': 'Old Alert',
      'body': 'Old body',
      'relatedZone': areaRef,
      'sentAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
    });
    await fakeFirestore.collection('notifications').add({
      'title': 'New Alert',
      'body': 'New body',
      'relatedZone': areaRef,
      'sentAt': Timestamp.fromDate(DateTime(2024, 6, 1)),
    });

    final result = await repository.getLatestForArea(areaRef);
    expect(result, isNotNull);
    expect(result!.title, 'New Alert');
  });

  test('returns null for a different area reference', () async {
    final areaRef1 = fakeFirestore.collection('areas').doc('area1');
    final areaRef2 = fakeFirestore.collection('areas').doc('area2');

    await fakeFirestore.collection('notifications').add({
      'title': 'Alert for area1',
      'body': 'body',
      'relatedZone': areaRef1,
      'sentAt': Timestamp.fromDate(DateTime(2024, 6, 1)),
    });

    final result = await repository.getLatestForArea(areaRef2);
    expect(result, isNull);
  });

  test('relatedZoneId is populated on returned model', () async {
    final areaRef = fakeFirestore.collection('areas').doc('zoneX');
    await fakeFirestore.collection('notifications').add({
      'title': 'T',
      'body': 'B',
      'relatedZone': areaRef,
      'sentAt': Timestamp.fromDate(DateTime(2024, 3, 15)),
    });

    final result = await repository.getLatestForArea(areaRef);
    expect(result!.relatedZoneId, 'zoneX');
  });
}
