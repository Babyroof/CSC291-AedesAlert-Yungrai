import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/home/domain/entities/location_entity.dart';
import 'package:aedes_alert_yungrai/features/home/domain/repositories/location_service.dart';
import 'package:aedes_alert_yungrai/features/home/data/data_sources/location_service_impl.dart';

class GetUserLocationUseCase {
  const GetUserLocationUseCase(this._locationService);

  final LocationService _locationService;

  Future<LocationEntity> execute() => _locationService.getCurrentLocation();
}

final getUserLocationUseCaseProvider = Provider<GetUserLocationUseCase>((ref) {
  return GetUserLocationUseCase(ref.watch(locationServiceProvider));
});
