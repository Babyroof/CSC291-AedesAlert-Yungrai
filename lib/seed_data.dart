// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';

final _db = FirebaseFirestore.instance;

// ─── CLEAR + SEED ─────────────────────────────────────────────
Future<void> clearAndSeedAll() async {
  await clearAll();
  await seedAll();
}

Future<void> removeRadiusFromAreas() async {
  final snapshot = await _db.collection('areas').get();
  for (final doc in snapshot.docs) {
    await doc.reference.update({
      'radius': FieldValue.delete(),
    });
  }
  print('✅ Removed radius from ${snapshot.docs.length} area documents');
}

Future<void> removeUpdatedAtFromAreas() async {
  final snapshot = await _db.collection('areas').get();
  for (final doc in snapshot.docs) {
    await doc.reference.update({
      'updatedAt': FieldValue.delete(),
    });
  }
  print('✅ Removed updatedAt from ${snapshot.docs.length} area documents');
}

Future<void> clearAndSeedAreas() async {
  final areasSnapshot = await _db.collection('areas').get();
  for (final doc in areasSnapshot.docs) {
    await doc.reference.delete();
  }
  print('🗑️ Cleared: areas');

  final placesSnapshot = await _db.collection('places').get();
  for (final doc in placesSnapshot.docs) {
    await doc.reference.delete();
  }
  print('🗑️ Cleared: places');

  await seedAreas();
  await seedPlaces();
}

