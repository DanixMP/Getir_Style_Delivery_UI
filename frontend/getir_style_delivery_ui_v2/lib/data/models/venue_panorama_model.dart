import '../../core/network/api_parsing.dart';

class VenuePanoramaModel {
  const VenuePanoramaModel({
    required this.imageUrl,
    this.initialYaw = 0,
  });

  final String imageUrl;
  final double initialYaw;

  factory VenuePanoramaModel.fromJson(Map<String, dynamic> json) =>
      VenuePanoramaModel(
        imageUrl: mediaUrl(json['image'] as String?) ??
            mediaUrl(json['image_url'] as String?) ??
            '',
        initialYaw: parseDouble(json['initial_yaw']),
      );
}
