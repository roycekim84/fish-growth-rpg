class RegionDefinition {
  const RegionDefinition({
    required this.id,
    required this.displayName,
    required this.description,
    required this.discoveryPoints,
  });

  factory RegionDefinition.fromJson(Map<String, dynamic> json) {
    final points = json['discoveryPoints'] as List<dynamic>;
    return RegionDefinition(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String,
      discoveryPoints: points
          .map(
            (item) =>
                RegionDiscoveryPoint.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }

  final String id;
  final String displayName;
  final String description;
  final List<RegionDiscoveryPoint> discoveryPoints;
}

class RegionDiscoveryPoint {
  const RegionDiscoveryPoint({
    required this.id,
    required this.displayName,
    required this.description,
    required this.x,
    required this.y,
    required this.radius,
  });

  factory RegionDiscoveryPoint.fromJson(Map<String, dynamic> json) {
    return RegionDiscoveryPoint(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
    );
  }

  final String id;
  final String displayName;
  final String description;
  final double x;
  final double y;
  final double radius;
}

class RegionDiscoveryEvent {
  const RegionDiscoveryEvent({
    required this.regionId,
    required this.pointId,
    required this.pointName,
    required this.completedRegion,
  });

  final String regionId;
  final String pointId;
  final String pointName;
  final bool completedRegion;
}
