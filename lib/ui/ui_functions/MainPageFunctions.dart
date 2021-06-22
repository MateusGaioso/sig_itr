import 'dart:async';
import 'dart:typed_data';

import 'package:app_itr/etc/PolygonGenerator.dart';
import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:latlong2/latlong.dart' as LatLng2;
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

List<LatLng> polygonLatLngs = [];



Future<BitmapDescriptor> getPin(String tipo) async {
  String asset;
  if (tipo == 'vertice') {
    asset = 'assets/images/vertice_marker.png';
  } else if (tipo == 'sede') {
    asset = 'assets/images/sede_marker.png';
  } else if (tipo == 'acesso-principal') {
    asset = 'assets/images/acesso_principal.png';
  } else if (tipo == 'center') {
    asset = 'assets/images/center_marker.png';
  } else if (tipo == 'imovel_route') {
    asset = 'assets/images/location_marker.png';
  } else if (tipo == 'imovel_sede') {
    asset = 'assets/images/arrow_marker.png';
  } else if (tipo == 'ponte') {
    asset = 'assets/images/bridge.png';
  } else {
    asset = 'assets/images/vertice_marker.png';
  }
  BitmapDescriptor pinLocationIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 1.5), asset);

  return pinLocationIcon;
}

Future<BitmapDescriptor> bitmapDescriptorFromSvgAsset(BuildContext context, String assetName) async {
  // Read SVG file as String
  String svgString = await DefaultAssetBundle.of(context).loadString(assetName);
  // Create DrawableRoot from SVG String
  DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, "");

  // toPicture() and toImage() don't seem to be pixel ratio aware, so we calculate the actual sizes here
  MediaQueryData queryData = MediaQuery.of(context);
  double devicePixelRatio = queryData.devicePixelRatio;
  double width = 32 * devicePixelRatio; // where 32 is your SVG's original width
  double height = 32 * devicePixelRatio; // same thing

  // Convert to ui.Picture
  ui.Picture picture = svgDrawableRoot.toPicture(size: Size(width, height));

  // Convert to ui.Image. toImage() takes width and height as parameters
  // you need to find the best size to suit your needs and take into account the
  // screen DPI
  ui.Image image = await picture.toImage(width.round(), height.round());
  ByteData bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
  return BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
}

class LatLng2WithDistance extends LatLng2.LatLng {
  double _distance = 0.0;
  LatLng2WithDistance(double latitude, double longitude) : super(latitude, longitude);

  double get distance => _distance;

  set distance(double value) {
    _distance = value;
  }

  @override
  String toString() {
    return 'LatLng2WithDistance{_distance: $_distance, latitude: $latitude, longitude: $longitude}';
  }
}

class PointObject {
  Widget? _child;
  LatLngWithAngle? _location;

  PointObject();

  LatLngWithAngle? get location => _location;

  set location(LatLngWithAngle? value) {
    _location = value;
  }

  Widget? get child => _child;

  set child(Widget? value) {
    _child = value;
  }
}

class _InfoWidgetRouteLayout<T> extends SingleChildLayoutDelegate {
  final Rect? mapsWidgetSize;
  final double? width;
  final double? height;

  _InfoWidgetRouteLayout(
      {@required this.mapsWidgetSize,
        @required this.height,
        @required this.width});

  /// Depending of the size of the marker or the widget, the offset in y direction has to be adjusted;
  /// If the appear to be of different size, the commented code can be uncommented and
  /// adjusted to get the right position of the Widget.
  /// Or better: Adjust the marker size based on the device pixel ratio!!!!)

  @override
  Offset getPositionForChild(Size size, Size childSize) {
//    if (Platform.isIOS) {
    return Offset(
      mapsWidgetSize!.center.dx - childSize.width / 2,
      mapsWidgetSize!.center.dy - childSize.height - 2,
    );
//    } else {
//      return Offset(
//        mapsWidgetSize.center.dx - childSize.width / 2,
//        mapsWidgetSize.center.dy - childSize.height - 10,
//      );
//    }
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    //we expand the layout to our predefined sizes
    return BoxConstraints.expand(width: width, height: height);
  }

  @override
  bool shouldRelayout(_InfoWidgetRouteLayout oldDelegate) {
    return mapsWidgetSize != oldDelegate.mapsWidgetSize;
  }
}

class InfoWidgetRoute extends PopupRoute {
  final Widget? child;
  final double? width;
  final double? height;
  final BuildContext? buildContext;
  final TextStyle? textStyle;
  final Rect? mapsWidgetSize;

  InfoWidgetRoute({
    @required this.child,
    @required this.buildContext,
    @required this.textStyle,
    @required this.mapsWidgetSize,
    this.width = 250,
    this.height = 160,
    this.barrierLabel,
  });

  @override
  Duration get transitionDuration => Duration(milliseconds: 100);

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => null;

  @override
  final String? barrierLabel;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      removeTop: true,
      child: Builder(builder: (BuildContext context) {
        return CustomSingleChildLayout(
          delegate: _InfoWidgetRouteLayout(
              mapsWidgetSize: mapsWidgetSize, width: width, height: height),
          child: InfoWidgetPopUp(
            infoWidgetRoute: this,
          ),
        );
      }),
    );
  }
}

class InfoWidgetPopUp extends StatefulWidget {
  const InfoWidgetPopUp({
    Key? key,
    @required this.infoWidgetRoute,
  })  : assert(infoWidgetRoute != null),
        super(key: key);

  final InfoWidgetRoute? infoWidgetRoute;

  @override
  _InfoWidgetPopUpState createState() => _InfoWidgetPopUpState();
}

class _InfoWidgetPopUpState extends State<InfoWidgetPopUp> {
  late CurvedAnimation _fadeOpacity;

  @override
  void initState() {
    super.initState();
    _fadeOpacity = CurvedAnimation(
      parent: widget.infoWidgetRoute!.animation!,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeOpacity,
      child: Material(
        type: MaterialType.transparency,
        textStyle: widget.infoWidgetRoute!.textStyle,
        child: ClipPath(
          clipper: _InfoWidgetClipper(),
          child: Container(
            color: ColorsCTRM.primaryColorDarkAlpha66,
            padding: EdgeInsets.only(bottom: 10),
            child: Center(child: widget.infoWidgetRoute!.child),
          ),
        ),
      ),
    );
  }
}

class _InfoWidgetClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height - 20);
    path.quadraticBezierTo(0.0, size.height - 10, 10.0, size.height - 10);
    path.lineTo(size.width / 2 - 10, size.height - 10);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width / 2 + 10, size.height - 10);
    path.lineTo(size.width - 10, size.height - 10);
    path.quadraticBezierTo(
        size.width, size.height - 10, size.width, size.height - 20);
    path.lineTo(size.width, 10.0);
    path.quadraticBezierTo(size.width, 0.0, size.width - 10.0, 0.0);
    path.lineTo(10, 0.0);
    path.quadraticBezierTo(0.0, 0.0, 0.0, 10);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}




