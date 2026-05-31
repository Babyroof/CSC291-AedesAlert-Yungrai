import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/news/domain/entities/news_article_entity.dart';
import 'package:aedes_alert_yungrai/features/news/domain/repositories/news_repository.dart';
import 'package:aedes_alert_yungrai/features/news/data/repositories/news_repository_impl.dart';

class GetApiNewsUseCase {
  const GetApiNewsUseCase(this._repository);

  final NewsRepository _repository;

  Future<List<NewsArticleEntity>> execute() => _repository.getApiNews();
}

final getApiNewsUseCaseProvider = Provider<GetApiNewsUseCase>((ref) {
  return GetApiNewsUseCase(ref.watch(newsRepositoryProvider));
});
