class NeshanSearchResult {
  const NeshanSearchResult({
    required this.title,
    required this.address,
    required this.lat,
    required this.lng,
    this.neighbourhood = '',
    this.region = '',
  });

  final String title;
  final String address;
  final double lat;
  final double lng;
  final String neighbourhood;
  final String region;

  String get displayLabel =>
      address.isNotEmpty ? '$title — $address' : title;

  factory NeshanSearchResult.fromJson(Map<String, dynamic> json) =>
      NeshanSearchResult(
        title: json['title'] as String? ?? '',
        address: json['address'] as String? ?? '',
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        neighbourhood: json['neighbourhood'] as String? ?? '',
        region: json['region'] as String? ?? '',
      );
}
