import 'package:cloud_firestore/cloud_firestore.dart';

class AreaModel {
  const AreaModel({
    required this.id,
    required this.subDistrict,
    required this.district,
    required this.province,
    required this.location,
    required this.radius,
    required this.riskScore,
    required this.riskLevel,
    required this.reportedAt,
    required this.updatedAt,
  });

  final String id;
  final String subDistrict;
  final String district;
  final String province;
  final GeoPoint location;
  final double radius;
  final double riskScore;
  final String riskLevel;
  final DateTime reportedAt;
  final DateTime updatedAt;

  factory AreaModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return AreaModel(
      id: doc.id,
      subDistrict: data['subDistrict'] as String,
      district: data['district'] as String,
      province: data['province'] as String,
      location: data['location'] as GeoPoint,
      radius: (data['radius'] as num).toDouble(),
      riskScore: ((data['riskScore'] as num?) ?? 0).toDouble(),
      riskLevel: data['riskLevel'] as String,
      reportedAt: (data['reportedAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'subDistrict': subDistrict,
        'district': district,
        'province': province,
        'location': location,
        'radius': radius,
        'riskScore': riskScore,
        'riskLevel': riskLevel,
        'reportedAt': Timestamp.fromDate(reportedAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  AreaModel copyWith({
    String? id,
    String? subDistrict,
    String? district,
    String? province,
    GeoPoint? location,
    double? radius,
    double? riskScore,
    String? riskLevel,
    DateTime? reportedAt,
    DateTime? updatedAt,
  }) {
    return AreaModel(
      id: id ?? this.id,
      subDistrict: subDistrict ?? this.subDistrict,
      district: district ?? this.district,
      province: province ?? this.province,
      location: location ?? this.location,
      radius: radius ?? this.radius,
      riskScore: riskScore ?? this.riskScore,
      riskLevel: riskLevel ?? this.riskLevel,
      reportedAt: reportedAt ?? this.reportedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