// ─── AREAS — 50 Bangkok Districts × 5 days = 250 documents ───
// Radius = sqrt(actualAreaKm² / π) * 1000 meters
// Days: May 17-21, 2026 at 06:00 each day
// isLatest = true only for May 21 (most recent)
Future<void> seedAreas() async {
  // Base data per district (fixed fields)
  final districts = [
    // ─── CRITICAL ─────────────────────────────────────────
    {
      'district': 'Khlong Toei',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7183, 100.5601),
      'radius': 2080.0,
      'baseRiskScore': 91.2,
      'baseTemp': 36.4,
      'baseHumidity': 82.0,
      'baseRain': 12.5,
    },
    {
      'district': 'Huai Khwang',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7762, 100.5742),
      'radius': 1801.0,
      'baseRiskScore': 85.7,
      'baseTemp': 37.1,
      'baseHumidity': 79.5,
      'baseRain': 8.0,
    },
    {
      'district': 'Din Daeng',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7694, 100.5496),
      'radius': 1625.0,
      'baseRiskScore': 83.4,
      'baseTemp': 36.8,
      'baseHumidity': 80.0,
      'baseRain': 10.2,
    },
    {
      'district': 'Samphanthawong',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7398, 100.5144),
      'radius': 977.0,
      'baseRiskScore': 79.8,
      'baseTemp': 36.2,
      'baseHumidity': 83.0,
      'baseRain': 15.0,
    },
    {
      'district': 'Khlong San',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7274, 100.4987),
      'radius': 1607.0,
      'baseRiskScore': 76.3,
      'baseTemp': 35.9,
      'baseHumidity': 84.5,
      'baseRain': 18.3,
    },
    // ─── HIGH ──────────────────────────────────────────────
    {
      'district': 'Bang Rak',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7245, 100.5247),
      'radius': 1262.0,
      'baseRiskScore': 68.5,
      'baseTemp': 35.5,
      'baseHumidity': 78.0,
      'baseRain': 6.5,
    },
    {
      'district': 'Phra Nakhon',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7563, 100.4930),
      'radius': 1262.0,
      'baseRiskScore': 65.1,
      'baseTemp': 35.2,
      'baseHumidity': 77.5,
      'baseRain': 5.0,
    },
    {
      'district': 'Yannawa',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7010, 100.5335),
      'radius': 2503.0,
      'baseRiskScore': 63.9,
      'baseTemp': 35.8,
      'baseHumidity': 79.0,
      'baseRain': 7.2,
    },
    {
      'district': 'Phaya Thai',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7805, 100.5388),
      'radius': 1635.0,
      'baseRiskScore': 61.4,
      'baseTemp': 35.0,
      'baseHumidity': 76.0,
      'baseRain': 4.5,
    },
    {
      'district': 'Ratchathewi',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7621, 100.5340),
      'radius': 1757.0,
      'baseRiskScore': 59.7,
      'baseTemp': 34.8,
      'baseHumidity': 75.5,
      'baseRain': 3.8,
    },
    {
      'district': 'Pathumwan',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7435, 100.5296),
      'radius': 1635.0,
      'baseRiskScore': 57.2,
      'baseTemp': 34.5,
      'baseHumidity': 74.0,
      'baseRain': 2.5,
    },
    {
      'district': 'Wang Thonglang',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7764, 100.5943),
      'radius': 2080.0,
      'baseRiskScore': 55.8,
      'baseTemp': 35.1,
      'baseHumidity': 76.5,
      'baseRain': 5.5,
    },
    {
      'district': 'Prawet',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6934, 100.6432),
      'radius': 4997.0,
      'baseRiskScore': 53.4,
      'baseTemp': 35.3,
      'baseHumidity': 77.0,
      'baseRain': 6.0,
    },
    {
      'district': 'Suan Luang',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7299, 100.6147),
      'radius': 2838.0,
      'baseRiskScore': 51.9,
      'baseTemp': 35.0,
      'baseHumidity': 76.0,
      'baseRain': 5.8,
    },
    // ─── MEDIUM ────────────────────────────────────────────
    {
      'district': 'Dusit',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7832, 100.5130),
      'radius': 1664.0,
      'baseRiskScore': 44.6,
      'baseTemp': 34.2,
      'baseHumidity': 73.0,
      'baseRain': 2.0,
    },
    {
      'district': 'Thon Buri',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7274, 100.4769),
      'radius': 2490.0,
      'baseRiskScore': 43.1,
      'baseTemp': 34.0,
      'baseHumidity': 72.5,
      'baseRain': 1.8,
    },
    {
      'district': 'Bangkok Yai',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7263, 100.4832),
      'radius': 1836.0,
      'baseRiskScore': 41.8,
      'baseTemp': 33.8,
      'baseHumidity': 72.0,
      'baseRain': 1.5,
    },
    {
      'district': 'Bangkok Noi',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7671, 100.4782),
      'radius': 2555.0,
      'baseRiskScore': 40.3,
      'baseTemp': 33.5,
      'baseHumidity': 71.5,
      'baseRain': 1.2,
    },
    {
      'district': 'Lat Phrao',
      'province': 'Bangkok',
      'location': const GeoPoint(13.8189, 100.5703),
      'radius': 2664.0,
      'baseRiskScore': 39.5,
      'baseTemp': 33.2,
      'baseHumidity': 71.0,
      'baseRain': 1.0,
    },
    {
      'district': 'Chom Thong',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6958, 100.4784),
      'radius': 3216.0,
      'baseRiskScore': 38.2,
      'baseTemp': 33.0,
      'baseHumidity': 70.5,
      'baseRain': 0.8,
    },
    {
      'district': 'Rat Burana',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6712, 100.5071),
      'radius': 2948.0,
      'baseRiskScore': 37.1,
      'baseTemp': 32.8,
      'baseHumidity': 70.0,
      'baseRain': 0.5,
    },
    {
      'district': 'Phasi Charoen',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7161, 100.4480),
      'radius': 3065.0,
      'baseRiskScore': 36.4,
      'baseTemp': 32.5,
      'baseHumidity': 69.5,
      'baseRain': 0.3,
    },
    {
      'district': 'Bang Kho Laem',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6968, 100.5188),
      'radius': 2228.0,
      'baseRiskScore': 35.7,
      'baseTemp': 32.3,
      'baseHumidity': 69.0,
      'baseRain': 0.0,
    },
    {
      'district': 'Saphan Sung',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7595, 100.6638),
      'radius': 3427.0,
      'baseRiskScore': 34.9,
      'baseTemp': 32.0,
      'baseHumidity': 68.5,
      'baseRain': 0.0,
    },
    {
      'district': 'Bueng Kum',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7966, 100.6443),
      'radius': 3284.0,
      'baseRiskScore': 33.6,
      'baseTemp': 31.8,
      'baseHumidity': 68.0,
      'baseRain': 0.0,
    },
    {
      'district': 'Taling Chan',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7784, 100.4449),
      'radius': 3328.0,
      'baseRiskScore': 32.4,
      'baseTemp': 31.5,
      'baseHumidity': 67.5,
      'baseRain': 0.0,
    },
    {
      'district': 'Chatuchak',
      'province': 'Bangkok',
      'location': const GeoPoint(13.8197, 100.5536),
      'radius': 2803.0,
      'baseRiskScore': 31.8,
      'baseTemp': 31.2,
      'baseHumidity': 67.0,
      'baseRain': 0.0,
    },
    {
      'district': 'Don Mueang',
      'province': 'Bangkok',
      'location': const GeoPoint(13.9125, 100.5966),
      'radius': 4813.0,
      'baseRiskScore': 30.5,
      'baseTemp': 31.0,
      'baseHumidity': 66.5,
      'baseRain': 0.0,
    },
    // ─── LOW ───────────────────────────────────────────────
    {
      'district': 'Lak Si',
      'province': 'Bangkok',
      'location': const GeoPoint(13.8690, 100.5706),
      'radius': 2975.0,
      'baseRiskScore': 22.4,
      'baseTemp': 30.5,
      'baseHumidity': 65.0,
      'baseRain': 0.0,
    },
    {
      'district': 'Sai Mai',
      'province': 'Bangkok',
      'location': const GeoPoint(13.9196, 100.6464),
      'radius': 5703.0,
      'baseRiskScore': 21.8,
      'baseTemp': 30.2,
      'baseHumidity': 64.5,
      'baseRain': 0.0,
    },
    {
      'district': 'Khan Na Yao',
      'province': 'Bangkok',
      'location': const GeoPoint(13.8322, 100.6764),
      'radius': 3496.0,
      'baseRiskScore': 20.3,
      'baseTemp': 30.0,
      'baseHumidity': 64.0,
      'baseRain': 0.0,
    },
    {
      'district': 'Min Buri',
      'province': 'Bangkok',
      'location': const GeoPoint(13.8136, 100.7481),
      'radius': 4188.0,
      'baseRiskScore': 19.7,
      'baseTemp': 29.8,
      'baseHumidity': 63.5,
      'baseRain': 0.0,
    },
    {
      'district': 'Lat Krabang',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7227, 100.7508),
      'radius': 5929.0,
      'baseRiskScore': 18.5,
      'baseTemp': 29.5,
      'baseHumidity': 63.0,
      'baseRain': 0.0,
    },
    {
      'district': 'Nong Chok',
      'province': 'Bangkok',
      'location': const GeoPoint(13.8614, 100.8398),
      'radius': 8672.0,
      'baseRiskScore': 17.2,
      'baseTemp': 29.2,
      'baseHumidity': 62.5,
      'baseRain': 0.0,
    },
    {
      'district': 'Nong Khaem',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6990, 100.3922),
      'radius': 3742.0,
      'baseRiskScore': 16.8,
      'baseTemp': 29.0,
      'baseHumidity': 62.0,
      'baseRain': 0.0,
    },
    {
      'district': 'Bang Khae',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7211, 100.4052),
      'radius': 3394.0,
      'baseRiskScore': 15.9,
      'baseTemp': 28.8,
      'baseHumidity': 61.5,
      'baseRain': 0.0,
    },
    {
      'district': 'Bang Khun Thian',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6480, 100.4547),
      'radius': 4916.0,
      'baseRiskScore': 14.6,
      'baseTemp': 28.5,
      'baseHumidity': 61.0,
      'baseRain': 0.0,
    },
    {
      'district': 'Thawi Watthana',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7761, 100.3672),
      'radius': 4651.0,
      'baseRiskScore': 13.4,
      'baseTemp': 28.2,
      'baseHumidity': 60.5,
      'baseRain': 0.0,
    },
    {
      'district': 'Thung Khru',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6438, 100.4836),
      'radius': 3270.0,
      'baseRiskScore': 12.8,
      'baseTemp': 28.0,
      'baseHumidity': 60.0,
      'baseRain': 0.0,
    },
    {
      'district': 'Bang Bon',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6512, 100.4205),
      'radius': 3720.0,
      'baseRiskScore': 11.3,
      'baseTemp': 27.8,
      'baseHumidity': 59.5,
      'baseRain': 0.0,
    },
    {
      'district': 'Bang Na',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6611, 100.6050),
      'radius': 2986.0,
      'baseRiskScore': 10.7,
      'baseTemp': 27.5,
      'baseHumidity': 59.0,
      'baseRain': 0.0,
    },
    {
      'district': 'Phra Khanong',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7018, 100.5917),
      'radius': 2285.0,
      'baseRiskScore': 9.8,
      'baseTemp': 27.2,
      'baseHumidity': 58.5,
      'baseRain': 0.0,
    },
    {
      'district': 'Pom Prap Sattru Phai',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7527, 100.5094),
      'radius': 644.0,
      'baseRiskScore': 8.4,
      'baseTemp': 27.0,
      'baseHumidity': 58.0,
      'baseRain': 0.0,
    },
    {
      'district': 'Khlong Sam Wa',
      'province': 'Bangkok',
      'location': const GeoPoint(13.8618, 100.7235),
      'radius': 7354.0,
      'baseRiskScore': 7.6,
      'baseTemp': 26.8,
      'baseHumidity': 57.5,
      'baseRain': 0.0,
    },
    {
      'district': 'Bang Sue',
      'province': 'Bangkok',
      'location': const GeoPoint(13.8022, 100.5278),
      'radius': 2148.0,
      'baseRiskScore': 6.9,
      'baseTemp': 26.5,
      'baseHumidity': 57.0,
      'baseRain': 0.0,
    },
    {
      'district': 'Bang Phlat',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7919, 100.4763),
      'radius': 2221.0,
      'baseRiskScore': 6.2,
      'baseTemp': 26.2,
      'baseHumidity': 56.5,
      'baseRain': 0.0,
    },
    {
      'district': 'Vadhana',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7298, 100.5698),
      'radius': 1904.0,
      'baseRiskScore': 5.4,
      'baseTemp': 26.0,
      'baseHumidity': 56.0,
      'baseRain': 0.0,
    },
    {
      'district': 'Sathon',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7200, 100.5250),
      'radius': 1844.0,
      'baseRiskScore': 4.8,
      'baseTemp': 25.8,
      'baseHumidity': 55.5,
      'baseRain': 0.0,
    },
    {
      'district': 'Bang Khen',
      'province': 'Bangkok',
      'location': const GeoPoint(13.8769, 100.5836),
      'radius': 3450.0,
      'baseRiskScore': 3.9,
      'baseTemp': 25.5,
      'baseHumidity': 55.0,
      'baseRain': 0.0,
    },
    {
      'district': 'Phra Pradaeng',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6602, 100.5317),
      'radius': 4409.0,
      'baseRiskScore': 2.5,
      'baseTemp': 25.2,
      'baseHumidity': 54.5,
      'baseRain': 0.0,
    },
  ];

  // 5 days: May 17-21, 2026 at 06:00
  final dates = [
    DateTime(2026, 5, 17, 6, 0),
    DateTime(2026, 5, 18, 6, 0),
    DateTime(2026, 5, 19, 6, 0),
    DateTime(2026, 5, 20, 6, 0),
    DateTime(2026, 5, 21, 6, 0), // latest
  ];

  // daily variation offsets per day index (0..4)
  // slight fluctuation to make data realistic
  final riskDelta   = [-3.1, -1.5,  0.0,  1.8,  0.0];
  final tempDelta   = [-0.6, -0.3,  0.0,  0.4,  0.0];
  final humDelta    = [ 1.5,  0.8,  0.0, -1.0,  0.0];
  final rainDelta   = [-2.0, -1.0,  0.0,  1.5,  0.0];

  int count = 0;
  for (final d in districts) {
    for (int i = 0; i < dates.length; i++) {
      final isLatest = i == dates.length - 1;
      final rawScore = (d['baseRiskScore'] as double) + riskDelta[i];
      final riskScore = double.parse(rawScore.clamp(0.0, 100.0).toStringAsFixed(1));
      final riskLevel = riskScore >= 75.0
          ? 'critical'
          : riskScore >= 50.0
              ? 'high'
              : riskScore >= 25.0
                  ? 'medium'
                  : 'low';
      final temperature = double.parse(
          ((d['baseTemp'] as double) + tempDelta[i]).toStringAsFixed(1));
      final humidity = double.parse(
          ((d['baseHumidity'] as double) + humDelta[i]).clamp(0.0, 100.0).toStringAsFixed(1));
      final rain = double.parse(
          ((d['baseRain'] as double) + rainDelta[i]).clamp(0.0, 999.0).toStringAsFixed(1));

      await _db.collection('areas').add({
        'district': d['district'],
        'province': d['province'],
        'location': d['location'],
        'radius': d['radius'],
        'riskScore': riskScore,
        'riskLevel': riskLevel,
        'temperature': temperature,
        'humidity': humidity,
        'rain': rain,
        'reportedAt': Timestamp.fromDate(dates[i]),
        'isLatest': isLatest,
        'updatedAt': Timestamp.now(),
      });
      count++;
    }
  }
  print('✅ Areas seeded ($count documents — ${districts.length} districts × ${dates.length} days)');
}

