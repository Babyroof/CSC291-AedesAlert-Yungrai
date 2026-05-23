import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/news/domain/use_cases/get_articles_use_case.dart';
import 'package:aedes_alert_yungrai/features/news/domain/use_cases/get_article_use_case.dart';
import 'package:aedes_alert_yungrai/features/news/presentation/controllers/news_state.dart';

class NewsController extends StateNotifier<NewsState> {
  NewsController({
    required GetArticlesUseCase getArticles,
    required GetArticleUseCase getArticle,
  })  : _getArticles = getArticles,
        _getArticle = getArticle,
        super(NewsState.initial());

  final GetArticlesUseCase _getArticles;
  final GetArticleUseCase _getArticle;

  Future<void> loadArticles() async {
    state = state.copyWith(articles: const AsyncValue.loading());
    try {
      final articles = await _getArticles.execute();
      state = state.copyWith(articles: AsyncValue.data(articles));
    } catch (e, st) {
      state = state.copyWith(articles: AsyncValue.error(e, st));
    }
  }

  Future<void> loadArticle(String id) async {
    state = state.copyWith(selected: const AsyncValue.loading());
    try {
      final article = await _getArticle.execute(id);
      state = state.copyWith(selected: AsyncValue.data(article));
    } catch (e, st) {
      state = state.copyWith(selected: AsyncValue.error(e, st));
    }
  }

  Future<void> refresh() => loadArticles();
}

final newsControllerProvider =
    StateNotifierProvider<NewsController, NewsState>((ref) {
  return NewsController(
    getArticles: ref.watch(getArticlesUseCaseProvider),
    getArticle: ref.watch(getArticleUseCaseProvider),
  );
});
