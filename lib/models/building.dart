import 'package:open_source_software/models/place.dart';

class Building extends Place {
  final String _name;
  final GeofenceRegion _area;
  final HashPlace _neighbor;
  final List<Place> neighborPlace;

  Building({
    required String name,
    required GeofenceRegion area,
    required HashPlace neighbor,
    List<Place>? neighborPlace,
  })  : _name = name,
        _area = area,
        _neighbor = neighbor,
        neighborPlace = neighborPlace ?? [];

  @override
  String get name => _name;

  @override
  GeofenceRegion get area => _area;

  @override
  HashPlace get neighbor => _neighbor;

  @override
  HashPlace get extendedNeighbor {
    return HashPlace(
      hash: _neighbor.hash,
      neighborHashes: _neighbor.getExtendedNeighbors(),
    );
  }

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      name: json['name'],
      area: GeofenceRegion.fromJson(json['area']),
      neighbor: HashPlace.fromJson(json['neighbor']),
      neighborPlace: (json['neighborPlace'] as List<dynamic>?)
          ?.map((e) => Building.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': _name,
      'area': _area.toJson(),
      'neighbor': _neighbor.toJson(),
      'neighborPlace': neighborPlace.map((e) => e.toJson()).toList(),
    };
  }

  Building copyWith({
    String? name,
    GeofenceRegion? area,
    HashPlace? neighbor,
    List<Place>? neighborPlace,
  }) {
    return Building(
      name: name ?? _name,
      area: area ?? _area,
      neighbor: neighbor ?? _neighbor,
      neighborPlace: neighborPlace ?? List.from(this.neighborPlace),
    );
  }
}
