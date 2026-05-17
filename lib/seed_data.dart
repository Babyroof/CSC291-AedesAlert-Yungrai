import 'package:cloud_firestore/cloud_firestore.dart';

final _db = FirebaseFirestore.instance;

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

// ─── 2. AREAS ────────────────────────────────────────────────
Future<void> seedAreas() async {
  final areas = [
    {
      'subDistrict': 'Suthep',
      'district': 'Mueang Chiang Mai',
      'province': 'Chiang Mai',
      'location': const GeoPoint(18.7965, 98.9529),
      'radius': 500.0,
      'riskScore': 87.5,
      'riskLevel': 'critical',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 1)),
      'updatedAt': Timestamp.now(),
    },
    {
      'subDistrict': 'Chang Phueak',
      'district': 'Mueang Chiang Mai',
      'province': 'Chiang Mai',
      'location': const GeoPoint(18.8120, 98.9730),
      'radius': 300.0,
      'riskScore': 62.0,
      'riskLevel': 'high',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 10)),
      'updatedAt': Timestamp.now(),
    },
    {
      'subDistrict': 'Hai Ya',
      'district': 'Mueang Chiang Mai',
      'province': 'Chiang Mai',
      'location': const GeoPoint(18.7700, 98.9800),
      'radius': 200.0,
      'riskScore': 35.0,
      'riskLevel': 'medium',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 15)),
      'updatedAt': Timestamp.now(),
    },
    {
      'subDistrict': 'Pa Tan',
      'district': 'Mueang Chiang Mai',
      'province': 'Chiang Mai',
      'location': const GeoPoint(18.8200, 98.9900),
      'radius': 150.0,
      'riskScore': 12.0,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2025, 5, 20)),
      'updatedAt': Timestamp.now(),
    },
  ];

  for (final area in areas) {
    await _db.collection('areas').add(area);
  }
  print('✅ Areas seeded');
}

// ─── 3. PLACES ───────────────────────────────────────────────
Future<void> seedPlaces() async {
  final places = [
    {
      'name': 'Maharaj Nakorn Chiang Mai Hospital',
      'description': 'Large public hospital, open 24 hours',
      'location': const GeoPoint(18.7937, 98.9732),
      'phoneNumber': '053-935000',
      'type': 'hospital',
    },
    {
      'name': 'Chiang Mai Ram Hospital',
      'description': 'Private hospital with infectious disease department',
      'location': const GeoPoint(18.8050, 98.9620),
      'phoneNumber': '053-920300',
      'type': 'hospital',
    },
    {
      'name': 'Suthep Health Clinic',
      'description': 'General clinic, open 08:00 - 20:00',
      'location': const GeoPoint(18.7980, 98.9510),
      'phoneNumber': '053-123456',
      'type': 'clinic',
    },
    {
      'name': 'Dr. Pracha Clinic',
      'description': 'Community clinic, accepts universal healthcare card',
      'location': const GeoPoint(18.8100, 98.9750),
      'phoneNumber': '053-654321',
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
