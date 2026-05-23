import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aedes_alert_yungrai/features/news/domain/entities/article_entity.dart';

class ArticleModel {
  const ArticleModel({
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

  factory ArticleModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ArticleModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      imageHeader: data['imageHeader'] as String? ?? '',
      source: data['source'] as String? ?? '',
    );
  }

  ArticleEntity toEntity() => ArticleEntity(
    id: id,
    title: title,
    content: content,
    imageHeader: imageHeader,
    source: source,
  );
}
