import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/yungrai_app_bar.dart';
import '../../../../features/dashboard/domain/entities/dashboard_summary_model.dart';
import '../../../../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../../features/dashboard/presentation/controllers/dashboard_init_provider.dart';

// Tracks the currently selected month key ("YYYY-MM").
// Initialized to the current month so the button label is correct on the
// very first frame, before Firestore data arrives.
final _selectedMonthKeyProvider = StateProvider<String?>((ref) {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
});

// ─── View Model ───────────────────────────────────────────────────────────────
// All hardcoded values live here.
// To connect to real data: replace `_DashboardViewData.placeholder()` with
// `_DashboardViewData.fromSummary(summary)` once the controller loads.

class _DashboardViewData {
  const _DashboardViewData({
    required this.highRiskCount,
    required this.criticalCount,
    required this.mediumRiskCount,
    required this.avgRiskScore,
    required this.monthlyScores,
    required this.monthLabels,
    required this.distribution,
    required this.topAreas,
  });

  final int highRiskCount;
  final int criticalCount;
  final int mediumRiskCount;
  final double? avgRiskScore;
  final List<double> monthlyScores;
  final List<String> monthLabels;
  final List<_DistributionItem> distribution;
  final List<_RankArea> topAreas;

  static _DashboardViewData placeholder() => _DashboardViewData(
    highRiskCount: 12,
    criticalCount: 4,
    mediumRiskCount: 28,
    avgRiskScore: null,
    monthlyScores: const [8.0, 10.0, 18.4],
    monthLabels: const ['Apr', 'May', 'Jun'],
    distribution: const [
      _DistributionItem('HIGH', AppColors.riskHigh, '12 Areas', 12, 130),
      _DistributionItem('MEDIUM', AppColors.riskMedium, '28 Areas', 28, 130),
    ],
    topAreas: const [
      _RankArea(1, 'Nong Chok', 94.2, 'critical'),
      _RankArea(2, 'Min Buri', 88.5, 'critical'),
      _RankArea(3, 'Lat Krabang', 74.1, 'high'),
      _RankArea(4, 'Bang Khen', 68.0, 'high'),
      _RankArea(5, 'Sai Mai', 49.8, 'medium'),
    ],
  );

