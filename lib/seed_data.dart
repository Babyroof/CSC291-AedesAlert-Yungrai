// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';

final _db = FirebaseFirestore.instance;

// ─── CLEAR + SEED ─────────────────────────────────────────────
Future<void> clearAndSeedAll() async {
  await clearAll();
  await seedAll();
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

// ─── AREAS — All 50 Bangkok Districts ────────────────────────
Future<void> seedAreas() async {
  final areas = [
    // ─── HIGH DENSITY / HIGH RISK ───
    {
      'subDistrict': 'Khlong Toei',
      'district': 'Khlong Toei',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7183, 100.5601),
      'radius': 800.0,
      'riskScore': 91.2,
      'riskLevel': 'critical',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 4, 3)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Khlong San',
      'district': 'Khlong San',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7274, 100.4987),
      'radius': 600.0,
      'riskScore': 85.7,
      'riskLevel': 'critical',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 4, 7)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Samphanthawong',
      'district': 'Samphanthawong',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7398, 100.5144),
      'radius': 500.0,
      'riskScore': 83.4,
      'riskLevel': 'critical',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 4, 10)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Huai Khwang',
      'district': 'Huai Khwang',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7762, 100.5742),
      'radius': 700.0,
      'riskScore': 79.8,
      'riskLevel': 'critical',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 4, 12)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Din Daeng',
      'district': 'Din Daeng',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7694, 100.5496),
      'radius': 600.0,
      'riskScore': 76.3,
      'riskLevel': 'critical',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 4, 15)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },

    // ─── HIGH RISK ───
    {
      'subDistrict': 'Bang Rak',
      'district': 'Bang Rak',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7245, 100.5247),
      'radius': 500.0,
      'riskScore': 68.5,
      'riskLevel': 'high',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 4, 18)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Phra Nakhon',
      'district': 'Phra Nakhon',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7563, 100.4930),
      'radius': 600.0,
      'riskScore': 65.1,
      'riskLevel': 'high',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 4, 20)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Yannawa',
      'district': 'Yannawa',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7010, 100.5335),
      'radius': 650.0,
      'riskScore': 63.9,
      'riskLevel': 'high',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 4, 22)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Phaya Thai',
      'district': 'Phaya Thai',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7805, 100.5388),
      'radius': 550.0,
      'riskScore': 61.4,
      'riskLevel': 'high',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 4, 25)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Ratchathewi',
      'district': 'Ratchathewi',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7621, 100.5340),
      'radius': 500.0,
      'riskScore': 59.7,
      'riskLevel': 'high',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 4, 27)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Wang Thonglang',
      'district': 'Wang Thonglang',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7764, 100.5943),
      'radius': 600.0,
      'riskScore': 57.2,
      'riskLevel': 'high',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 4, 29)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Pathumwan',
      'district': 'Pathumwan',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7435, 100.5296),
      'radius': 550.0,
      'riskScore': 55.8,
      'riskLevel': 'high',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 1)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Prawet',
      'district': 'Prawet',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6934, 100.6432),
      'radius': 900.0,
      'riskScore': 53.4,
      'riskLevel': 'high',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 2)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Suan Luang',
      'district': 'Suan Luang',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7299, 100.6147),
      'radius': 800.0,
      'riskScore': 51.9,
      'riskLevel': 'high',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 3)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },

    // ─── MEDIUM RISK ───
    {
      'subDistrict': 'Dusit',
      'district': 'Dusit',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7832, 100.5130),
      'radius': 700.0,
      'riskScore': 44.6,
      'riskLevel': 'medium',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 4)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Thon Buri',
      'district': 'Thon Buri',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7274, 100.4769),
      'radius': 700.0,
      'riskScore': 43.1,
      'riskLevel': 'medium',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 4)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Bangkok Yai',
      'district': 'Bangkok Yai',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7263, 100.4832),
      'radius': 600.0,
      'riskScore': 41.8,
      'riskLevel': 'medium',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 5)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Bangkok Noi',
      'district': 'Bangkok Noi',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7671, 100.4782),
      'radius': 650.0,
      'riskScore': 40.3,
      'riskLevel': 'medium',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 5)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Lat Phrao',
      'district': 'Lat Phrao',
      'province': 'Bangkok',
      'location': const GeoPoint(13.8189, 100.5703),
      'radius': 850.0,
      'riskScore': 39.5,
      'riskLevel': 'medium',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 6)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Chom Thong',
      'district': 'Chom Thong',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6958, 100.4784),
      'radius': 750.0,
      'riskScore': 38.2,
      'riskLevel': 'medium',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 6)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Rat Burana',
      'district': 'Rat Burana',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6712, 100.5071),
      'radius': 800.0,
      'riskScore': 37.1,
      'riskLevel': 'medium',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 7)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Phasi Charoen',
      'district': 'Phasi Charoen',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7161, 100.4480),
      'radius': 900.0,
      'riskScore': 36.4,
      'riskLevel': 'medium',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 7)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Bang Kho Laem',
      'district': 'Bang Kho Laem',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6968, 100.5188),
      'radius': 650.0,
      'riskScore': 35.7,
      'riskLevel': 'medium',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 8)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Saphan Sung',
      'district': 'Saphan Sung',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7595, 100.6638),
      'radius': 900.0,
      'riskScore': 34.9,
      'riskLevel': 'medium',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 8)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Bueng Kum',
      'district': 'Bueng Kum',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7966, 100.6443),
      'radius': 850.0,
      'riskScore': 33.6,
      'riskLevel': 'medium',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 9)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Taling Chan',
      'district': 'Taling Chan',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7784, 100.4449),
      'radius': 900.0,
      'riskScore': 32.4,
      'riskLevel': 'medium',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 9)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Chatuchak',
      'district': 'Chatuchak',
      'province': 'Bangkok',
      'location': const GeoPoint(13.8197, 100.5536),
      'radius': 750.0,
      'riskScore': 31.8,
      'riskLevel': 'medium',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 10)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Don Mueang',
      'district': 'Don Mueang',
      'province': 'Bangkok',
      'location': const GeoPoint(13.9125, 100.5966),
      'radius': 1000.0,
      'riskScore': 30.5,
      'riskLevel': 'medium',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 10)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },

    // ─── LOW RISK ───
    {
      'subDistrict': 'Lak Si',
      'district': 'Lak Si',
      'province': 'Bangkok',
      'location': const GeoPoint(13.8690, 100.5706),
      'radius': 900.0,
      'riskScore': 22.4,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 11)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Sai Mai',
      'district': 'Sai Mai',
      'province': 'Bangkok',
      'location': const GeoPoint(13.9196, 100.6464),
      'radius': 1200.0,
      'riskScore': 21.8,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 11)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Khan Na Yao',
      'district': 'Khan Na Yao',
      'province': 'Bangkok',
      'location': const GeoPoint(13.8322, 100.6764),
      'radius': 1000.0,
      'riskScore': 20.3,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 12)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Min Buri',
      'district': 'Min Buri',
      'province': 'Bangkok',
      'location': const GeoPoint(13.8136, 100.7481),
      'radius': 1100.0,
      'riskScore': 19.7,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 12)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Lat Krabang',
      'district': 'Lat Krabang',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7227, 100.7508),
      'radius': 1300.0,
      'riskScore': 18.5,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 13)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Nong Chok',
      'district': 'Nong Chok',
      'province': 'Bangkok',
      'location': const GeoPoint(13.8614, 100.8398),
      'radius': 1500.0,
      'riskScore': 17.2,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 13)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Nong Khaem',
      'district': 'Nong Khaem',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6990, 100.3922),
      'radius': 1100.0,
      'riskScore': 16.8,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 14)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Bang Khae',
      'district': 'Bang Khae',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7211, 100.4052),
      'radius': 1000.0,
      'riskScore': 15.9,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 14)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Bang Khun Thian',
      'district': 'Bang Khun Thian',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6480, 100.4547),
      'radius': 1200.0,
      'riskScore': 14.6,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 15)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Thawi Watthana',
      'district': 'Thawi Watthana',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7761, 100.3672),
      'radius': 1100.0,
      'riskScore': 13.4,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 15)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Thung Khru',
      'district': 'Thung Khru',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6438, 100.4836),
      'radius': 1000.0,
      'riskScore': 12.8,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 16)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Bang Bon',
      'district': 'Bang Bon',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6512, 100.4205),
      'radius': 1000.0,
      'riskScore': 11.3,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 16)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Bang Na',
      'district': 'Bang Na',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6611, 100.6050),
      'radius': 950.0,
      'riskScore': 10.7,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 17)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Phra Khanong',
      'district': 'Phra Khanong',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7018, 100.5917),
      'radius': 700.0,
      'riskScore': 9.8,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 17)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Pom Prap Sattru Phai',
      'district': 'Pom Prap Sattru Phai',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7527, 100.5094),
      'radius': 450.0,
      'riskScore': 8.4,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 18)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Khlong Sam Wa',
      'district': 'Khlong Sam Wa',
      'province': 'Bangkok',
      'location': const GeoPoint(13.8618, 100.7235),
      'radius': 1400.0,
      'riskScore': 7.6,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 18)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Bang Sue',
      'district': 'Bang Sue',
      'province': 'Bangkok',
      'location': const GeoPoint(13.8022, 100.5278),
      'radius': 600.0,
      'riskScore': 6.9,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 19)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Bang Phlat',
      'district': 'Bang Phlat',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7919, 100.4763),
      'radius': 650.0,
      'riskScore': 6.2,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 19)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Dok Mai',
      'district': 'Prawet',
      'province': 'Bangkok',
      'location': const GeoPoint(13.6724, 100.6721),
      'radius': 800.0,
      'riskScore': 5.4,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 20)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
    {
      'subDistrict': 'Vadhana',
      'district': 'Vadhana',
      'province': 'Bangkok',
      'location': const GeoPoint(13.7298, 100.5698),
      'radius': 600.0,
      'riskScore': 4.8,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 20)),
      'updatedAt': Timestamp.now(),
      'isLatest': true,
    },
  ];

  for (final area in areas) {
    await _db.collection('areas').add(area);
  }
  print('✅ Areas seeded (${areas.length} Bangkok districts)');
}

