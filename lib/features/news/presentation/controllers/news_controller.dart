import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/news/domain/use_cases/get_articles_use_case.dart';
import 'package:aedes_alert_yungrai/features/news/domain/use_cases/get_article_use_case.dart';
import 'package:aedes_alert_yungrai/features/news/domain/use_cases/get_api_news_use_case.dart';
import 'package:aedes_alert_yungrai/features/news/presentation/controllers/news_state.dart';

class NewsController extends StateNotifier<NewsState> {
  NewsController({
    required GetArticlesUseCase getArticles,
    required GetArticleUseCase getArticle,
    required GetApiNewsUseCase getApiNews,
  }) : _getArticles = getArticles,
       _getArticle = getArticle,
       _getApiNews = getApiNews,
       super(NewsState.initial());

  final GetArticlesUseCase _getArticles;
  final GetArticleUseCase _getArticle;
  final GetApiNewsUseCase _getApiNews;

  DateTime? _newsCachedAt;
  DateTime? _articlesCachedAt;
  static const _cacheTtl = Duration(minutes: 15);

  Future<void> loadArticles() async {
    final cached = state.articles.valueOrNull;
    final hasCached = cached != null && cached.isNotEmpty;
    final isFresh =
        _articlesCachedAt != null &&
        DateTime.now().difference(_articlesCachedAt!) < _cacheTtl;

    if (hasCached && isFresh) return;

    if (!hasCached) {
      state = state.copyWith(articles: const AsyncValue.loading());
    }

    try {
      final articles = await _getArticles.execute();
      _articlesCachedAt = DateTime.now();
      state = state.copyWith(articles: AsyncValue.data(articles));
    } catch (e, st) {
      if (!hasCached) {
        state = state.copyWith(articles: AsyncValue.error(e, st));
      }
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

  Future<void> loadNews() async {
    final cached = state.newsArticles.valueOrNull;
    final hasCached = cached != null && cached.isNotEmpty;
    final isFresh =
        _newsCachedAt != null &&
        DateTime.now().difference(_newsCachedAt!) < _cacheTtl;

    // Fresh cache — skip fetch entirely
    if (hasCached && isFresh) return;

    // No cache — show loading spinner
    if (!hasCached) {
      state = state.copyWith(newsArticles: const AsyncValue.loading());
    }
    // Stale cache — keep showing old data while refreshing silently

    try {
      final articles = await _getApiNews.execute();
      _newsCachedAt = DateTime.now();
      state = state.copyWith(newsArticles: AsyncValue.data(articles));
    } catch (e, st) {
      if (!hasCached) {
        state = state.copyWith(newsArticles: AsyncValue.error(e, st));
      }
    }
  }

  Future<void> refresh() async {
    _newsCachedAt = null;
    _articlesCachedAt = null;
    await Future.wait([loadArticles(), loadNews()]);
  }
}

final newsControllerProvider = StateNotifierProvider<NewsController, NewsState>(
  (ref) {
    return NewsController(
      getArticles: ref.watch(getArticlesUseCaseProvider),
      getArticle: ref.watch(getArticleUseCaseProvider),
      getApiNews: ref.watch(getApiNewsUseCaseProvider),
    );
  },
);
