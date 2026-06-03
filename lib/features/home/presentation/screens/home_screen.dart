import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/yungrai_app_bar.dart';
import '../../data/models/area_model.dart';
import '../../domain/entities/weather_forecast_model.dart';
import '../controllers/home_controller.dart';
import '../../../map/presentation/controllers/map_controller.dart';

// ── Helpers ────────────────────────────────────────────────────────────────

Color _riskColor(String level) {
  switch (level) {
    case 'critical':
      return AppColors.riskCritical;
    case 'high':
      return AppColors.riskHigh;
    case 'medium':
      return AppColors.riskMedium;
    default:
      return AppColors.riskLow;
  }
}

String _riskLabel(String level) {
  switch (level) {
    case 'critical':
      return 'Critical Risk';
    case 'high':
      return 'High Risk';
    case 'medium':
      return 'Medium Risk';
    default:
      return 'Low Risk';
  }
}

// ── Screen ─────────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition();
      ref
          .read(homeControllerProvider.notifier)
          .loadHomeData(GeoPoint(position.latitude, position.longitude));
    } catch (_) {
      // fallback to Chiang Mai (where seed data is)
      ref
          .read(homeControllerProvider.notifier)
          .loadHomeData(const GeoPoint(18.7904, 98.9847));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    final isLoading = state.nearestArea is AsyncLoading;
    final nearestArea = state.nearestArea.valueOrNull;
    final notification = state.latestNotification.valueOrNull;
    final forecast = state.weatherForecast.valueOrNull;

    // Use the latest district area record for risk score/level display.
    // Falls back to the nearest area if the district query has not resolved yet.
    final latestDistrictArea = state.latestDistrictArea.valueOrNull;
    final displayArea = latestDistrictArea ?? nearestArea;

    // The alert banner severity comes from the latest district data.
    final alertLevel = displayArea?.riskLevel;

    return Scaffold(
      appBar: const YungraiAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: isLoading
              ? const _LoadingBody()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (displayArea != null) _RiskCard(area: displayArea),
                    if (displayArea == null)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'No updated data in this month yet',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ),
                    if (displayArea != null) const SizedBox(height: 12),
                    if (displayArea != null &&
                        (alertLevel == 'high' || alertLevel == 'critical'))
                      _AlertBanner(
                        title: alertLevel == 'critical'
                            ? 'Critical Risk Alert'
                            : 'High Risk Alert',
                        body:
                            notification?.body ??
                            'High mosquito activity detected in your current zone. Please take immediate preventive measures.',
                      ),
                    if (displayArea != null &&
                        (alertLevel == 'high' || alertLevel == 'critical'))
                      const SizedBox(height: 20),
                    if (forecast != null) _WeatherSection(forecast: forecast),
                    if (forecast != null) const SizedBox(height: 20),
                    const _QuickServicesSection(),
                    const SizedBox(height: 24),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Loading ────────────────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Skeleton(height: 160, radius: 16),
        const SizedBox(height: 12),
        _Skeleton(height: 90, radius: 14),
        const SizedBox(height: 20),
        _Skeleton(height: 145, radius: 14),
        const SizedBox(height: 20),
        _Skeleton(height: 160, radius: 12),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.height, required this.radius});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Risk Card ──────────────────────────────────────────────────────────────

class _RiskCard extends StatelessWidget {
  const _RiskCard({required this.area});

  final AreaModel area;

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(area.riskLevel);
    // riskScore is already on a 0–100 scale — display it directly.
    // Bug was: dividing by 10 turned e.g. 4.0 → 0.4.
    final score = area.riskScore.toStringAsFixed(1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mosquito Breeding Risk',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            area.subDistrict.isNotEmpty
                ? '${area.subDistrict}, ${area.district} - ${area.province}'
                : '${area.district} - ${area.province}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Text(
            score,
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Risk Score', style: Theme.of(context).textTheme.bodyMedium),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _riskLabel(area.riskLevel),
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Alert Banner ───────────────────────────────────────────────────────────

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.riskCriticalBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.riskCritical.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppColors.riskCritical,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.riskCritical,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.riskCritical,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weather Section ────────────────────────────────────────────────────────

class _WeatherSection extends StatelessWidget {
  const _WeatherSection({required this.forecast});

  final WeatherForecastModel forecast;

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🌤', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'Weather Forecast',
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: forecast.days.length,
            separatorBuilder: (context, i) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final day = forecast.days[i];
              final dayName = _dayNames[day.date.weekday - 1];
              return _WeatherCard(
                day: dayName,
                tempMax: day.tempMax,
                tempMin: day.tempMin,
                rain: day.precipitationSum,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({
    required this.day,
    required this.tempMax,
    required this.tempMin,
    required this.rain,
  });

  final String day;
  final double tempMax;
  final double tempMin;
  final double rain;

  @override
  Widget build(BuildContext context) {
    final rainPct = (rain * 10).clamp(0, 100).toStringAsFixed(0);

    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('🌧', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text('$rainPct%', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                'Highest ',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const Icon(
                Icons.thermostat,
                size: 13,
                color: AppColors.riskCritical,
              ),
              Text(
                ' ${tempMax.toStringAsFixed(0)}°C',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Text(
                'Lowest  ',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const Icon(Icons.thermostat, size: 13, color: AppColors.info),
              Text(
                ' ${tempMin.toStringAsFixed(0)}°C',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick Services ─────────────────────────────────────────────────────────

class _QuickServicesSection extends ConsumerWidget {
  const _QuickServicesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Services', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: _ServiceButton(
                    icon: Icons.local_hospital_outlined,
                    label: 'Hospital Nearby',
                    onTap: () {
                      ref
                          .read(mapControllerProvider.notifier)
                          .setFilter('hospitals');
                      context.go(routeMap);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ServiceButton(
                    icon: Icons.newspaper_outlined,
                    label: 'News',
                    onTap: () => context.push(routeNews),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _ServiceButton extends StatelessWidget {
  const _ServiceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
