class AddressModel {
  const AddressModel({
    required this.id,
    required this.title,
    required this.details,
    required this.city,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String title;
  final String details;
  final String city;
  final double? latitude;
  final double? longitude;

  bool get hasCoordinates => latitude != null && longitude != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'details': details,
        'city': city,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        details: json['details'] as String? ?? '',
        city: json['city'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );
}