  // TODO: call this once dashboardControllerProvider loads real data
  factory _DashboardViewData.fromSummary(DashboardSummaryModel summary) {
    final trend = summary.monthlyTrend;
    final total = summary.riskCounts.totalCount.clamp(1, 9999);
    return _DashboardViewData(
      highRiskCount: summary.riskCounts.highCount,
      criticalCount: summary.riskCounts.criticalCount,
      mediumRiskCount: summary.riskCounts.mediumCount,
      avgRiskScore: summary.averageRiskScore != null
          ? double.parse(summary.averageRiskScore!.toStringAsFixed(1))
          : null,
      monthlyScores: trend.map((e) => e.avgRiskScore).toList(),
      monthLabels: trend.map((e) => e.monthLabel).toList(),
      distribution: [
        _DistributionItem(
          'CRITICAL',
          AppColors.riskCritical,
          '${summary.riskCounts.criticalCount} Areas',
          summary.riskCounts.criticalCount,
          total,
        ),
        _DistributionItem(
          'HIGH',
          AppColors.riskHigh,
          '${summary.riskCounts.highCount} Areas',
          summary.riskCounts.highCount,
          total,
        ),
        _DistributionItem(
          'MEDIUM',
          AppColors.riskMedium,
          '${summary.riskCounts.mediumCount} Areas',
          summary.riskCounts.mediumCount,
          total,
        ),
        _DistributionItem(
          'LOW',
          AppColors.riskLow,
          '${summary.riskCounts.lowCount} Areas',
          summary.riskCounts.lowCount,
          total,
        ),
      ],
      topAreas: summary.topFiveAreas.asMap().entries.map((e) {
        final area = e.value;
        return _RankArea(
          e.key + 1,
          area.subDistrict,
          area.riskScore,
          area.riskLevel,
        );
      }).toList(),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Returns the month key for [monthsBack] months before [base].
/// [base] must be in "YYYY-MM" format.
String _shiftMonthKey(String base, int monthsBack) {
  final parts = base.split('-');
  int year = int.parse(parts[0]);
  int month = int.parse(parts[1]);
  month -= monthsBack;
  while (month <= 0) {
    month += 12;
    year -= 1;
  }
  return '$year-${month.toString().padLeft(2, '0')}';
}

/// Returns the 3-letter month abbreviation from a "YYYY-MM" key.
String _monthAbbr(String monthKey) {
  final parts = monthKey.split('-');
  final month = int.parse(parts[1]);
  const abbrs = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return abbrs[month];
}

/// Returns a user-friendly "Month YYYY" label from a "YYYY-MM" key.
String _monthYearLabel(String monthKey) {
  final parts = monthKey.split('-');
  final year = int.parse(parts[0]);
  final month = int.parse(parts[1]);
  const names = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${names[month]} $year';
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    ref.watch(dashboardInitProvider);

    // Reads live state from controller; falls back to placeholder until
    // loadDashboard() is called and data arrives.
    final dashState = ref.watch(dashboardControllerProvider);
    final isLoading = dashState.summary.isLoading;
    final summary = dashState.summary.valueOrNull;
    final data = summary != null
        ? _DashboardViewData.fromSummary(summary)
        : null;
    final displayData = data ?? _DashboardViewData.placeholder();

    // The effective selected month key:
    //   - what's in the provider if the user has picked one, or
    //   - the most recent real data month from the summary.
    final localKey = ref.watch(_selectedMonthKeyProvider);
    final mostRecentKey = summary?.selectedMonthKey;
    final selectedKey = localKey ?? mostRecentKey;

    // When data has loaded but the trend is empty it means no district is
    // known (location denied / unavailable). The chart and avg card should
    // show nothing in that case.
    final trendIsEmpty = summary != null && (summary.monthlyTrend.isEmpty);

    // Build the 3-bar data for the chart from the selected month key.
    List<double> chartScores;
    List<String> chartLabels;
    int chartHighlightIndex;

    if (trendIsEmpty) {
      // No district — show empty chart with the "enable location" prompt.
      chartScores = [];
      chartLabels = [];
      chartHighlightIndex = 0;
    } else if (selectedKey != null) {
      final k0 = _shiftMonthKey(selectedKey, 2); // 2 months before selected
      final k1 = _shiftMonthKey(selectedKey, 1); // 1 month before selected
      final k2 = selectedKey; // the selected month

      final trend = summary?.monthlyTrend ?? [];
      final scoreMap = {for (final m in trend) m.monthKey: m.avgRiskScore};

      chartScores = [
        scoreMap[k0] ?? 0.0,
        scoreMap[k1] ?? 0.0,
        scoreMap[k2] ?? 0.0,
      ];
      chartLabels = [_monthAbbr(k0), _monthAbbr(k1), _monthAbbr(k2)];
      chartHighlightIndex = 2; // rightmost bar = selected month
    } else {
      // Fallback before data loads
      chartScores = displayData.monthlyScores.length >= 3
          ? displayData.monthlyScores.sublist(
              displayData.monthlyScores.length - 3,
            )
          : List<double>.from(displayData.monthlyScores);
      chartLabels = displayData.monthLabels.length >= 3
          ? displayData.monthLabels.sublist(displayData.monthLabels.length - 3)
          : List<String>.from(displayData.monthLabels);
      chartHighlightIndex = chartScores.isEmpty ? 0 : chartScores.length - 1;
    }

    // Avg risk score: use the district-scoped value from the summary.
    // null means no district is known → show "--" in the card.
    final double? avgRiskScore = summary?.averageRiskScore;

    return Scaffold(
      appBar: const YungraiAppBar(),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            const SizedBox(height: 4),
            _MonthSelector(
              selectedMonthKey: selectedKey,
              mostRecentKey: mostRecentKey,
              onPickMonth: (picked) {
                ref.read(_selectedMonthKeyProvider.notifier).state = picked;
                ref
                    .read(dashboardControllerProvider.notifier)
                    .selectMonth(picked);
              },
              onResetToRecent: () {
                if (mostRecentKey != null) {
                  ref.read(_selectedMonthKeyProvider.notifier).state = null;
                  ref
                      .read(dashboardControllerProvider.notifier)
                      .selectMonth(mostRecentKey);
                }
              },
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              _StatCardsGrid(data: displayData, selectedMonthAvg: avgRiskScore),
            const SizedBox(height: 24),
            if (isLoading)
              const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              _RiskScoreChart(
                scores: chartScores,
                months: chartLabels,
                highlightIndex: chartHighlightIndex,
                noDistrict: trendIsEmpty,
              ),
            const SizedBox(height: 24),
            _RiskDistribution(items: displayData.distribution),
            const SizedBox(height: 24),
            _Top5RiskAreas(areas: displayData.topAreas),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Real-time Environmental Monitoring',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ─── Month Selector ───────────────────────────────────────────────────────────
// Shows a chip with the selected month name (resets to most recent when tapped)
// and a calendar icon button that opens a month/year picker.

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.selectedMonthKey,
    required this.mostRecentKey,
    required this.onPickMonth,
    required this.onResetToRecent,
  });

  final String? selectedMonthKey;
  final String? mostRecentKey;
  final void Function(String monthKey) onPickMonth;
  final VoidCallback onResetToRecent;

  @override
  Widget build(BuildContext context) {
    final effectiveKey = selectedMonthKey ?? mostRecentKey;
    final label = effectiveKey != null ? _monthYearLabel(effectiveKey) : '—';
    // The chip is "selected" (filled) when the local key matches mostRecent
    // or when no override is set (i.e. we are showing the most-recent month).
    final isCurrentMonth =
        selectedMonthKey == null || selectedMonthKey == mostRecentKey;

    return Row(
      children: [
        GestureDetector(
          onTap: onResetToRecent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isCurrentMonth ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: isCurrentMonth
                  ? null
                  : Border.all(color: AppColors.border),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isCurrentMonth
                    ? AppColors.textOnPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.calendar_month,
              size: 16,
              color: AppColors.textSecondary,
            ),
            padding: const EdgeInsets.all(7),
            constraints: const BoxConstraints(),
            onPressed: () async {
              // Derive initial year/month from the effective key, or now.
              int initialYear;
              int initialMonth;
              if (effectiveKey != null) {
                final parts = effectiveKey.split('-');
                initialYear = int.parse(parts[0]);
                initialMonth = int.parse(parts[1]);
              } else {
                final now = DateTime.now();
                initialYear = now.year;
                initialMonth = now.month;
              }
              final picked = await showDialog<String>(
                context: context,
                builder: (_) => _MonthYearPickerDialog(
                  initialYear: initialYear,
                  initialMonth: initialMonth,
                ),
              );
              if (picked != null) {
                onPickMonth(picked);
              }
            },
          ),
        ),
      ],
    );
  }
}

// ─── Stat Cards Grid ──────────────────────────────────────────────────────────

class _StatCardsGrid extends StatelessWidget {
  const _StatCardsGrid({required this.data, required this.selectedMonthAvg});
  final _DashboardViewData data;
  final double? selectedMonthAvg;

