import 'dart:async';

import 'package:app_itr/api/dados_abertos_api.dart';
import 'package:app_itr/etc/ConnectionChecker.dart';
import 'package:app_itr/etc/CustomSnackBar.dart';
import 'package:app_itr/etc/MapUtils.dart';
import 'package:app_itr/etc/PolygonGenerator.dart';
import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/etc/custom_icons_icons.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:wakelock/wakelock.dart';

import 'package:latlong2/latlong.dart' as LatLng2;

import 'ui_functions/MainPageFunctions.dart';

String titleAppBar = "CTRM - ";

class DadosAbertosMapPage extends StatefulWidget {

  final String? userRoute;
  DadosAbertosMapPage({Key? key, String? this.userRoute}) : super(key: key);

  @override
  _DadosAbertosMapPageState createState() {

    return _DadosAbertosMapPageState(userRoute: userRoute);
  }
}

class _DadosAbertosMapPageState extends State<DadosAbertosMapPage> with SingleTickerProviderStateMixin {


  _DadosAbertosMapPageState({String? this.userRoute});

  late LoginDataStore _loginDataStore;
  DBHelper _helper = DBHelper();

  late ScrollController _scrollController;
  late AnimationController _animationController;
  FocusNode _focusNode = FocusNode();
  Completer<GoogleMapController> _controller = Completer();

  late String _mapStyle;
  late LatLng _initialPosition;

  final Set<Polyline> _polylineSet = {};
  final Set<Marker> _markerSet = {};
  final Set<Polygon> _polygonSet = {};

  bool _stopLoop = false;

  StreamSubscription? _mapIdleSubscription;
  InfoWidgetRoute? _infoWidgetRoute;

  String? userRoute;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(vsync: this, duration: kThemeAnimationDuration, value: 1);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    Wakelock.enable();

