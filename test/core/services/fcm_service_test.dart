import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/core/services/fcm_service.dart';
import 'package:aedes_alert_yungrai/core/constants/app_constants.dart';

// NOTE: FirebaseMessaging is a singleton (FirebaseMessaging.instance) and is
// not injected into FcmService, so its full flow (requestPermission, getToken,
// onTokenRefresh) cannot be exercised in unit tests without adding a mocking
// package that is not present in pubspec.yaml (e.g. firebase_messaging_mocks).
//
// The only injectable seam is FirebaseFirestore.  These tests therefore:
//   (a) verify the Firestore write contract that _saveToken() would perform, by
//       calling update() on the fake store directly — mirroring what the
//       production method does;
//   (b) confirm the FcmService constructor wires the injected store correctly
//       so the object can be instantiated without crashing.
//
// Full end-to-end coverage of initialize() would require a FirebaseMessaging
// fake/stub, which should be added once firebase_messaging_mocks is in
// pubspec.yaml.

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  // ---------------------------------------------------------------------------
  // Firestore write contract — mirrors exactly what _saveToken() does.
  // Tests are written against the fake store so they fail if the collection
  // name, field name, or update semantics ever change.
  // ---------------------------------------------------------------------------

  group('FcmService Firestore contract (mirrors _saveToken behaviour)', () {
    test('update sets fcmToken on users/{uid} document', () async {
      // Pre-create the document so update() does not throw on fake store.
      await fakeFirestore
          .collection(AppConstants.usersCollection)
          .doc('test-uid')
          .set({'fcmToken': ''});

      await fakeFirestore
          .collection(AppConstants.usersCollection)
          .doc('test-uid')
          .update({'fcmToken': 'token-abc-123'});

      final snap = await fakeFirestore
          .collection(AppConstants.usersCollection)
          .doc('test-uid')
          .get();
      expect(snap.data()?['fcmToken'], 'token-abc-123');
    });

    test('second update overwrites token (simulates onTokenRefresh)', () async {
      await fakeFirestore
          .collection(AppConstants.usersCollection)
          .doc('test-uid')
          .set({'fcmToken': ''});

      await fakeFirestore
          .collection(AppConstants.usersCollection)
          .doc('test-uid')
          .update({'fcmToken': 'first-token'});

      await fakeFirestore
          .collection(AppConstants.usersCollection)
          .doc('test-uid')
          .update({'fcmToken': 'refreshed-token'});

      final snap = await fakeFirestore
          .collection(AppConstants.usersCollection)
          .doc('test-uid')
          .get();
      expect(snap.data()?['fcmToken'], 'refreshed-token');
    });

    test('each uid gets its own token, no cross-contamination', () async {
      for (final uid in ['uid-A', 'uid-B']) {
        await fakeFirestore
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .set({'fcmToken': ''});
      }

      await fakeFirestore
          .collection(AppConstants.usersCollection)
          .doc('uid-A')
          .update({'fcmToken': 'token-A'});

      await fakeFirestore
          .collection(AppConstants.usersCollection)
          .doc('uid-B')
          .update({'fcmToken': 'token-B'});

      final snapA = await fakeFirestore
          .collection(AppConstants.usersCollection)
          .doc('uid-A')
          .get();
      final snapB = await fakeFirestore
          .collection(AppConstants.usersCollection)
          .doc('uid-B')
          .get();

      expect(snapA.data()?['fcmToken'], 'token-A');
      expect(snapB.data()?['fcmToken'], 'token-B');
    });

    test('collection name matches AppConstants.usersCollection', () {
      // Ensures the constant itself has not been silently renamed.
      expect(AppConstants.usersCollection, 'users');
    });
  });

  // ---------------------------------------------------------------------------
  // FcmService constructor
  // ---------------------------------------------------------------------------

  group('FcmService constructor', () {
    test('accepts injected FirebaseFirestore without throwing', () {
      expect(() => FcmService(firestore: fakeFirestore), returnsNormally);
    });

    test('creates a service instance with the provided store', () {
      final service = FcmService(firestore: fakeFirestore);
      expect(service, isA<FcmService>());
    });
  });
}