  static String _fmt(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'HIGH RISK AREAS',
                value: _fmt(data.highRiskCount),
                valueColor: AppColors.riskHigh,
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.riskHigh,
                borderColor: AppColors.riskHigh,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'CRITICAL AREAS',
                value: _fmt(data.criticalCount),
                valueColor: AppColors.riskCritical,
                icon: Icons.cancel_outlined,
                iconColor: AppColors.riskCritical,
                borderColor: AppColors.riskCritical,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'MEDIUM RISK',
                value: _fmt(data.mediumRiskCount),
                valueColor: AppColors.riskMedium,
                icon: Icons.info_outline,
                iconColor: AppColors.riskMedium,
                borderColor: AppColors.riskMedium,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'AVG RISK SCORE',
                value: selectedMonthAvg != null
                    ? selectedMonthAvg!.toStringAsFixed(1)
                    : '--',
                valueColor: AppColors.riskLow,
                icon: Icons.verified_user_outlined,
                iconColor: AppColors.riskLow,
                borderColor: AppColors.riskLow,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
    required this.iconColor,
    required this.borderColor,
  });

  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;
  final Color iconColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                  height: 1,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: iconColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ],
      ),
    );
  }
}

// ─── Risk Score Bar Chart ─────────────────────────────────────────────────────

class _RiskScoreChart extends StatelessWidget {
  const _RiskScoreChart({
    required this.scores,
    required this.months,
    required this.highlightIndex,
    this.noDistrict = false,
  });
  final List<double> scores;
  final List<String> months;
  final int highlightIndex;

