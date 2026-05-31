import 'package:maps_toolkit/maps_toolkit.dart';

/// 캠퍼스 건물 한 개를 표현하는 모델.
///
/// 건물 이름과 외곽선 폴리곤 좌표를 담으며,
/// 특정 GPS 좌표가 이 건물 안에 있는지 판별하는 기능을 제공한다.
///
/// 기존 [Place] / [Building] / [GeofenceRegion] 은 원형(중심점+반지름)
/// 구조라 폴리곤 데이터와 맞지 않으므로, 폴리곤 판별 전용으로 분리한 모델이다.
class CampusBuilding {
  /// 건물 이름 (예: '정보문화관', '원흥관')
  final String name;

  /// 건물 외곽선을 이루는 폴리곤 좌표 목록.
  ///
  /// maps_toolkit 의 [LatLng] 를 그대로 사용하므로,
  /// 5단계의 점 포함 판별에서 변환 없이 바로 쓸 수 있다.
  final List<LatLng> polygon;

  CampusBuilding({
    required this.name,
    required this.polygon,
  });

  /// GeoJSON 의 feature 한 개를 받아 [CampusBuilding] 으로 변환한다.
  ///
  /// 주의: GeoJSON 좌표는 [경도, 위도] 순서지만,
  /// maps_toolkit 의 [LatLng] 생성자는 (위도, 경도) 순서이므로
  /// 여기서 순서를 뒤집어 준다.
  factory CampusBuilding.fromGeoJsonFeature(Map<String, dynamic> feature) {
    // 건물 이름 — properties.이름
    final properties = feature['properties'] as Map<String, dynamic>;
    final String name = properties['이름'] as String;

    // 폴리곤 좌표 — geometry.coordinates[0]
    // GeoJSON Polygon 의 coordinates 는 "링(ring)들의 배열" 구조라
    // 바깥 외곽선은 첫 번째 링([0])에 해당한다.
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;
    final outerRing = coordinates[0] as List<dynamic>;

    final List<LatLng> polygon = outerRing.map((point) {
      final coord = point as List<dynamic>;
   // 🟢 이렇게 고쳐야 정확히 [위도, 경도] 순서로 들어갑니다.
      final double lng = (coord[0] as num).toDouble(); // 경도 (126.xxx)
      final double lat = (coord[1] as num).toDouble(); // 위도 (37.xxx)

      // LatLng 생성자에는 (위도, 경도) 순서로 넣습니다!
      return LatLng(lat, lng);
    }).toList();

    return CampusBuilding(name: name, polygon: polygon);
  }

  /// 주어진 좌표가 이 건물 폴리곤 내부에 있는지 판별한다.
  ///
  /// maps_toolkit 의 point-in-polygon 알고리즘을 사용한다.
  /// 폴리곤 경계선 위의 점도 내부로 간주한다(geodesic: true).
  bool contains(LatLng point) {
    return PolygonUtil.containsLocation(point, polygon, true);
  }

  @override
  String toString() => 'CampusBuilding(name: $name, points: ${polygon.length})';
}