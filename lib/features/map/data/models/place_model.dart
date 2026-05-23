import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aedes_alert_yungrai/features/map/domain/entities/place_entity.dart';

class PlaceModel {
  const PlaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.phoneNumber,
    required this.type,
  });

  final String id;
  final String name;
  final String description;
  final GeoPoint location;
  final String phoneNumber;
  final String type;

  factory PlaceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return PlaceModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      location: data['location'] as GeoPoint,
      phoneNumber: data['phoneNumber'] as String? ?? '',
      type: data['type'] as String? ?? 'hospital',
    );
  }

  PlaceEntity toEntity() => PlaceEntity(
        id: id,
        name: name,
        description: description,
        lat: location.latitude,
        lng: location.longitude,
        phoneNumber: phoneNumber,
        type: type,
      );
}