Future<void> clearAll() async {
  final collections = ['users', 'areas', 'places', 'information', 'notifications', 'news'];
  for (final name in collections) {
    final snapshot = await _db.collection(name).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
    print('🗑️ Cleared: $name');
  }
  print('🗑️ All collections cleared');
}

Future<void> seedAll() async {
  await seedUsers();
  await seedAreas();
  await seedPlaces();
  await seedInformation();
  await seedNotifications();
  await seedNews();
  print('✅ All seed data completed!');
}

// ─── 1. USERS ────────────────────────────────────────────────
Future<void> seedUsers() async {
  final users = [
    {
      'firstName': 'Somchai',
      'lastName': 'Jaidee',
      'email': 'somchai@email.com',
      'phoneNumber': '0812345678',
      'fcmToken': 'fcm_token_001',
      'notificationsEnabled': true,
    },
    {
      'firstName': 'Malee',
      'lastName': 'Rakthai',
      'email': 'malee@email.com',
      'phoneNumber': '0898765432',
      'fcmToken': 'fcm_token_002',
      'notificationsEnabled': false,
    },
    {
      'firstName': 'Wichai',
      'lastName': 'Suksun',
      'email': 'wichai@email.com',
      'phoneNumber': '0867654321',
      'fcmToken': 'fcm_token_003',
      'notificationsEnabled': true,
    },
  ];
  for (final user in users) {
    await _db.collection('users').add(user);
  }
  print('✅ Users seeded');
}

