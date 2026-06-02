import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/risk_level_utils.dart';
import '../../../../core/widgets/yungrai_app_bar.dart';
import '../../domain/entities/map_area_entity.dart';
import '../../domain/entities/place_entity.dart';
import '../controllers/map_controller.dart' hide MapController;

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _searchController = TextEditingController();
  final _flutterMapController = MapController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _fetchUserLocation();
    });
  }

  Future<void> _fetchUserLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      ref
          .read(mapControllerProvider.notifier)
          .setUserLocation(pos.latitude, pos.longitude);
      _flutterMapController.move(LatLng(pos.latitude, pos.longitude), 14);
    } catch (_) {
      // location unavailable — map stays on default center
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _flutterMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapControllerProvider);
    final areas = state.areas.valueOrNull ?? [];
    final places = state.places.valueOrNull ?? [];
    final filterMode = state.filterMode;
    final searchQuery = state.searchQuery.toLowerCase();

    final showRiskAreas = filterMode == 'riskAreas';
    final showHospitals = filterMode == 'hospitals';

    final filteredAreas =
        areas
            .where(
              (a) =>
                  searchQuery.isEmpty ||
                  a.subDistrict.toLowerCase().contains(searchQuery) ||
                  a.district.toLowerCase().contains(searchQuery) ||
                  a.province.toLowerCase().contains(searchQuery),
            )
            .toList()
          ..sort((a, b) => b.riskScore.compareTo(a.riskScore));

    final topAreas = filteredAreas.take(3).toList();

    final criticalCount = areas.where((a) => a.riskLevel == 'critical').length;
    final highCount = areas.where((a) => a.riskLevel == 'high').length;
    final mediumCount = areas.where((a) => a.riskLevel == 'medium').length;

    final mapCenter = areas.isNotEmpty
        ? LatLng(areas.first.lat, areas.first.lng)
        : const LatLng(18.7883, 98.9853);

    return Scaffold(
      appBar: const YungraiAppBar(),
      body: Stack(
        children: [
          // ── Map full screen ───────────────────────────────────────
          FlutterMap(
            mapController: _flutterMapController,
            options: MapOptions(initialCenter: mapCenter, initialZoom: 13),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yungrai.aedes_alert',
              ),
              if (showRiskAreas)
                CircleLayer(
                  circles: areas.map((a) {
                    final color = RiskLevelUtils.colorForLevel(a.riskLevel);
                    return CircleMarker(
                      point: LatLng(a.lat, a.lng),
                      radius: a.radius,
                      useRadiusInMeter: true,
                      color: color.withValues(alpha: 0.25),
                      borderColor: color,
                      borderStrokeWidth: 1.5,
                    );
                  }).toList(),
                ),
              if (showHospitals)
                MarkerLayer(
                  markers: places.map((p) => _hospitalMarker(p)).toList(),
                ),
              // ── User location marker ───────────────────────────
              if (state.userLat != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(state.userLat!, state.userLng!),
                      width: 48,
                      height: 48,
                      child: const _UserLocationMarker(),
                    ),
                  ],
                ),
            ],
          ),

          // ── Search + filter overlay ───────────────────────────────
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: _MapOverlay(
              controller: _searchController,
              filterMode: filterMode,
              onSearchChanged: (q) {
                ref.read(mapControllerProvider.notifier).setSearch(q);
                if (q.isNotEmpty) {
                  final lower = q.toLowerCase();
                  final match =
                      areas
                          .where(
                            (a) =>
                                a.subDistrict.toLowerCase().contains(lower) ||
                                a.district.toLowerCase().contains(lower) ||
                                a.province.toLowerCase().contains(lower),
                          )
                          .toList()
                        ..sort((a, b) => b.riskScore.compareTo(a.riskScore));
                  if (match.isNotEmpty) {
                    _flutterMapController.move(
                      LatLng(match.first.lat, match.first.lng),
                      14,
                    );
                  }
                }
              },
              onFilterChanged: (mode) =>
                  ref.read(mapControllerProvider.notifier).setFilter(mode!),
            ),
          ),

          // ── Draggable bottom panel ────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.38,
            minChildSize: 0.08,
            maxChildSize: 0.75,
            snap: true,
            snapSizes: const [0.08, 0.38, 0.75],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: state.areas.when(
                  loading: () => Column(
                    children: [
                      const _DragHandle(),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  ),
                  error: (e, _) => Column(
                    children: [
                      const _DragHandle(),
                      Expanded(child: Center(child: Text('Error: $e'))),
                    ],
                  ),
                  data: (_) => CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverToBoxAdapter(child: const _DragHandle()),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: _RiskCountRow(
                            critical: criticalCount,
                            high: highCount,
                            medium: mediumCount,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        sliver: SliverToBoxAdapter(
                          child: _TopRiskZonesSection(
                            areas: topAreas,
                            showAll: searchQuery.isNotEmpty,
                            onViewAll: () => context.push('/ranking'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Marker _hospitalMarker(PlaceEntity p) => Marker(
    point: LatLng(p.lat, p.lng),
    width: 36,
    height: 36,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.local_hospital,
        color: AppColors.riskHigh,
        size: 20,
      ),
    ),
  );
}

// ── User location marker ───────────────────────────────────────────────────

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // outer pulse ring
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
        // middle white ring
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x331B2B6B),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        // inner solid dot
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
        ),
        // center white dot
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ── Drag handle ───────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ── Map overlay: search bar ────────────────────────────────────────────────

class _MapOverlay extends StatelessWidget {
  const _MapOverlay({
    required this.controller,
    required this.filterMode,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  final TextEditingController controller;
  final String filterMode;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: controller,
              onChanged: onSearchChanged,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: 'Search risky areas...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: filterMode,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              items: const [
                DropdownMenuItem(value: 'riskAreas', child: Text('Risk Areas')),
                DropdownMenuItem(value: 'hospitals', child: Text('Hospitals')),
              ],
              onChanged: onFilterChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Risk count summary cards ───────────────────────────────────────────────

class _RiskCountRow extends StatelessWidget {
  const _RiskCountRow({
    required this.critical,
    required this.high,
    required this.medium,
  });

  final int critical;
  final int high;
  final int medium;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RiskCountCard(
            label: 'CRITICAL',
            count: critical,
            color: AppColors.riskCritical,
            bg: AppColors.riskCriticalBg,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RiskCountCard(
            label: 'HIGH',
            count: high,
            color: AppColors.riskHigh,
            bg: AppColors.riskHighBg,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RiskCountCard(
            label: 'MEDIUM',
            count: medium,
            color: AppColors.riskMedium,
            bg: AppColors.riskMediumBg,
          ),
        ),
      ],
    );
  }
}

class _RiskCountCard extends StatelessWidget {
  const _RiskCountCard({
    required this.label,
    required this.count,
    required this.color,
    required this.bg,
  });

  final String label;
  final int count;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top Risk Zones ─────────────────────────────────────────────────────────

class _TopRiskZonesSection extends StatelessWidget {
  const _TopRiskZonesSection({
    required this.areas,
    required this.showAll,
    required this.onViewAll,
  });

  final List<MapAreaEntity> areas;
  final bool showAll;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top Risk Zones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (!showAll)
              TextButton(onPressed: onViewAll, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 8),
        if (areas.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No zones found',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < areas.length; i++) ...[
                  _ZoneRow(area: areas[i]),
                  if (i < areas.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _ZoneRow extends StatelessWidget {
  const _ZoneRow({required this.area});

  final MapAreaEntity area;

  @override
  Widget build(BuildContext context) {
    final color = RiskLevelUtils.colorForLevel(area.riskLevel);
    final progress = (area.riskScore / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 5, backgroundColor: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${area.subDistrict}, ${area.district}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _RiskChip(level: area.riskLevel, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${area.riskScore.toInt()}/100',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiskChip extends StatelessWidget {
  const _RiskChip({required this.level, required this.color});

  final String level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        level[0].toUpperCase() + level.substring(1),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
