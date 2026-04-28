class GeofenceRegion {
  final double latitude;
  final double longitude;
  final double radius;

  GeofenceRegion({
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  factory GeofenceRegion.fromJson(Map<String, dynamic> json) {
    return GeofenceRegion(
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
  }
}

class HashPlace {
  final String hash;
  final List<String> neighborHashes;

  HashPlace({
    required this.hash,
    List<String>? neighborHashes,
  }) : neighborHashes = neighborHashes ?? [];

  static String generateHash(double latitude, double longitude, {int precision = 8}) {
    String latBinary = _convertToBase4(latitude.abs(), precision);
    String lonBinary = _convertToBase4(longitude.abs(), precision);

    String combined = '';
    for (int i = 0; i < precision; i++) {
      combined += lonBinary[i] + latBinary[i];
    }

    return combined;
  }

  static String _convertToBase4(double value, int precision) {
    String result = '';
    double temp = value;

    for (int i = 0; i < precision; i++) {
      temp *= 10;
      int digit = temp.toInt() % 4;
      result += digit.toString();
      temp -= digit;
    }

    return result;
  }

  List<String> getExtendedNeighbors() {
    List<String> extended = List.from(neighborHashes);
    for (String neighbor in neighborHashes) {
      HashPlace neighborPlace = HashPlace(hash: neighbor);
      extended.addAll(neighborPlace.neighborHashes);
    }
    return extended.toSet().toList();
  }

  factory HashPlace.fromJson(Map<String, dynamic> json) {
    return HashPlace(
      hash: json['hash'],
      neighborHashes: (json['neighborHashes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'neighborHashes': neighborHashes,
    };
  }
}

abstract class Place {
  String get name;
  GeofenceRegion get area;
  HashPlace get neighbor;
  HashPlace get extendedNeighbor;

  Map<String, dynamic> toJson();
}
