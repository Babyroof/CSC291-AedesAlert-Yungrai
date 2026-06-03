import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/constants/app_constants.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/entities/ranking_area_entity.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/repositories/ranking_repository.dart';

class RankingRepositoryImpl implements RankingRepository {
  const RankingRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  /// Converts a list of Firestore document snapshots to [RankingAreaEntity]
  /// objects, keeping only the highest-scoring document per district.
  List<RankingAreaEntity> _entitiesToRanked(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    // De-duplicate: keep the doc with the highest riskScore per district.
    final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> byDistrict =
        {};
    for (final doc in docs) {
      final data = doc.data();
      final district = data['district'] as String? ?? '';
      final score = ((data['riskScore'] as num?) ?? 0).toDouble();
      final existing = byDistrict[district];
      if (existing == null) {
        byDistrict[district] = doc;
      } else {
        final existingScore =
            ((existing.data()['riskScore'] as num?) ?? 0).toDouble();
        if (score > existingScore) {
          byDistrict[district] = doc;
        }
      }
    }

    final entities = byDistrict.values.map((doc) {
      final data = doc.data();
      final district = data['district'] as String? ?? '';
      return RankingAreaEntity(
        id: doc.id,
        subDistrict: data['subDistrict'] as String? ?? district,
        district: district,
        province: data['province'] as String? ?? '',
        riskScore: ((data['riskScore'] as num?) ?? 0).toDouble(),
        riskLevel: data['riskLevel'] as String? ?? 'low',
        updatedAt:
            (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList()
      ..sort((a, b) => b.riskScore.compareTo(a.riskScore));

    return entities;
  }

  @override
  Future<List<RankingAreaEntity>> getRankedAreas({int limit = 20}) async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);

    try {
      // Primary query: composite index on isLatest + reportedAt.
      // This requires a composite Firestore index; falls back if it is not
      // yet deployed (failed-precondition) or any other FirebaseException.
      final snapshot = await _firestore
          .collection(AppConstants.areasCollection)
          .where('isLatest', isEqualTo: true)
          .where(
            'reportedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart),
          )
          .where('reportedAt', isLessThan: Timestamp.fromDate(monthEnd))
          .get();

      return _entitiesToRanked(snapshot.docs);
    } on FirebaseException {
      // Fallback: single-field index on riskScore — always available without
      // a composite index.  De-duplicate by district in memory so the result
      // shape matches the primary path.
      final fallbackSnapshot = await _firestore
          .collection(AppConstants.areasCollection)
          .orderBy('riskScore', descending: true)
          .limit(50)
          .get();

      return _entitiesToRanked(fallbackSnapshot.docs);
    }
  }
  
  @override
  Stream<List<RankingAreaEntity>> watchRankedAreas({int limit = 20}) {
    // TODO: implement watchRankedAreas
    throw UnimplementedError();
  }
}

final rankingRepositoryProvider = Provider<RankingRepository>((ref) {
  return RankingRepositoryImpl(FirebaseFirestore.instance);
});