Future<void> clearAll() async {
  final collections = [
    'users',
    'areas',
    'places',
    'information',
    'notifications',
    'news',
  ];

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
  //await seedAreas();
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

// ─── 2. AREAS ────────────────────────────────────────────────

// ─── 3. PLACES ───────────────────────────────────────────────
// ─── 3. PLACES ───────────────────────────────────────────────
Future<void> seedPlaces() async {
  final places = [
    {
      'name': 'King Chulalongkorn Memorial Hospital',
      'description':
          'Large public hospital under Thai Red Cross, open 24 hours',
      'location': const GeoPoint(13.7330, 100.5347),
      'phoneNumber': '02-256-4000',
      'type': 'hospital',
    },
    {
      'name': 'Ramathibodi Hospital',
      'description':
          'University hospital, Faculty of Medicine Mahidol University',
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
      'imageHeader':
          'https://images.unsplash.com/photo-1599940824399-b87987ceb72a?w=800',
      'source': 'Department of Disease Control, Ministry of Public Health',
    },
    {
      'title': 'How to Prevent Mosquito Breeding',
      'content':
          '1. Remove standing water around your home\n2. Cover all water storage containers\n3. Change water in vases every week\n4. Use mosquito larvicide (Abate) in containers that cannot be covered\n5. Wear long-sleeved clothing when outdoors',
      'imageHeader':
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800',
      'source': 'Chiang Mai Provincial Health Office',
    },
    {
      'title': 'Symptoms of Dengue Fever',
      'content':
          'Dengue fever typically causes sudden high fever lasting 2-7 days, severe headache, pain behind the eyes, muscle and joint pain, nausea, vomiting, and a skin rash. If you experience these symptoms, seek medical attention immediately.',
      'imageHeader':
          'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800',
      'source': 'Maharaj Nakorn Chiang Mai Hospital',
    },
  ];

  for (final info in information) {
    await _db.collection('information').add(info);
  }
  print('✅ Information seeded');
}

// ─── 5. NOTIFICATIONS ────────────────────────────────────────
Future<void> seedNotifications() async {
  final areasSnapshot = await _db.collection('areas').limit(2).get();
  final areaRefs = areasSnapshot.docs.map((d) => d.reference).toList();

  final notifications = [
    {
      'title': '⚠️ Outbreak Detected in Suthep Area',
      'body':
          'Dengue fever cases have increased in Suthep subdistrict. Please eliminate standing water around your home.',
      'relatedZone': areaRefs.isNotEmpty ? areaRefs[0] : null,
      'sentAt': Timestamp.now(),
    },
    {
      'title': '📢 High Risk Area Alert',
      'body':
          'Chang Phueak area is rated high risk. Residents are advised to take precautionary measures immediately.',
      'relatedZone': areaRefs.length > 1 ? areaRefs[1] : null,
      'sentAt': Timestamp.fromDate(
        DateTime.now().subtract(const Duration(days: 1)),
      ),
    },
    {
      'title': '✅ Risk Level Improved',
      'body':
          'Pa Tan subdistrict has been downgraded to low risk. Keep up the good work in keeping your area clean.',
      'relatedZone': null,
      'sentAt': Timestamp.fromDate(
        DateTime.now().subtract(const Duration(days: 3)),
      ),
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
          'Health authorities report a significant increase in dengue fever cases across northern Thailand. Residents are urged to eliminate standing water around their homes to reduce mosquito breeding sites.',
      'imageUrl':
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800',
      'sourceName': 'Department of Disease Control',
      'sourceUrl': 'https://ddc.moph.go.th',
      'publishedAt': Timestamp.fromDate(DateTime(2025, 5, 20, 9, 0)),
      'originalId': 'ddc_001',
      'createdAt': Timestamp.now(),
    },
    {
      'title': 'Chiang Mai Records Highest Dengue Cases in 5 Years',
      'description':
          'Chiang Mai province has reported over 1,200 dengue cases this year, the highest in five years. Local health officials are launching emergency mosquito control campaigns in high-risk areas.',
      'imageUrl':
          'https://images.unsplash.com/photo-1631815589968-fdb09a223b1e?w=800',
      'sourceName': 'ThaiPBS',
      'sourceUrl': 'https://www.thaipbs.or.th',
      'publishedAt': Timestamp.fromDate(DateTime(2025, 5, 18, 14, 30)),
      'originalId': 'thaipbs_002',
      'createdAt': Timestamp.now(),
    },
    {
      'title': 'How to Identify Aedes Mosquito Breeding Sites at Home',
      'description':
          'Experts share practical tips on identifying and eliminating common Aedes mosquito breeding spots, including flower pot saucers, water containers, and clogged gutters.',
      'imageUrl':
          'https://images.unsplash.com/photo-1599940824399-b87987ceb72a?w=800',
      'sourceName': 'Mahidol University',
      'sourceUrl': 'https://www.mahidol.ac.th',
      'publishedAt': Timestamp.fromDate(DateTime(2025, 5, 15, 10, 0)),
      'originalId': 'mahidol_003',
      'createdAt': Timestamp.now(),
    },
    {
      'title': 'Thailand Launches National Dengue Prevention Week',
      'description':
          'The Ministry of Public Health has announced a national dengue prevention week campaign, encouraging communities to clean up potential mosquito breeding sites simultaneously across the country.',
      'imageUrl':
          'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800',
      'sourceName': 'Ministry of Public Health',
      'sourceUrl': 'https://www.moph.go.th',
      'publishedAt': Timestamp.fromDate(DateTime(2025, 5, 12, 8, 0)),
      'originalId': 'moph_004',
      'createdAt': Timestamp.now(),
    },
    {
      'title': 'New Rapid Test for Dengue Fever Now Available at Clinics',
      'description':
          'A new rapid diagnostic test for dengue fever is now available at clinics nationwide. The test provides results within 15 minutes, allowing faster treatment and reducing complications.',
      'imageUrl':
          'https://images.unsplash.com/photo-1581595219315-a187dd40c322?w=800',
      'sourceName': 'Bangkok Post',
      'sourceUrl': 'https://www.bangkokpost.com',
      'publishedAt': Timestamp.fromDate(DateTime(2025, 5, 10, 11, 0)),
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