  /// When true, location is unavailable — show a prompt instead of bars.
  final bool noDistrict;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Avg Risk Score by\nMonth',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 12),
        if (noDistrict)
          SizedBox(
            height: 160,
            child: Center(
              child: Text(
                'Enable location to see district trend',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          )
        else
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _BarChartPainter(
                scores: scores,
                months: months,
                highlightIndex: highlightIndex,
              ),
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.scores,
    required this.months,
    required this.highlightIndex,
  });

  final List<double> scores;
  final List<String> months;
  final int highlightIndex;

  @override
  void paint(Canvas canvas, Size size) {
    const double bottomPad = 24;
    const double topPad = 28;
    final double chartH = size.height - bottomPad - topPad;
    final double chartW = size.width;
    final int n = months.length;
    if (n == 0) return;
    final double maxVal = scores.isEmpty ? 100.0 : scores.reduce(max) * 1.25;

    final double slotW = chartW / n;
    const double barWidthFraction = 0.52;

    double centerX(int i) => i * slotW + slotW / 2;

    // Horizontal grid lines
    final gridPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1;
    for (int j = 0; j <= 4; j++) {
      final y = topPad + chartH - (j / 4) * chartH;
      canvas.drawLine(Offset(0, y), Offset(chartW, y), gridPaint);
    }

    for (int i = 0; i < n; i++) {
      final isHighlight = i == highlightIndex;
      final bw = slotW * barWidthFraction;
      final effectiveMax = maxVal > 0 ? maxVal : 1.0;
      final bh = (scores[i] / effectiveMax) * chartH;
      final bx = centerX(i) - bw / 2;
      final by = topPad + chartH - bh;

      final color = isHighlight ? AppColors.primary : AppColors.riskLow;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(bx, by, bw, bh),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        Paint()..color = color,
      );

      if (isHighlight) {
        const tooltipW = 46.0;
        const tooltipH = 22.0;
        final tx = centerX(i);
        final tooltipLeft = (tx - tooltipW / 2).clamp(0.0, chartW - tooltipW);
        final tooltipTop = by - tooltipH - 6;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(tooltipLeft, tooltipTop, tooltipW, tooltipH),
            const Radius.circular(6),
          ),
          Paint()..color = AppColors.textPrimary,
        );
        canvas.drawPath(
          Path()
            ..moveTo(tx - 5, tooltipTop + tooltipH)
            ..lineTo(tx + 5, tooltipTop + tooltipH)
            ..lineTo(tx, tooltipTop + tooltipH + 5)
            ..close(),
          Paint()..color = AppColors.textPrimary,
        );

        final tp = TextPainter(
          text: TextSpan(
            text: scores[i].toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(
            tooltipLeft + (tooltipW - tp.width) / 2,
            tooltipTop + (tooltipH - tp.height) / 2,
          ),
        );
      } else {
        // Always show a value label above non-highlighted bars, including 0.0.
        final lp = TextPainter(
          text: TextSpan(
            text: scores[i].toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        lp.paint(canvas, Offset(centerX(i) - lp.width / 2, by - lp.height - 4));
      }
    }

    // Month labels
    for (int i = 0; i < months.length; i++) {
      final lp = TextPainter(
        text: TextSpan(
          text: months[i],
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      lp.paint(
        canvas,
        Offset(centerX(i) - lp.width / 2, size.height - bottomPad + 5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.scores != scores ||
      oldDelegate.months != months ||
      oldDelegate.highlightIndex != highlightIndex;
}

// ─── Risk Distribution ────────────────────────────────────────────────────────

class _RiskDistribution extends StatelessWidget {
  const _RiskDistribution({required this.items});
  final List<_DistributionItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Risk Distribution',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _RiskBar(item: item),
          ),
        ),
      ],
    );
  }
}

class _DistributionItem {
  const _DistributionItem(
    this.label,
    this.color,
    this.countLabel,
    this.count,
    this.max,
  );
  final String label;
  final Color color;
  final String countLabel;
  final int count;
  final int max;
}

class _RiskBar extends StatelessWidget {
  const _RiskBar({required this.item});
  final _DistributionItem item;

