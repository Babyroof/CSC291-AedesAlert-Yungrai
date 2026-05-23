import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aedes_alert_yungrai/core/constants/app_colors.dart';
import 'package:aedes_alert_yungrai/core/routes/app_router.dart';
import 'package:aedes_alert_yungrai/features/news/domain/entities/article_entity.dart';
import 'package:aedes_alert_yungrai/features/news/domain/entities/news_article_entity.dart';
import 'package:aedes_alert_yungrai/features/news/presentation/controllers/news_controller.dart';
import 'package:aedes_alert_yungrai/features/news/presentation/controllers/news_state.dart';

class NewsListScreen extends ConsumerStatefulWidget {
  const NewsListScreen({super.key});

  @override
  ConsumerState<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends ConsumerState<NewsListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(newsControllerProvider.notifier)
        ..loadNews()
        ..loadArticles();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Color(0xFF0D1117),
          ),
          onPressed: () => context.go(routeHome),
        ),
        title: const Text(
          'News & Info',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF0D1117),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'News'),
            Tab(text: 'Information'),
          ],
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          labelColor: AppColors.primary,
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewsTab(context, state),
          _buildInfoTab(context, state),
        ],
      ),
    );
  }

  Widget _buildNewsTab(BuildContext context, NewsState state) {
    return state.newsArticles.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Failed to load news',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  ref.read(newsControllerProvider.notifier).loadNews(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (articles) {
        if (articles.isEmpty) {
          return const Center(
            child: Text(
              'No news available',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          itemCount: articles.length,
          itemBuilder: (_, i) => _NewsArticleItem(
            article: articles[i],
            onTap: () => context.push(routeNewsArticle, extra: articles[i]),
          ),
        );
      },
    );
  }

  Widget _buildInfoTab(BuildContext context, NewsState state) {
    return state.articles.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Failed to load information',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  ref.read(newsControllerProvider.notifier).loadArticles(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (articles) => ListView(
        children: [
          const _InfoCenterBanner(),
          ...List.generate(
            articles.length,
            (i) => _InfoArticleItem(
              article: articles[i],
              index: i,
              onTap: () => context.push(
                '$routeNews/${articles[i].id}',
                extra: articles[i],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

String _webProxiedUrl(String url) {
  if (!kIsWeb) return url;
  return 'https://wsrv.nl/?url=${Uri.encodeComponent(url)}';
}

// ─── News tab ────────────────────────────────────────────────────────────────

class _NewsArticleItem extends StatelessWidget {
  const _NewsArticleItem({required this.article, required this.onTap});

  final NewsArticleEntity article;
  final VoidCallback onTap;

  String get _timeAgo {
    try {
      final date = DateTime.parse(article.publishedAt).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 0) {
        return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
      }
      if (diff.inHours > 0) return '${diff.inHours} hr ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes} min ago';
      return 'Just now';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFF0D1117),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$_timeAgo · ${article.sourceName}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                if (article.imageUrl != null) ...[
                  const SizedBox(width: 12),
                  _NewsThumb(url: article.imageUrl!),
                ],
              ],
            ),
          ),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

class _NewsThumb extends StatefulWidget {
  const _NewsThumb({required this.url});
  final String url;

  @override
  State<_NewsThumb> createState() => _NewsThumbState();
}

class _NewsThumbState extends State<_NewsThumb> {
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    if (_failed) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        _webProxiedUrl(widget.url),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _failed = true);
          });
          return const SizedBox(width: 80, height: 80);
        },
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            width: 80,
            height: 80,
            color: const Color(0xFFF3F4F6),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      ),
    );
  }
}

// ─── Information tab ─────────────────────────────────────────────────────────

class _InfoCenterBanner extends StatelessWidget {
  const _InfoCenterBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      color: const Color(0xFF1B2B6B),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -16,
            child: Icon(
              Icons.coronavirus_outlined,
              size: 130,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Information Center',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Everything you need to know about\npreventing and managing Aedes-borne illnesses.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: Color(0xCCFFFFFF),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const _infoIconConfigs = [
  (
    icon: Icons.warning_amber_rounded,
    bg: Color(0xFFEDE7F6),
    color: Color(0xFF7C3AED),
  ),
  (icon: Icons.bug_report, bg: Color(0xFFFFEBEE), color: Color(0xFFEF4444)),
  (icon: Icons.water_drop, bg: Color(0xFFE0F2FE), color: Color(0xFF0284C7)),
  (
    icon: Icons.health_and_safety,
    bg: Color(0xFFDCFCE7),
    color: Color(0xFF16A34A),
  ),
];

class _InfoArticleItem extends StatelessWidget {
  const _InfoArticleItem({
    required this.article,
    required this.index,
    required this.onTap,
  });

  final ArticleEntity article;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cfg = _infoIconConfigs[index % _infoIconConfigs.length];

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cfg.bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(cfg.icon, color: cfg.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF0D1117),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Source: ${article.source}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9CA3AF),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}
