import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/constants/api_keys.dart';
import 'package:aedes_alert_yungrai/features/news/data/models/news_api_article_model.dart';

class NewsApiService {
  NewsApiService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  static const _baseUrl = 'https://newsapi.org/v2/everything';

  Future<List<NewsApiArticleModel>> fetchDengueNews() async {
    debugPrint('[NewsApiService] fetchDengueNews: fetching...');

    // Web: English sources only (CORS restriction prevents Thai RSS)
    // Mobile: add Thai RSS directly — no CORS on native HTTP client
    final futures = <Future<List<NewsApiArticleModel>>>[
      _fetchNewsApi(
        q: '(dengue OR "aedes mosquito" OR "dengue fever") AND Thailand',
        pageSize: 20,
      ),
      _fetchBangkokPostRss(),
      if (!kIsWeb) _fetchThaiRssMobile(),
    ];

    final results = await Future.wait(futures);

    final seenUrls = <String>{};
    final seenTitles = <String>{};
    final merged = results.expand((r) => r).where((a) {
      final normalizedTitle = a.title.toLowerCase().trim();
      return seenUrls.add(a.url) && seenTitles.add(normalizedTitle);
    }).toList()..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    debugPrint(
      '[NewsApiService] fetchDengueNews: loaded ${merged.length} articles',
    );
    return merged;
  }

  Future<List<NewsApiArticleModel>> _fetchNewsApi({
    required String q,
    required int pageSize,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _baseUrl,
        queryParameters: {
          'q': q,
          'language': 'en',
          'sortBy': 'publishedAt',
          'pageSize': pageSize,
          'apiKey': ApiKeys.newsApi,
        },
      );
      final raw = response.data?['articles'] as List<dynamic>? ?? [];
      return raw
          .map((e) => NewsApiArticleModel.fromJson(e as Map<String, dynamic>))
          .where((a) => a.title != '[Removed]' && a.title.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('[NewsApiService] _fetchNewsApi error: $e');
      return [];
    }
  }

  Future<List<NewsApiArticleModel>> _fetchBangkokPostRss() async {
    const keywords = ['dengue', 'mosquito', 'aedes', 'ยุงลาย', 'ไข้เลือดออก'];
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.allorigins.win/get',
        queryParameters: {
          'url': 'https://www.bangkokpost.com/rss/data/topstories.xml',
        },
      );
      final xml = response.data?['contents'] as String? ?? '';
      if (xml.isEmpty) return [];

      final articles = _parseRssXml(xml, 'Bangkok Post');
      debugPrint('[BangkokPost] total parsed: ${articles.length}');
      return articles.where((a) {
        final combined = '${a.title} ${a.description ?? ''}'.toLowerCase();
        return keywords.any(combined.contains);
      }).toList();
    } catch (e) {
      debugPrint('[BangkokPost] error: $e');
      return [];
    }
  }

  // Mobile only — Thai RSS works without CORS proxy on native HTTP clients
  Future<List<NewsApiArticleModel>> _fetchThaiRssMobile() async {
    const sources = <(String, String)>[
      ('https://www.thairath.co.th/rss/news.xml', 'ไทยรัฐ'),
      ('https://www.sanook.com/health/feed/', 'Sanook สุขภาพ'),
      ('https://mgronline.com/qol/rss', 'Manager สุขภาพ'),
    ];
    const keywords = [
      'ยุงลาย',
      'ไข้เลือดออก',
      'เดงกี',
      'dengue',
      'mosquito',
      'aedes',
    ];

    final all = <NewsApiArticleModel>[];
    for (final (url, sourceName) in sources) {
      try {
        final response = await _dio.get<String>(
          url,
          options: Options(responseType: ResponseType.plain),
        );
        final articles = _parseRssXml(response.data ?? '', sourceName);
        final filtered = articles.where((a) {
          final combined = '${a.title} ${a.description ?? ''}'.toLowerCase();
          return keywords.any(combined.contains);
        });
        all.addAll(filtered);
        debugPrint('[ThaiRSS] $sourceName: ${filtered.length} dengue articles');
      } catch (e) {
        debugPrint('[ThaiRSS] error ($sourceName): $e');
      }
    }
    return all;
  }

  List<NewsApiArticleModel> _parseRssXml(String xml, String sourceName) {
    final items = <NewsApiArticleModel>[];
    final itemRegex = RegExp(r'<item[^>]*>(.*?)</item>', dotAll: true);
    for (final match in itemRegex.allMatches(xml)) {
      final block = match.group(1) ?? '';
      final title = _rssText(block, 'title');
      final link = _rssText(block, 'link');
      if (title.isEmpty || link.isEmpty) continue;

      String? imageUrl;
      final enclosure = RegExp(
        r'<enclosure[^>]+url="([^"]+)"',
      ).firstMatch(block);
      imageUrl = enclosure?.group(1);
      if (imageUrl == null) {
        final media = RegExp(
          r'<media:content[^>]+url="([^"]+)"',
        ).firstMatch(block);
        imageUrl = media?.group(1);
      }

      items.add(
        NewsApiArticleModel(
          title: title,
          description: _stripHtml(_rssText(block, 'description')),
          urlToImage: imageUrl,
          publishedAt: _rssText(block, 'pubDate'),
          sourceName: sourceName,
          url: link,
        ),
      );
    }
    return items;
  }

  static String _rssText(String block, String tag) {
    final cdata = RegExp(
      '<$tag>\\s*<!\\[CDATA\\[(.*?)\\]\\]>\\s*</$tag>',
      dotAll: true,
    ).firstMatch(block);
    if (cdata != null) return cdata.group(1)?.trim() ?? '';
    final plain = RegExp(
      '<$tag>\\s*(.*?)\\s*</$tag>',
      dotAll: true,
    ).firstMatch(block);
    return plain?.group(1)?.trim() ?? '';
  }

  static String _stripHtml(String html) =>
      html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
}

final newsApiServiceProvider = Provider<NewsApiService>(
  (ref) => NewsApiService(),
);
