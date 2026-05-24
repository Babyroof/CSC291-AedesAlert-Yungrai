import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aedes_alert_yungrai/core/constants/app_colors.dart';
import 'package:aedes_alert_yungrai/features/news/domain/entities/news_article_entity.dart';

String _webProxiedUrl(String url) {
  if (!kIsWeb) return url;
  return 'https://wsrv.nl/?url=${Uri.encodeComponent(url)}';
}

class NewsArticleDetailScreen extends StatelessWidget {
  const NewsArticleDetailScreen({super.key, required this.article});

  final NewsArticleEntity article;

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

  int get _readMinutes {
    final words = (article.description ?? '').split(' ').length;
    return (words / 200).ceil().clamp(1, 99);
  }

  Future<void> _openArticle(BuildContext context) async {
    final uri = Uri.tryParse(article.articleUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open article link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'News',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF0D1117),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null)
              _HeaderImage(imageUrl: article.imageUrl!),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _SourceChip(name: article.sourceName),
                      const SizedBox(width: 10),
                      Text(
                        _timeAgo,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '·',
                        style: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_readMinutes min read',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 20),
                  if (article.description != null &&
                      article.description!.isNotEmpty) ...[
                    Text(
                      article.description!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: Color(0xFF374151),
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                  _ReadFullButton(onTap: () => _openArticle(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderImage extends StatelessWidget {
  const _HeaderImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(0)),
      child: Image.network(
        _webProxiedUrl(imageUrl),
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Container(
          width: double.infinity,
          height: 240,
          color: const Color(0xFFF3F4F6),
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFFD1D5DB),
            size: 48,
          ),
        ),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: double.infinity,
            height: 240,
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

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ReadFullButton extends StatelessWidget {
  const _ReadFullButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.open_in_new, size: 18),
        label: const Text(
          'Read full article',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
