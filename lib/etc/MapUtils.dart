import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'PolygonGenerator.dart';


class MapUtils{

  static void setMapFitToTour(Set<Polyline> p, GoogleMapController controller) {
    double minLat = p.first.points.first.latitude;
    double minLong = p.first.points.first.longitude;
    double maxLat = p.first.points.first.latitude;
    double maxLong = p.first.points.first.longitude;
    p.forEach((poly) {
      poly.points.forEach((point) {
        if(point.latitude < minLat) minLat = point.latitude;
        if(point.latitude > maxLat) maxLat = point.latitude;
        if(point.longitude < minLong) minLong = point.longitude;
        if(point.longitude > maxLong) maxLong = point.longitude;
      });
    });
    controller.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(
        southwest: LatLng(minLat, minLong),
        northeast: LatLng(maxLat,maxLong)
    ), 25));
  }

  static void setMapPolygonFitToTour(List<LatLngWithAngle> p, GoogleMapController controller) {
    double minLat = p.first.latitude;
    double minLong = p.first.longitude;
    double maxLat = p.first.latitude;
    double maxLong = p.first.longitude;
    p.forEach((point) {
      if(point.latitude < minLat) minLat = point.latitude;
      if(point.latitude > maxLat) maxLat = point.latitude;
      if(point.longitude < minLong) minLong = point.longitude;
      if(point.longitude > maxLong) maxLong = point.longitude;
    });
    controller.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(
        southwest: LatLng(minLat, minLong),
        northeast: LatLng(maxLat,maxLong)
    ), 100));
  }

}

