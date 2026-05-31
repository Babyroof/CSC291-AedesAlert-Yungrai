import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/news/domain/entities/article_entity.dart';
import 'package:aedes_alert_yungrai/features/news/domain/repositories/news_repository.dart';
import 'package:aedes_alert_yungrai/features/news/data/repositories/news_repository_impl.dart';

class GetArticlesUseCase {
  const GetArticlesUseCase(this._repository);

  final NewsRepository _repository;

  Future<List<ArticleEntity>> execute() => _repository.getArticles();
}

final getArticlesUseCaseProvider = Provider<GetArticlesUseCase>((ref) {
  return GetArticlesUseCase(ref.watch(newsRepositoryProvider));
});
