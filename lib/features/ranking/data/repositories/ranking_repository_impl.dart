import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/constants/app_constants.dart';
import 'package:aedes_alert_yungrai/features/ranking/data/models/ranking_model.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/entities/ranking_area_entity.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/repositories/ranking_repository.dart';

class RankingRepositoryImpl implements RankingRepository {
  const RankingRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<RankingAreaEntity>> getRankedAreas({int limit = 20}) async {
    final snapshot = await _firestore
        .collection(AppConstants.areasCollection)
        .orderBy('riskScore', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return RankingAreaEntity(
        id: doc.id,
        subDistrict: data['subDistrict'] as String? ?? '',
        district: data['district'] as String? ?? '',
        province: data['province'] as String? ?? '',
        riskScore: ((data['riskScore'] as num?) ?? 0).toDouble(),
        riskLevel: data['riskLevel'] as String? ?? 'low',
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  @override
  Stream<List<RankingAreaEntity>> watchRankedAreas({int limit = 20}) {
    return _firestore
        .collection(AppConstants.rankingCollection)
        .orderBy('rank')
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RankingModel.fromFirestore(doc).toEntity())
            .toList());
  }
}

final rankingRepositoryProvider = Provider<RankingRepository>((ref) {
  return RankingRepositoryImpl(FirebaseFirestore.instance);
});
