class RankingAreaEntity {
  const RankingAreaEntity({
    required this.id,
    required this.subDistrict,
    required this.district,
    required this.province,
    required this.riskScore,
    required this.riskLevel,
    required this.updatedAt,
    this.rank = 0,
  });

  final String id;
  final String subDistrict;
  final String district;
  final String province;
  final double riskScore;
  final String riskLevel;
  final DateTime updatedAt;
  final int rank;
}
