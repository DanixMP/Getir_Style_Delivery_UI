/// Result of picking a location on the map before filling the address form.
class AddressMapPickResult {
  const AddressMapPickResult({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.city,
    required this.titleSuggestion,
  });

  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String city;
  final String titleSuggestion;
}
