import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/news/domain/entities/article_entity.dart';

class NewsState {
  const NewsState({required this.articles, required this.selected});

  final AsyncValue<List<ArticleEntity>> articles;
  final AsyncValue<ArticleEntity?> selected;

  factory NewsState.initial() => const NewsState(
    articles: AsyncValue.loading(),
    selected: AsyncValue.data(null),
  );

  NewsState copyWith({
    AsyncValue<List<ArticleEntity>>? articles,
    AsyncValue<ArticleEntity?>? selected,
  }) => NewsState(
    articles: articles ?? this.articles,
    selected: selected ?? this.selected,
  );
}
