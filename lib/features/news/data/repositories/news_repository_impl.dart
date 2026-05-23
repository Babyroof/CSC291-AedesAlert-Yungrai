import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/constants/app_constants.dart';
import 'package:aedes_alert_yungrai/features/news/data/models/article_model.dart';
import 'package:aedes_alert_yungrai/features/news/domain/entities/article_entity.dart';
import 'package:aedes_alert_yungrai/features/news/domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  const NewsRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<ArticleEntity>> getArticles() async {
    final snapshot =
        await _firestore.collection(AppConstants.informationCollection).get();
    return snapshot.docs
        .map((doc) => ArticleModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<ArticleEntity?> getArticleById(String id) async {
    final doc = await _firestore
        .collection(AppConstants.informationCollection)
        .doc(id)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return ArticleModel.fromFirestore(doc).toEntity();
  }
}

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl(FirebaseFirestore.instance);
});
