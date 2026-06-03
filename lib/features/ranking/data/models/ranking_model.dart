import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/entities/ranking_area_entity.dart';

class RankingModel {
  const RankingModel({
    required this.areaId,
    required this.subDistrict,
    required this.district,
    required this.province,
    required this.riskScore,
    required this.riskLevel,
    required this.rank,
    required this.updatedAt,
  });

  final String areaId;
  final String subDistrict;
  final String district;
  final String province;
  final double riskScore;
  final String riskLevel;
  final int rank;
  final DateTime updatedAt;

  factory RankingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return RankingModel(
      areaId: data['areaId'] as String? ?? doc.id,
      subDistrict: data['subDistrict'] as String? ?? '',
      district: data['district'] as String? ?? '',
      province: data['province'] as String? ?? '',
      riskScore: (data['riskScore'] as num?)?.toDouble() ?? 0.0,
      riskLevel: data['riskLevel'] as String? ?? 'low',
      rank: (data['rank'] as num?)?.toInt() ?? 0,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  RankingAreaEntity toEntity() => RankingAreaEntity(
    id: areaId,
    subDistrict: subDistrict,
    district: district,
    province: province,
    riskScore: riskScore,
    riskLevel: riskLevel,
    rank: rank,
    updatedAt: updatedAt,
  );
}
