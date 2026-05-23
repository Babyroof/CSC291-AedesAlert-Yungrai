import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/news/domain/entities/article_entity.dart';
import 'package:aedes_alert_yungrai/features/news/domain/repositories/news_repository.dart';
import 'package:aedes_alert_yungrai/features/news/data/repositories/news_repository_impl.dart';

class GetArticleUseCase {
  const GetArticleUseCase(this._repository);

  final NewsRepository _repository;

  Future<ArticleEntity?> execute(String id) => _repository.getArticleById(id);
}

final getArticleUseCaseProvider = Provider<GetArticleUseCase>((ref) {
  return GetArticleUseCase(ref.watch(newsRepositoryProvider));
});
