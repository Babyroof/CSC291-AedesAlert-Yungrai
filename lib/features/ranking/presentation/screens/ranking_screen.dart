import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/utils/risk_level_utils.dart';
import 'package:aedes_alert_yungrai/core/widgets/yungrai_app_bar.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/entities/ranking_area_entity.dart';
import 'package:aedes_alert_yungrai/features/ranking/presentation/controllers/ranking_stream_provider.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(rankedAreasStreamProvider);
    return Scaffold(
      appBar: const YungraiAppBar(showBackButton: true),
      body: state.areas.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (areas) => ListView.builder(
          itemCount: areas.length,
          itemBuilder: (context, index) =>
              _RankingCard(rank: areas[index].rank != 0 ? areas[index].rank : index + 1, area: areas[index]),
        ),
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  const _RankingCard({required this.rank, required this.area});

  final int rank;
  final RankingAreaEntity area;

  @override
  Widget build(BuildContext context) {
    final color = RiskLevelUtils.colorForLevel(area.riskLevel);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Text(
          '$rank',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text('${area.subDistrict}, ${area.district}'),
      subtitle: Text(area.province),
      trailing: Chip(
        label: Text(
          area.riskLevel.toUpperCase(),
          style: TextStyle(color: color, fontSize: 11),
        ),
        backgroundColor: color.withValues(alpha: 0.15),
        side: BorderSide(color: color),
      ),
    );
  }
}