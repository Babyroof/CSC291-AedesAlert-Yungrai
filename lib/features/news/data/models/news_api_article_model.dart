import 'package:aedes_alert_yungrai/features/news/domain/entities/news_article_entity.dart';

class NewsApiArticleModel {
  const NewsApiArticleModel({
    required this.title,
    this.description,
    this.urlToImage,
    required this.publishedAt,
    required this.sourceName,
    required this.url,
  });

  final String title;
  final String? description;
  final String? urlToImage;
  final String publishedAt;
  final String sourceName;
  final String url;

  factory NewsApiArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsApiArticleModel(
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      urlToImage: json['urlToImage'] as String?,
      publishedAt: json['publishedAt'] as String? ?? '',
      sourceName:
          (json['source'] as Map<String, dynamic>?)?['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  NewsArticleEntity toEntity() => NewsArticleEntity(
    title: title,
    description: description,
    imageUrl: urlToImage,
    publishedAt: publishedAt,
    sourceName: sourceName,
    articleUrl: url,
  );
}
