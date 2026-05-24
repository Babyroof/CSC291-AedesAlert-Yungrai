class NewsArticleEntity {
  const NewsArticleEntity({
    required this.title,
    this.description,
    this.imageUrl,
    required this.publishedAt,
    required this.sourceName,
    required this.articleUrl,
  });

  final String title;
  final String? description;
  final String? imageUrl;
  final String publishedAt;
  final String sourceName;
  final String articleUrl;
}
