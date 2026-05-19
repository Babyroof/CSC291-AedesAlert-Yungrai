class RiskCountModel {
  const RiskCountModel({
    required this.criticalCount,
    required this.highCount,
    required this.mediumCount,
    required this.lowCount,
  });

  final int criticalCount;
  final int highCount;
  final int mediumCount;
  final int lowCount;

  int get totalCount => criticalCount + highCount + mediumCount + lowCount;
}