// ─── 3. PLACES ───────────────────────────────────────────────
Future<void> seedPlaces() async {
  final places = [
    {
      'name': 'King Chulalongkorn Memorial Hospital',
      'description': 'Large public hospital under Thai Red Cross, open 24 hours',
      'location': const GeoPoint(13.7330, 100.5347),
      'phoneNumber': '02-256-4000',
      'type': 'hospital',
    },
    {
      'name': 'Ramathibodi Hospital',
      'description': 'University hospital, Faculty of Medicine Mahidol University',
      'location': const GeoPoint(13.7651, 100.5278),
      'phoneNumber': '02-201-1000',
      'type': 'hospital',
    },
    {
      'name': 'Bumrungrad International Hospital',
      'description': 'Private international hospital in Sukhumvit',
      'location': const GeoPoint(13.7441, 100.5546),
      'phoneNumber': '02-066-8888',
      'type': 'hospital',
    },
    {
      'name': 'Bangkok Hospital',
      'description': 'Private hospital, New Phetchaburi Road',
      'location': const GeoPoint(13.7526, 100.5697),
      'phoneNumber': '02-310-3000',
      'type': 'hospital',
    },
    {
      'name': 'Samitivej Sukhumvit Hospital',
      'description': 'Private hospital on Sukhumvit 49',
      'location': const GeoPoint(13.7301, 100.5849),
      'phoneNumber': '02-022-2222',
      'type': 'hospital',
    },
    {
      'name': 'Phyathai 2 Hospital',
      'description': 'Private hospital near Victory Monument',
      'location': const GeoPoint(13.7622, 100.5387),
      'phoneNumber': '02-617-2444',
      'type': 'hospital',
    },
    {
      'name': 'Silom Medical Clinic',
      'description': 'General clinic in Silom area, open 08:00 - 20:00',
      'location': const GeoPoint(13.7267, 100.5231),
      'phoneNumber': '02-234-5678',
      'type': 'clinic',
    },
    {
      'name': 'On Nut Community Clinic',
      'description': 'Community clinic, accepts universal healthcare card',
      'location': const GeoPoint(13.7019, 100.6012),
      'phoneNumber': '02-321-4567',
      'type': 'clinic',
    },
    {
      'name': 'Ladprao Family Clinic',
      'description': 'General clinic, open 08:00 - 21:00',
      'location': const GeoPoint(13.8156, 100.5612),
      'phoneNumber': '02-512-3456',
      'type': 'clinic',
    },
    {
      'name': 'Huai Khwang Health Clinic',
      'description': 'Community clinic near MRT Huai Khwang',
      'location': const GeoPoint(13.7748, 100.5756),
      'phoneNumber': '02-276-5678',
      'type': 'clinic',
    },
  ];
  for (final place in places) {
    await _db.collection('places').add(place);
  }
  print('✅ Places seeded');
}

