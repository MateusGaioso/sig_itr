import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class LatLngWithAngle extends LatLng{

  late double angle;
  late int id;
  LatLngWithAngle(double latitude, double longitude) : super(latitude, longitude);

}

class PolygonGenerator{

  PolygonGenerator(this.points);

  List<LatLngWithAngle> points;
  late LatLng center;

  LatLng findCenter(){
    double x = 0;
    double y = 0;
    int i;
    int len = points.length;

    for(i = 0; i < len; i++){
      x += points[i].latitude;
      y += points[i].longitude;
    }

    center = LatLng(x / len, y / len);
    return center;

  }

  void findAngles() {

    int i;
    int len = points.length;
    LatLngWithAngle p;
    double dx;
    double dy;

    for (i = 0; i < len; i++) {
      p = points[i];
      dx = p.latitude - center.latitude;
      dy = p.longitude - center.longitude;
      p.angle = atan2(dy, dx);
    }

  }


  List<LatLngWithAngle> getSortedList(){
    findCenter();
    findAngles();
    points.sort((a, b) => a.angle > b.angle ? 1 : a.angle < b.angle ? -1 : 0 );

    for(int i = 0; i < points.length; i++){
      print("$i => " + points[i].toString());
    }
    return points;
  }

  @override
  String toString() {
    return "POINTS -> $points";
  }
}