import 'package:aedes_alert_yungrai/features/news/domain/entities/article_entity.dart';
import 'package:aedes_alert_yungrai/features/news/domain/entities/news_article_entity.dart';

abstract class NewsRepository {
  Future<List<ArticleEntity>> getArticles();
  Future<ArticleEntity?> getArticleById(String id);
  Future<List<NewsArticleEntity>> getApiNews();
}
