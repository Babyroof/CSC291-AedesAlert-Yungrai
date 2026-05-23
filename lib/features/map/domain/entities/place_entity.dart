class PlaceEntity {
  const PlaceEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
    required this.phoneNumber,
    required this.type,
  });

  final String id;
  final String name;
  final String description;
  final double lat;
  final double lng;
  final String phoneNumber;
  final String type;
}
