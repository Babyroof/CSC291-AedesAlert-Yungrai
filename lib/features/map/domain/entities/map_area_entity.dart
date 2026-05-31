class MapAreaEntity {
  const MapAreaEntity({
    required this.id,
    required this.subDistrict,
    required this.district,
    required this.province,
    required this.lat,
    required this.lng,
    required this.radius,
    required this.riskScore,
    required this.riskLevel,
  });

  final String id;
  final String subDistrict;
  final String district;
  final String province;
  final double lat;
  final double lng;
  final double radius;
  final double riskScore;
  final String riskLevel;
}
