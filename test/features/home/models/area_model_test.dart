import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  Map<String, dynamic> baseData() => {
        'subDistrict': 'Bang Khen',
        'district': 'Mueang',
        'province': 'Nonthaburi',
        'location': const GeoPoint(13.8621, 100.5144),
        'radius': 500.0,
        'riskScore': 75.5,
        'riskLevel': 'high',
        'reportedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2024, 6, 1)),
      };

  test('fromFirestore parses all fields correctly', () async {
    final ref = await fakeFirestore.collection('areas').add(baseData());
    final doc = await ref.get();
    final model = AreaModel.fromFirestore(doc);

    expect(model.id, ref.id);
    expect(model.subDistrict, 'Bang Khen');
    expect(model.district, 'Mueang');
    expect(model.province, 'Nonthaburi');
    expect(model.riskScore, 75.5);
    expect(model.riskLevel, 'high');
    expect(model.radius, 500.0);
  });

  test('null riskScore defaults to 0.0 without crashing', () async {
    final data = baseData()..['riskScore'] = null;
    final ref = await fakeFirestore.collection('areas').add(data);
    final doc = await ref.get();
    final model = AreaModel.fromFirestore(doc);

    expect(model.riskScore, 0.0);
  });

  test('copyWith replaces specified fields', () async {
    final ref = await fakeFirestore.collection('areas').add(baseData());
    final doc = await ref.get();
    final model = AreaModel.fromFirestore(doc);
    final updated = model.copyWith(riskLevel: 'critical', riskScore: 95.0);

    expect(updated.riskLevel, 'critical');
    expect(updated.riskScore, 95.0);
    expect(updated.subDistrict, model.subDistrict);
  });

  test('toFirestore round-trips riskScore', () async {
    final ref = await fakeFirestore.collection('areas').add(baseData());
    final doc = await ref.get();
    final model = AreaModel.fromFirestore(doc);
    final map = model.toFirestore();

    expect(map['riskScore'], 75.5);
    expect(map['riskLevel'], 'high');
  });
}
