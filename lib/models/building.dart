import 'package:maps_toolkit/maps_toolkit.dart' as mk;
import 'package:open_source_software/models/place.dart';

class Building extends Place {
  final String _id;
  final String _name;
  final GeofencePolygonRegion _area;
  final List<String> _neighbor;

  Building({
    required String id,
    required String name,
    required GeofencePolygonRegion area,
    required List<String> neighbor,
  }) : _id = id,
       _name = name,
       _area = area,
       _neighbor = neighbor;

  @override
  String get id => _id;

  @override
  String get name => _name;

  @override
  GeofenceRegion get area => _area;

  @override
  List<String> get neighbor => _neighbor;

  // extendedNeighbor 호출 시에는 TestDataManager.places로 만든 Map<String, Place>를 넘기면 됨
  @override
  List<String> extendedNeighbor(Map<String, Place> lookup) {
    final visited = <String>{};
    final queue = <String>[..._neighbor];
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (visited.add(current)) {
        queue.addAll(lookup[current]?.neighbor ?? []);
      }
    }
    return visited.toList();
  }

  factory Building.fromGeoJsonFeature(Map<String, dynamic> feature) {
    final properties = feature['properties'] as Map<String, dynamic>;
    final String name = properties['이름'] as String;

    final geometry = feature['geometry'] as Map<String, dynamic>;
    final outerRing = (geometry['coordinates'] as List<dynamic>)[0] as List<dynamic>;

    final polygon = outerRing.map((point) {
      final coord = point as List<dynamic>;
      final double lng = (coord[0] as num).toDouble();
      final double lat = (coord[1] as num).toDouble();
      return LatLng(lat, lng); // geofencing_api LatLng (위도, 경도)
    }).toList();

    return Building(
      id: name,
      name: name,
      area: GeofencePolygonRegion(id: name, polygon: polygon),
      neighbor: [],
    );
  }

  factory Building.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    return Building(
      id: id,
      name: json['name'] as String,
      area: GeofencePolygonRegion(
        id: id,
        polygon: (json['area'] as List<dynamic>)
            .map(
              (e) => LatLng(e['latitude'] as double, e['longitude'] as double),
            )
            .toList(),
      ),
      neighbor: (json['neighbor'] as List<String>? ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'area': _area.polygon
          .map((p) => {'latitude': p.latitude, 'longitude': p.longitude})
          .toList(),
      'neighbor': _neighbor.toList(),
    };
  }

  /// GPS 좌표가 이 건물 폴리곤 안에 있는지 판별한다.
  bool containsLocation(double latitude, double longitude) {
    final point = mk.LatLng(latitude, longitude);
    final mkPolygon = _area.polygon
        .map((p) => mk.LatLng(p.latitude, p.longitude))
        .toList();
    return mk.PolygonUtil.containsLocation(point, mkPolygon, true);
  }

  Building copyWith({
    String? id,
    String? name,
    GeofencePolygonRegion? area,
    List<String>? neighbor,
  }) {
    return Building(
      id: id ?? _id,
      name: name ?? _name,
      area: area ?? _area,
      neighbor: neighbor ?? List.from(_neighbor),
    );
  }
}
