enum DiningTableStatus { available, occupied, reserved }

DiningTableStatus diningTableStatusFromJson(String? value) =>
    switch (value) {
      'occupied' => DiningTableStatus.occupied,
      'reserved' => DiningTableStatus.reserved,
      _ => DiningTableStatus.available,
    };

class DiningTableModel {
  const DiningTableModel({
    required this.id,
    required this.label,
    required this.hotspotYaw,
    required this.hotspotPitch,
    this.capacity = 2,
    this.status = DiningTableStatus.available,
  });

  final String id;
  final String label;
  final double hotspotYaw;
  final double hotspotPitch;
  final int capacity;
  final DiningTableStatus status;

  bool get isSelectable => status == DiningTableStatus.available;

  factory DiningTableModel.fromJson(Map<String, dynamic> json) =>
      DiningTableModel(
        id: json['id'] as String,
        label: json['label'] as String,
        hotspotYaw: _parseAngle(json['hotspot_yaw']),
        hotspotPitch: _parseAngle(json['hotspot_pitch']),
        capacity: json['capacity'] is int
            ? json['capacity'] as int
            : int.tryParse('${json['capacity']}') ?? 2,
        status: diningTableStatusFromJson(json['status'] as String?),
      );
}

double _parseAngle(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
