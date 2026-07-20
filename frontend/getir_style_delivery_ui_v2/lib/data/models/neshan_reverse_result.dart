class NeshanReverseResult {
  const NeshanReverseResult({
    required this.formattedAddress,
    required this.lat,
    required this.lng,
    this.city = '',
    this.state = '',
    this.neighbourhood = '',
    this.place = '',
    this.routeName = '',
    this.village = '',
    this.county = '',
  });

  final String formattedAddress;
  final double lat;
  final double lng;
  final String city;
  final String state;
  final String neighbourhood;
  final String place;
  final String routeName;
  final String village;
  final String county;

  /// City label for forms — never falls back to a hard-coded default.
  String get resolvedCity {
    final direct = city.trim();
    if (direct.isNotEmpty) return direct;

    final v = village.trim();
    if (v.isNotEmpty) return v;

    final addr = formattedAddress.trim();
    if (addr.contains('،')) {
      final first = addr.split('،').first.trim();
      if (first.isNotEmpty) return first;
    }
    if (addr.contains(',')) {
      final first = addr.split(',').first.trim();
      if (first.isNotEmpty) return first;
    }

    final c = county.trim();
    if (c.isNotEmpty) {
      return c.startsWith('شهرستان ') ? c.substring('شهرستان '.length) : c;
    }

    final st = state.trim();
    if (st.isNotEmpty) {
      return st.startsWith('استان ') ? st.substring('استان '.length) : st;
    }

    return '';
  }

  String get shortLabel {
    if (place.isNotEmpty) return place;
    if (neighbourhood.isNotEmpty) return neighbourhood;
    if (routeName.isNotEmpty) return routeName;
    return resolvedCity.isNotEmpty ? resolvedCity : 'موقعیت انتخابی';
  }

  factory NeshanReverseResult.fromJson(Map<String, dynamic> json) =>
      NeshanReverseResult(
        formattedAddress: json['formatted_address'] as String? ?? '',
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        city: json['city'] as String? ?? '',
        state: json['state'] as String? ?? '',
        neighbourhood: json['neighbourhood'] as String? ?? '',
        place: json['place'] as String? ?? '',
        routeName: json['route_name'] as String? ?? '',
        village: json['village'] as String? ?? '',
        county: json['county'] as String? ?? '',
      );
}
