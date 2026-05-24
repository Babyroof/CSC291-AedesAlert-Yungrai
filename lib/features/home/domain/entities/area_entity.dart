class AreaEntity {
  const AreaEntity({
    required this.id,
    required this.subDistrict,
    required this.district,
    required this.province,
    required this.latitude,
    required this.longitude,
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
  final double latitude;
  final double longitude;
  final double radius;
  final double riskScore;
  final String riskLevel;
  final DateTime reportedAt;
  final DateTime updatedAt;
}
