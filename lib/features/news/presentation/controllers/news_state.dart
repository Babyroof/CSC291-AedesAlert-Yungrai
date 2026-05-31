import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/news/domain/entities/article_entity.dart';
import 'package:aedes_alert_yungrai/features/news/domain/entities/news_article_entity.dart';

class NewsState {
  const NewsState({
    required this.articles,
    required this.newsArticles,
    required this.selected,
  });

  final AsyncValue<List<ArticleEntity>> articles;
  final AsyncValue<List<NewsArticleEntity>> newsArticles;
  final AsyncValue<ArticleEntity?> selected;

  factory NewsState.initial() => const NewsState(
    articles: AsyncValue.loading(),
    newsArticles: AsyncValue.loading(),
    selected: AsyncValue.data(null),
  );

  NewsState copyWith({
    AsyncValue<List<ArticleEntity>>? articles,
    AsyncValue<List<NewsArticleEntity>>? newsArticles,
    AsyncValue<ArticleEntity?>? selected,
  }) => NewsState(
    articles: articles ?? this.articles,
    newsArticles: newsArticles ?? this.newsArticles,
    selected: selected ?? this.selected,
  );
}