// ─── 4. INFORMATION ──────────────────────────────────────────
Future<void> seedInformation() async {
  final information = [
    {
      'title': 'What is the Aedes Mosquito?',
      'content':
          'The Aedes aegypti mosquito is the primary carrier of dengue fever. It has distinctive black and white markings on its legs and body. Unlike other mosquitoes, it is most active during the day, especially in the early morning and late afternoon.',
      'imageHeader': 'https://images.unsplash.com/photo-1599940824399-b87987ceb72a?w=800',
      'source': 'Department of Disease Control, Ministry of Public Health',
    },
    {
      'title': 'How to Prevent Mosquito Breeding',
      'content':
          '1. Remove standing water around your home\n2. Cover all water storage containers\n3. Change water in vases every week\n4. Use mosquito larvicide (Abate) in containers that cannot be covered\n5. Wear long-sleeved clothing when outdoors',
      'imageHeader': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800',
      'source': 'Bangkok Metropolitan Administration Health Department',
    },
    {
      'title': 'Symptoms of Dengue Fever',
      'content':
          'Dengue fever typically causes sudden high fever lasting 2-7 days, severe headache, pain behind the eyes, muscle and joint pain, nausea, vomiting, and a skin rash. If you experience these symptoms, seek medical attention immediately.',
      'imageHeader': 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800',
      'source': 'King Chulalongkorn Memorial Hospital',
    },
  ];
  for (final info in information) {
    await _db.collection('information').add(info);
  }
  print('✅ Information seeded');
}

