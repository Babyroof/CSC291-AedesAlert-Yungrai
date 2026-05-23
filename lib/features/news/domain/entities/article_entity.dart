class ArticleEntity {
  const ArticleEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.imageHeader,
    required this.source,
  });

  final String id;
  final String title;
  final String content;
  final String imageHeader;
  final String source;
}
