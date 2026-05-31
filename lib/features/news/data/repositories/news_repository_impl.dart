import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/constants/app_constants.dart';
import 'package:aedes_alert_yungrai/features/news/data/models/article_model.dart';
import 'package:aedes_alert_yungrai/features/news/domain/entities/article_entity.dart';
import 'package:aedes_alert_yungrai/features/news/domain/entities/news_article_entity.dart';
import 'package:aedes_alert_yungrai/features/news/domain/repositories/news_repository.dart';
import 'package:aedes_alert_yungrai/features/news/services/news_api_service.dart';

class NewsRepositoryImpl implements NewsRepository {
  const NewsRepositoryImpl(this._firestore, this._newsApiService);

  final FirebaseFirestore _firestore;
  final NewsApiService _newsApiService;

  @override
  Future<List<ArticleEntity>> getArticles() async {
    final snapshot = await _firestore
        .collection(AppConstants.informationCollection)
        .get();
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

  @override
  Future<List<NewsArticleEntity>> getApiNews() async {
    final models = await _newsApiService.fetchDengueNews();
    return models.map((m) => m.toEntity()).toList();
  }
}

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl(
    FirebaseFirestore.instance,
    ref.watch(newsApiServiceProvider),
  );
});