// ─── 5. NOTIFICATIONS ────────────────────────────────────────
Future<void> seedNotifications() async {
  final areasSnapshot = await _db
      .collection('areas')
      .where('isLatest', isEqualTo: true)
      .limit(2)
      .get();
  final areaRefs = areasSnapshot.docs.map((d) => d.reference).toList();

  final notifications = [
    {
      'title': '⚠️ Outbreak Detected in Khlong Toei',
      'body': 'Dengue fever cases have surged in Khlong Toei district. Please eliminate standing water around your home.',
      'relatedZone': areaRefs.isNotEmpty ? areaRefs[0] : null,
      'sentAt': Timestamp.fromDate(DateTime(2026, 5, 21, 7, 0)),
    },
    {
      'title': '📢 High Risk Area — Huai Khwang',
      'body': 'Huai Khwang district is rated critical risk. Residents are advised to take precautionary measures immediately.',
      'relatedZone': areaRefs.length > 1 ? areaRefs[1] : null,
      'sentAt': Timestamp.fromDate(DateTime(2026, 5, 20, 7, 0)),
    },
    {
      'title': '✅ Risk Level Improved — Bang Khen',
      'body': 'Bang Khen district has been downgraded to low risk. Keep up the good work in keeping your area clean.',
      'relatedZone': null,
      'sentAt': Timestamp.fromDate(DateTime(2026, 5, 19, 7, 0)),
    },
  ];
  for (final notif in notifications) {
    await _db.collection('notifications').add(notif);
  }
  print('✅ Notifications seeded');
}

