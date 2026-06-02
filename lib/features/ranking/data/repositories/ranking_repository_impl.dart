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
        .where('isLatest', isEqualTo: true)
        .get();

    final entities = snapshot.docs.map((doc) {
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
    }).toList()..sort((a, b) => b.riskScore.compareTo(a.riskScore));
    return entities;
  }
}

final rankingRepositoryProvider = Provider<RankingRepository>((ref) {
  return RankingRepositoryImpl(FirebaseFirestore.instance);
});
