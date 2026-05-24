import 'package:geofencing_api/geofencing_api.dart';

export 'package:geofencing_api/geofencing_api.dart'
    show GeofenceRegion, GeofencePolygonRegion, LatLng;

abstract class Place {
  const Place();

  String get id;
  String get name;
  GeofenceRegion get area;
  List<String> get neighbor;
  List<String> extendedNeighbor(Map<String, Place> lookup);

  Map<String, dynamic> toJson();
}
