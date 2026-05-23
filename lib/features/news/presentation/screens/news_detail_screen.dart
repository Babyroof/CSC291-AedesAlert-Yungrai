import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aedes_alert_yungrai/core/constants/app_colors.dart';
import 'package:aedes_alert_yungrai/features/news/domain/entities/article_entity.dart';
import 'package:aedes_alert_yungrai/features/news/presentation/controllers/news_controller.dart';

class NewsDetailScreen extends ConsumerStatefulWidget {
  const NewsDetailScreen({super.key, required this.id, this.article});

  final String id;
  final ArticleEntity? article;

  @override
  ConsumerState<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends ConsumerState<NewsDetailScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.article == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(newsControllerProvider.notifier).loadArticle(widget.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final article =
        widget.article ??
        ref.watch(newsControllerProvider).selected.valueOrNull;

    if (widget.article == null) {
      final selectedAsync = ref.watch(newsControllerProvider).selected;
      return selectedAsync.when(
        loading: () => Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(context, null),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(context, null),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                const Text(
                  'Failed to load article',
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref
                      .read(newsControllerProvider.notifier)
                      .loadArticle(widget.id),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (a) => _buildContent(context, a),
      );
    }

    return _buildContent(context, article);
  }

  AppBar _buildAppBar(BuildContext context, ArticleEntity? article) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          color: Color(0xFF0D1117),
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        article != null ? 'Information' : '',
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Color(0xFF0D1117),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ArticleEntity? article) {
    if (article == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context, null),
        body: const Center(
          child: Text(
            'Article not found',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: Color(0xFF0D1117),
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: article.imageHeader.isNotEmpty
                  ? Image.network(
                      article.imageHeader,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          _imagePlaceholder(),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return _imagePlaceholder(loading: true);
                      },
                    )
                  : _imagePlaceholder(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Source: ${article.source}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Color(0xFF0D1117),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 20),
                  Text(
                    article.content,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: Color(0xFF374151),
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder({bool loading = false}) {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: Center(
        child: loading
            ? const CircularProgressIndicator(strokeWidth: 2)
            : const Icon(
                Icons.article_outlined,
                size: 64,
                color: Color(0xFFD1D5DB),
              ),
      ),
    );
  }
}