  @override
  Widget build(BuildContext context) {
    final fraction = (item.count / item.max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              item.countLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: fraction,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Top 5 Risk Areas ─────────────────────────────────────────────────────────

class _RankArea {
  const _RankArea(this.rank, this.name, this.score, this.level);
  final int rank;
  final String name;
  final double score;
  final String level;
}

class _Top5RiskAreas extends StatelessWidget {
  const _Top5RiskAreas({required this.areas});
  final List<_RankArea> areas;

  static Color _color(String level) => switch (level) {
    'critical' => AppColors.riskCritical,
    'high' => AppColors.riskHigh,
    'medium' => AppColors.riskMedium,
    _ => AppColors.riskLow,
  };

  static Color _bg(String level) => switch (level) {
    'critical' => AppColors.riskCriticalBg,
    'high' => AppColors.riskHighBg,
    'medium' => AppColors.riskMediumBg,
    _ => AppColors.riskLowBg,
  };

  static String _label(String level) => switch (level) {
    'critical' => 'Critical',
    'high' => 'High',
    'medium' => 'Medium',
    _ => 'Low',
  };

  static const _headerStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 0.8,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top 5 Risk Areas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        // Header row — same flex proportions as data rows (25 / 55 / 20)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Expanded(
                flex: 5,
                child: Text('RANK\nDISTRICT', style: _headerStyle),
              ),
              Expanded(
                flex: 11,
                child: Text('RISK SCORE', style: _headerStyle),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'STATUS',
                  textAlign: TextAlign.right,
                  style: _headerStyle,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE8EAF0)),
        ...areas.asMap().entries.map(
          (e) => _RankingRow(
            area: e.value,
            isLast: e.key == areas.length - 1,
            levelColor: _color(e.value.level),
            levelBg: _bg(e.value.level),
            levelLabel: _label(e.value.level),
          ),
        ),
      ],
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.area,
    required this.isLast,
    required this.levelColor,
    required this.levelBg,
    required this.levelLabel,
  });

  final _RankArea area;
  final bool isLast;
  final Color levelColor;
  final Color levelBg;
  final String levelLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE8EAF0))),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Col 1 — 25%: rank badge + name
          Expanded(
            flex: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: levelColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '#${area.rank}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    area.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Col 2 — 55%: score + full-width bar
          Expanded(
            flex: 11,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${area.score}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: levelColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEEF2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: (area.score / 100).clamp(0.0, 1.0),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: levelColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Col 3 — 20%: status badge right-aligned
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: levelBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: levelColor.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  levelLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: levelColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Month + Year Picker Dialog ───────────────────────────────────────────────
// A custom StatefulWidget dialog that lets the user pick a month and year.
// Returns a "YYYY-MM" string via Navigator.pop when the user taps a month.
// No day selection — only month and year.

class _MonthYearPickerDialog extends StatefulWidget {
  const _MonthYearPickerDialog({
    required this.initialYear,
    required this.initialMonth,
  });

  final int initialYear;
  final int initialMonth;

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _year;
  late int _month;

  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _month = widget.initialMonth;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final canGoForward =
        _year < now.year || (_year == now.year && _month < now.month);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Year navigation row ───────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: AppColors.primary,
                  onPressed: () => setState(() => _year--),
                ),
                Text(
                  '$_year',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: canGoForward ? AppColors.primary : AppColors.border,
                  onPressed: canGoForward
                      ? () => setState(() => _year++)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ── 3×4 month grid ───────────────────────────────
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.2,
              ),
              itemBuilder: (context, index) {
                final monthNumber = index + 1; // 1-based
                // Highlight the currently selected month.
                final isHighlighted = monthNumber == _month;
                // Disable future months.
                final isFuture =
                    _year > now.year ||
                    (_year == now.year && monthNumber > now.month);

                return GestureDetector(
                  onTap: isFuture
                      ? null
                      : () {
                          setState(() => _month = monthNumber);
                          final key =
                              '$_year-${monthNumber.toString().padLeft(2, '0')}';
                          Navigator.of(context).pop(key);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isHighlighted && !isFuture
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isHighlighted && !isFuture
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _monthNames[index],
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isFuture
                              ? AppColors.textHint
                              : isHighlighted
                              ? AppColors.textOnPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // ── Cancel button ────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