    rootBundle.loadString('assets/mapStyle.txt').then((string) {
      _mapStyle = string;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _focusNode.dispose();

    _loginDataStore.fullDataClear();

    _stopLoop = true;

    _helper.getAllImoveisDadosAbertosByMunicipio(_loginDataStore);

    Wakelock.disable();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginDataStore = Provider.of<LoginDataStore>(context);
    _initialPosition = LatLng(_loginDataStore.userPosition!.latitude, _loginDataStore.userPosition!.longitude);
    print("height status bar:^${_loginDataStore.statusBarHeight}");
    //_showRoute();
  }

  _getUserLocation(bool clear, bool showRoute) async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    print("POSITION -> &latitude=${position.latitude}&longitude=${position.longitude}");
    final GoogleMapController controller = await _controller.future;
    if (showRoute) {
      _showRoute();
    } else {
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 17.5)));
      _loginDataStore.setUserPosition(position);
    }
    if (clear) {
      setState(() {
        _polylineSet.clear();
        _polygonSet.clear();
        _markerSet.clear();
      });
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Imóvel selecionado muito distante, a rota foi gerada a partir do município ${_loginDataStore.m.municipio_plus_uf()}",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          actions: <Widget>[
            // define os botões na base do dialogo
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                child: Text(
                  "OK",
                  style: FontsStyleCTRM.primaryFontWhite,
                ),
                style: ElevatedButton.styleFrom(primary: ColorsCTRM.primaryColor),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showRoute();
                },
              ),
            )
          ],
        );
      },
    );
  }

  void _showOfflineMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Você está Offline}",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Text(
            "Não foi possível carregar sua localização atual, a rota foi gerada a partir do município ${_loginDataStore.m.municipio_plus_uf()}",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          actions: <Widget>[
            // define os botões na base do dialogo
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                child: Text(
                  "OK",
                  style: FontsStyleCTRM.primaryFontWhite,
                ),
                style: ElevatedButton.styleFrom(primary: ColorsCTRM.primaryColor),
                onPressed: () {
                  Navigator.of(context).pop();
                  _loginDataStore.setOfflineMessage(false);
                  _showRoute();
                },
              ),
            )
          ],
        );
      },
    );
  }

  _showUserRoute() async{
    var conn = await ConnectionChecker.checkConnection();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    if (conn) {
      DadosAbertosAPI(_loginDataStore, _helper).getUserRoute(position, _loginDataStore.selectedImovelDadosAbertos.idSistema!).then((route) {
        _showRoute(route: route);
      }).onError((error, stackTrace){
        print("ERRO $error -> $stackTrace");
        _showErrorDialog();
      });
    } else {
      _showRoute();
    }
  }

  _onMapCreated(GoogleMapController controller) async {

    setState(() {
      controller.setMapStyle(_mapStyle);
      _controller.complete(controller);
      print("Map Ready $_initialPosition");

    });

    if(_loginDataStore.showOfflineMessage){
      _showOfflineMessage();
    } else{
      if(userRoute == null ){
        _showErrorDialog();
      } else{
        _showRoute(route: userRoute);
      }
    }
  }

  _showSelectedRoute() {
    if(userRoute == null ){
      _showRoute();
    } else{
      _showRoute(route: userRoute);
    }
  }

  Future<void> _showRoute({String? route}) async {
    _clearMapSet();
    _loginDataStore.setRouteDone(false);
    _loginDataStore.clearButtons();
    //_loginDataStore.clearLatLngRoute();
    String geometryRoute = "";

    LatLng markerPositionSede;
    Marker marker2;
    MarkerId markerId2;
    BitmapDescriptor pin2;

    if (route == null) {
      geometryRoute = _loginDataStore.selectedImovelDadosAbertos.geomRota!.replaceAll('type', '"type"').replaceAll('coordinates', '"coordinates"').replaceAll(
          'MultiLineString',
          '"MultiLineStr'
              'ing"');
      markerPositionSede = new LatLng(_loginDataStore.selectedImovelDadosAbertos.coordenadas_sede.longitude, _loginDataStore.selectedImovelDadosAbertos.coordenadas_sede.latitude);
      markerId2 = MarkerId("sede");
      pin2 = await bitmapDescriptorFromSvgAsset(context, 'assets/images/icons/city-hall.svg');
      marker2 = Marker(
        markerId: markerId2,
        position: markerPositionSede,
        infoWindow: InfoWindow(title: 'Origem: ${_loginDataStore.m.municipio_plus_uf()}'),
        icon: pin2,
        onTap: () {
          print("TAPPED -> ${_loginDataStore.selectedImovelDadosAbertos.toString()}");
        },
      );
      setState(() {
        _markerSet.add(marker2);
      });
    } else {
      geometryRoute = route.replaceAll('type', '"type"').replaceAll('coordinates', '"coordinates"').replaceAll(
          'MultiLineString',
          '"MultiLineStr'
              'ing"');
    }

    final multiLineFromJson = GeoJSONMultiLineString.fromJSON(geometryRoute);
    final MarkerId markerId = MarkerId("imovel");

    final LatLng markerPositionImovel = new LatLng(_loginDataStore.selectedImovelDadosAbertos.coordenadas_imovel.longitude, _loginDataStore.selectedImovelDadosAbertos.coordenadas_imovel.latitude);
    BitmapDescriptor pin = await bitmapDescriptorFromSvgAsset(context, 'assets/images/icons/home-location.svg');

    final Marker marker = Marker(
      markerId: markerId,
      position: markerPositionImovel,
      infoWindow: InfoWindow(title: 'Destino: ${_loginDataStore.selectedImovelDadosAbertos.nome_imovel}'),
      icon: pin,
      onTap: () {
        print("TAPPED -> ${_loginDataStore.selectedImovelDadosAbertos.toString()}");
      },
    );

    for (int i = 0; i < multiLineFromJson.coordinates.length; i++) {
      List<LatLng> routeCoords = [];
      for (int j = 0; j < multiLineFromJson.coordinates[i].length; j++) {
        LatLng coordPoint = new LatLng(multiLineFromJson.coordinates[i][j][1], multiLineFromJson.coordinates[i][j][0]);

        LatLng2.LatLng point = new LatLng2.LatLng(multiLineFromJson.coordinates[i][j][1], multiLineFromJson.coordinates[i][j][0]);
        _loginDataStore.addLatLngRoute(point);

        //toolKit.LatLng tK = new toolKit.LatLng(multiLineFromJson.coordinates[i][j][1], multiLineFromJson.coordinates[i][j][0]);
        //_loginDataStore.addLatLngRoute(tK);

        routeCoords.add(coordPoint);
      }

      print("Coord $i $routeCoords");

      Polyline p = new Polyline(polylineId: PolylineId("route$i"), visible: true, points: routeCoords, width: 4, color: Colors.blue, startCap: Cap.roundCap, endCap: Cap.buttCap);

      _polylineSet.add(p);
    }

    _loginDataStore.routePath.addAll(_loginDataStore.routeLatLngList);

    for (Polyline p in _polylineSet) {
      print("POINT -> ${p.polylineId.value} ${p.points}");
    }

    final GoogleMapController controller = await _controller.future;
    setState(() {
      MapUtils.setMapFitToTour(_polylineSet, controller);
      print("ADD MARKING IMOVEL ROUTE $marker");
      _markerSet.add(marker);
      _showPolygon(false);
    });

    _loginDataStore.setRouteDone(true);
    _loginDataStore.setButtonIniciarNavegacaoVisibility(true);
  }

  /// NAVIGATION FUNCTIONS

  void the_timerWithCompass() {
    if (!_stopLoop) {
      Timer(Duration(milliseconds: 1000), () {
        print("TIMER ON -->");
        _getNavigationLocation(true);
      });
    } else {
      _loginDataStore.setNavigationHeading(0);
      print("TIMER OFF");
    }
  }

  void the_timerWithoutCompass() {
    if (!_stopLoop) {
      Timer(Duration(milliseconds: 1000), () {
        print("TIMER ON -->");
        _getNavigationLocation(false);
      });
    } else {
      _loginDataStore.setNavigationHeading(0);
      print("TIMER OFF");
    }
  }

  Future<void> startNavigation() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(
              "ATENÇÃO: a navegação do app foi otimizada para ambiente rural, enquanto estiver em ambiente urbano, atente-se para as regras de trânsito das vias",
              style: FontsStyleCTRM.primaryFont20Dark,
            ),
            content: Text(""),
            actions: <Widget>[
              // define os botões na base do dialogo
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: ElevatedButton(
                  child: Text(
                    "CONTINUAR",
                    style: FontsStyleCTRM.primaryFontWhite,
                  ),
                  style: ElevatedButton.styleFrom(primary: ColorsCTRM.primaryColor),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _stopLoop = false;
                    timerBeforeNavigationStart();
                  },
                ),
              ),
            ],
          );
        });
  }

  void stopNavigation() {
    _getUserLocation(false, false);

    _loginDataStore.setButtonIniciarNavegacaoText("INICIAR NAVEGAÇÃO");
    _stopLoop = true;
    _loginDataStore.setNavigationHeading(0);
  }

  void timerBeforeNavigationStart() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    final GoogleMapController controller = await _controller.future;

    try {
      final CompassEvent tmp = await FlutterCompass.events!.first;
      if (tmp.heading == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text(
                "Seu dispositivo não suporta essa função.",
                style: FontsStyleCTRM.primaryFont20Dark,
              ),
              content: Text(""),
              actions: <Widget>[
                // define os botões na base do dialogo
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: ElevatedButton(
                    child: Text(
                      "FECHAR",
                      style: FontsStyleCTRM.primaryFontWhite,
                    ),
                    style: ElevatedButton.styleFrom(primary: ColorsCTRM.primaryColor),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                )
              ],
            );
          },
        );
        _getUserLocation(true, false);

        _loginDataStore.setButtonIniciarNavegacaoText("INICIAR NAVEGAÇÃO");
        _stopLoop = true;
        _loginDataStore.setNavigationHeading(0);
      } else {
        _loginDataStore.setNavigationHeading(tmp.heading!);
        controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 18.5, bearing: _loginDataStore.navigationHeading, tilt: 90)));

        Timer(Duration(milliseconds: 1000), () {
          print("TIMER ON -->");
          _loginDataStore.setButtonIniciarNavegacaoText("PARAR NAVEGAÇÃO");
          _getNavigationLocation(true);
        });
      }
    } catch (e) {
      print("CATHED $e");

      _loginDataStore.setNavigationHeading(0);

      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 18.5, bearing: position.heading)));

      Timer(Duration(milliseconds: 1000), () {
        print("TIMER ON -->");
        _loginDataStore.setButtonIniciarNavegacaoText("PARAR NAVEGAÇÃO 2");
        _getNavigationLocation(false);
      });
    }
  }

  _getNavigationLocation(bool compass) async {
    print("GET USER LOCATION");

    if (!_stopLoop) {
      if (compass) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
        _loginDataStore.setUserPosition(position);

        //List<toolKit.LatLng> list = _loginDataStore.routeLatLngList;
        //bool isLocationOnRoute = toolKit.PolygonUtil.isLocationOnPath(toolKit.LatLng(position.latitude, position.longitude), list, true, tolerance: 0.5);
        //print("LOCATION NEAR ROUTE? $isLocationOnRoute");

        final GoogleMapController controller = await _controller.future;
        double headingaccurate;
        print("OLD HEADING -> ${_loginDataStore.oldUserPosition!.heading} /// NEW HEADING -> ${_loginDataStore.userPosition!.heading}");
        print("FIXED HEADING: ${_loginDataStore.navigationHeading}");

        final CompassEvent tmp = await FlutterCompass.events!.first;
        print("TMP  HEADING: ${tmp.heading}");

        if (_loginDataStore.navigationHeading == 0.0) {
          print("~IF");
          headingaccurate = (_loginDataStore.oldUserPosition!.heading - _loginDataStore.userPosition!.heading).abs();
        } else {
          print("~ELSE");
          headingaccurate = (_loginDataStore.navigationHeading - _loginDataStore.userPosition!.heading).abs();
        }

        print("HEADING ACCURACY: $headingaccurate");

        _loginDataStore.setNavigationHeading(tmp.heading!);
        controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 18.5, bearing: _loginDataStore.navigationHeading, tilt: 90)));

        the_timerWithCompass();
      } else {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
        _loginDataStore.setUserPosition(position);

        // List<toolKit.LatLng> list = _loginDataStore.routeLatLngList;
        // bool isLocationOnRoute = toolKit.PolygonUtil.isLocationOnPath(toolKit.LatLng(position.latitude, position.longitude), list, true, tolerance: 0.5);
        // print("LOCATION NEAR ROUTE? $isLocationOnRoute");
        List<LatLng2WithDistance> distancesList = [];
        for (int i = 0; i < _loginDataStore.routeLatLngList.length; i++) {
          LatLng2.Distance d = new LatLng2.Distance();
          double distance = d.as(LatLng2.LengthUnit.Meter, new LatLng2.LatLng(position.latitude, position.longitude), _loginDataStore.routeLatLngList[i]);
          print("DISTANCE $i --> $distance");
          LatLng2WithDistance latLng2WithDistance = new LatLng2WithDistance(_loginDataStore.routeLatLngList[i].latitude, _loginDataStore.routeLatLngList[i].longitude);
          latLng2WithDistance.distance = distance;
          distancesList.add(latLng2WithDistance);
        }
        distancesList.sort((a, b) => a.distance.compareTo(b.distance));
        print("LISTA -> $distancesList");

        if (distancesList.first.distance < 20) {
          print("TRUE");
        }

        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 18.5, bearing: position.heading, tilt: 90)));

        the_timerWithoutCompass();
      }
    }
  }

  void _exitNavigation() {
    print("SAINDO DA NAVEGACÃO");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Deseja sair da navegação e voltar ao mapa?",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Text(""),
          actions: <Widget>[
            // define os botões na base do dialogo
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                child: Text(
                  "NÃO",
                  style: FontsStyleCTRM.primaryFontWhite,
                ),
                style: ElevatedButton.styleFrom(primary: ColorsCTRM.primaryColorComplementary),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                child: Text(
                  "SIM",
                  style: FontsStyleCTRM.primaryFontWhite,
                ),
                style: ElevatedButton.styleFrom(primary: ColorsCTRM.primaryColor),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _polylineSet.clear();
                    _markerSet.clear();
                  });
                  _loginDataStore.setButtonIniciarNavegacaoVisibility(false);
                  _getUserLocation(false, false);
                },
              ),
            )
          ],
        );
      },
    );
  }

  Future<void> _showPolygon(bool fit) async {
    _loginDataStore.clearImovelGeoPointList();

    String geometryPolygon = _loginDataStore.selectedImovelDadosAbertos.geomMultipolygon!.replaceAll('type', '"type"').replaceAll('coordinates', '"coordinates"').replaceAll('MultiPolygon', '"MultiPolygon"');
    final multiPolygonFromJson = GeoJSONMultiPolygon.fromJSON(geometryPolygon);

    for (int i = 0; i < multiPolygonFromJson.coordinates.length; i++) {
      for (int j = 0; j < multiPolygonFromJson.coordinates[i].length; j++) {
        List<LatLngWithAngle> pointsCoords = [];
        for (int k = 0; k < multiPolygonFromJson.coordinates[i][j].length; k++) {
          LatLngWithAngle coordPoint = new LatLngWithAngle(multiPolygonFromJson.coordinates[i][j][k][1], multiPolygonFromJson.coordinates[i][j][k][0]);
          pointsCoords.add(coordPoint);
        }
        final PolygonId polygonId = PolygonId("imovel-${_loginDataStore.selectedImovelDadosAbertos.idSistema}-$i-$j");
        final Polygon polygon = Polygon(
          polygonId: polygonId,
          points: pointsCoords,
          strokeWidth: 2,
          strokeColor: ColorsCTRM.primaryColor,
          fillColor: ColorsCTRM.primaryColor.withOpacity(0.01),
        );
        setState(() {
          _polygonSet.add(polygon);
        });
      }
    }

    if (fit) {
      final GoogleMapController controller = await _controller.future;
      List<LatLngWithAngle> p = [];

      _polygonSet.forEach((element) {
        element.points.forEach((point) {
          LatLngWithAngle l = LatLngWithAngle(point.latitude, point.longitude);
          print("POINT $l");
          p.add(l);
        });
      });

      setState(() {
        MapUtils.setMapPolygonFitToTour(p, controller);
      });
    }
  }

  _message() {
    print("${_loginDataStore.selectedImovelDadosAbertos.nome_imovel!.length} Caracteres -> ${_loginDataStore.selectedImovelDadosAbertos.nome_imovel}");
    if (_loginDataStore.selectedImovelDadosAbertos.nome_imovel!.length > 66) {
      showTopSnackBar(
        context,
        CustomSnackBar.success(
          backgroundColor: ColorsCTRM.primaryColor,
          icon: Container(),
          message: "${_loginDataStore.selectedImovelDadosAbertos.nome_imovel}",
          textStyle: FontsStyleCTRM.primaryFont16WhiteHeight,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: ColorsCTRM.primaryColor,
              appBar: AppBar(
                flexibleSpace: GestureDetector(
                  onTap: _message,
                ),
                actions: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Container(),
                  )
                ],
                title: GestureDetector(
                  onTap: _message,
                  child: Padding(
                    padding: _loginDataStore.isButtonIniciarNavegacaoVisible
                        ? _loginDataStore.isNavigationStarted
                            ? EdgeInsets.only(bottom: 8)
                            : _loginDataStore.isNavigationStartedWithoutCompass
                                ? EdgeInsets.only(bottom: 8)
                                : EdgeInsets.only(bottom: 8, right: 38)
                        : EdgeInsets.only(bottom: 8),
                    child: Flex(direction: Axis.horizontal, children: [
                      Flexible(
                        child: RichText(
                          maxLines: 3,
                          text: TextSpan(
                            text: _loginDataStore.selectedImovelDadosAbertos.nome_imovel!,
                            style: FontsStyleCTRM.primaryFont16WhiteHeight,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
                centerTitle: true,
                backgroundColor: Theme.of(context).primaryColor,
              ),
              floatingActionButton: Padding(
                padding: EdgeInsets.only(right: 5.0, bottom: 24.0),
                child: SpeedDial(
                  animatedIcon: AnimatedIcons.menu_arrow,
                  animatedIconTheme: IconThemeData(color: Colors.white, size: 30),
                  backgroundColor: ColorsCTRM.primaryColor,
                  children: [
                    SpeedDialChild(
                      child: Icon(
                        Icons.linear_scale_outlined,
                        color: Colors.white,
                      ),
                      backgroundColor: ColorsCTRM.primaryColor,
                      label: "Visualizar Rota Selecionada",
                      onTap: _showSelectedRoute,
                    ),
                    SpeedDialChild(
                      child: Icon(
                        Icons.house_outlined,
                        color: Colors.white,
                      ),
                      backgroundColor: ColorsCTRM.primaryColor,
                      label: "Visualizar Imóvel",
                      onTap: () {
                        _showPolygon(true);
                      },
                    )
                  ],
                ),
              ),
              body: Padding(
                padding: EdgeInsets.only(right: 5.0, left: 5.0, bottom: 0.0, top: 5.0),
                child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 17),
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    tiltGesturesEnabled: false,
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: true,
                    markers: _markerSet,
                    onCameraMove: (newPosition) {
                      _mapIdleSubscription?.cancel();
                      _mapIdleSubscription = Future.delayed(Duration(milliseconds: 150)).asStream().listen((_) {
                        if (_infoWidgetRoute != null) {
                          Navigator.of(context, rootNavigator: true).push(_infoWidgetRoute!).then<void>(
                            (newValue) {
                              _infoWidgetRoute = null;
                            },
                          );
                        }
                      });
                    },
                    // YOUR MARKS IN MAP
                    polygons: _polygonSet,
                    polylines: _polylineSet,
                    onTap: (point) {}),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                height: 33,
                width: MediaQuery.of(context).size.width,
                color: ColorsCTRM.primaryColorDark,
                child: Container(),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 40,
              child: FloatingActionButton(
                heroTag: "btn1",
                child: Icon(Icons.location_searching),
                backgroundColor: ColorsCTRM.primaryColor,
                onPressed: () {
                  _getUserLocation(false, false);
                },
              ),
            ),
            Observer(builder: (_) {
              return _loginDataStore.isNavigationStarted
                  ? Container(
                      color: Colors.white24,
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(up_arrow_1, height: 45),
                            ],
                          ),
                        ),
                      ),
                    )
                  : _loginDataStore.isNavigationStartedWithoutCompass
                      ? Container(
                          color: Colors.white24,
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 100.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(up_arrow_1, height: 45),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container();
            }),
            Observer(builder: (_) {
              return _loginDataStore.isButtonIniciarNavegacaoVisible
                  ? Container(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: 50.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints.tightFor(height: 50),
                              child: _loginDataStore.isNavigationStarted
                                  ? ElevatedButton(
                                      child: Text(
                                        "PARAR NAVEGACÃO",
                                        style: FontsStyleCTRM.primaryFontWhite,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        primary: ColorsCTRM.primaryColorTetraticRed,
                                        elevation: 6,
                                        shadowColor: ColorsCTRM.primaryColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                      ),
                                      onPressed: stopNavigation,
                                    )
                                  : _loginDataStore.isNavigationStartedWithoutCompass
                                      ? ElevatedButton(
                                          child: Text(
                                            "PARAR NAVEGACÃO",
                                            style: FontsStyleCTRM.primaryFontWhite,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            primary: ColorsCTRM.primaryColorTetraticRed,
                                            elevation: 6,
                                            shadowColor: ColorsCTRM.primaryColor,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                          ),
                                          onPressed: stopNavigation,
                                        )
                                      : ElevatedButton(
                                          child: Text(
                                            "INICIAR NAVEGACÃO",
                                            style: FontsStyleCTRM.primaryFontWhite,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            primary: ColorsCTRM.primaryColorTetraticGreen,
                                            elevation: 6,
                                            shadowColor: ColorsCTRM.primaryColor,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                          ),
                                          onPressed: startNavigation,
                                        ),
                            )),
                      ),
                    )
                  : Container();
            }),
          ],
        ),
        onWillPop: _onBackPressed);
  }

  Future<bool> _onBackPressed() async {
    Navigator.of(context).pop(true);
    _loginDataStore.setMarkersVisibility(false);
    _loginDataStore.setAllSincronized(false);
    _loginDataStore.setImoveisListStartPosition(true);
    return true;
  }

  void _clearMapSet() {
    _polygonSet.clear();
    _markerSet.clear();
    _polylineSet.clear();
  }
}