// ─── 6. NEWS ─────────────────────────────────────────────────
Future<void> seedNews() async {
  final news = [
    {
      'title': 'Warning: Dengue Fever Cases Surge During Rainy Season',
      'description':
          'Health authorities report a significant increase in dengue fever cases across Bangkok. Residents are urged to eliminate standing water around their homes to reduce mosquito breeding sites.',
      'imageUrl': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800',
      'sourceName': 'Department of Disease Control',
      'sourceUrl': 'https://ddc.moph.go.th',
      'publishedAt': Timestamp.fromDate(DateTime(2026, 5, 20, 9, 0)),
      'originalId': 'ddc_001',
      'createdAt': Timestamp.now(),
    },
    {
      'title': 'Bangkok Records Highest Dengue Cases in 5 Years',
      'description':
          'Bangkok has reported over 3,500 dengue cases this year, the highest in five years. Local health officials are launching emergency mosquito control campaigns in high-risk districts.',
      'imageUrl': 'https://images.unsplash.com/photo-1631815589968-fdb09a223b1e?w=800',
      'sourceName': 'ThaiPBS',
      'sourceUrl': 'https://www.thaipbs.or.th',
      'publishedAt': Timestamp.fromDate(DateTime(2026, 5, 18, 14, 30)),
      'originalId': 'thaipbs_002',
      'createdAt': Timestamp.now(),
    },
    {
      'title': 'How to Identify Aedes Mosquito Breeding Sites at Home',
      'description':
          'Experts share practical tips on identifying and eliminating common Aedes mosquito breeding spots, including flower pot saucers, water containers, and clogged gutters.',
      'imageUrl': 'https://images.unsplash.com/photo-1599940824399-b87987ceb72a?w=800',
      'sourceName': 'Mahidol University',
      'sourceUrl': 'https://www.mahidol.ac.th',
      'publishedAt': Timestamp.fromDate(DateTime(2026, 5, 15, 10, 0)),
      'originalId': 'mahidol_003',
      'createdAt': Timestamp.now(),
    },
    {
      'title': 'Thailand Launches National Dengue Prevention Week',
      'description':
          'The Ministry of Public Health has announced a national dengue prevention week campaign, encouraging communities to clean up potential mosquito breeding sites simultaneously across the country.',
      'imageUrl': 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800',
      'sourceName': 'Ministry of Public Health',
      'sourceUrl': 'https://www.moph.go.th',
      'publishedAt': Timestamp.fromDate(DateTime(2026, 5, 12, 8, 0)),
      'originalId': 'moph_004',
      'createdAt': Timestamp.now(),
    },
    {
      'title': 'New Rapid Test for Dengue Fever Now Available at Clinics',
      'description':
          'A new rapid diagnostic test for dengue fever is now available at clinics nationwide. The test provides results within 15 minutes, allowing faster treatment and reducing complications.',
      'imageUrl': 'https://images.unsplash.com/photo-1581595219315-a187dd40c322?w=800',
      'sourceName': 'Bangkok Post',
      'sourceUrl': 'https://www.bangkokpost.com',
      'publishedAt': Timestamp.fromDate(DateTime(2026, 5, 10, 11, 0)),
      'originalId': 'bkpost_005',
      'createdAt': Timestamp.now(),
    },
  ];

  for (final article in news) {
    final existing = await _db
        .collection('news')
        .where('originalId', isEqualTo: article['originalId'])
        .limit(1)
        .get();
    if (existing.docs.isEmpty) {
      await _db.collection('news').add(article);
      print('✅ Added: ${article['title']}');
    } else {
      print('⚠️ Skipped (duplicate): ${article['title']}');
    }
  }
  print('✅ News seeded');
}