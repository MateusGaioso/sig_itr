import 'dart:async';
import 'dart:io';

import 'package:app_itr/api/sync_points_api.dart';
import 'package:app_itr/etc/ConnectionChecker.dart';
import 'package:app_itr/etc/MapUtils.dart';
import 'package:app_itr/etc/PolygonGenerator.dart';
import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/etc/custom_icons_icons.dart';
import 'package:app_itr/helpers/classes/EstradaPoint.dart';
import 'package:app_itr/helpers/classes/ImovelGeoPoint.dart';
import 'package:app_itr/helpers/classes/Levantamento.dart';
import 'package:app_itr/helpers/classes/PontePoint.dart';
import 'package:app_itr/helpers/classes/RotaEscolarPoint.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:app_itr/ui/AddPointPage.dart';
import 'package:app_itr/ui/PonteCameraPickerPage.dart';
import 'package:app_itr/ui/PonteInfoEditPage.dart';
import 'package:app_itr/ui/RotaEscolarInfoEditPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:wakelock/wakelock.dart';

//import 'package:maps_toolkit/maps_toolkit.dart' as toolKit;
import 'package:latlong2/latlong.dart' as LatLng2;

import 'EstradaInfoEditPage.dart';
import 'LevantamentosPage.dart';
import 'PontoImovelInfoEditPage.dart';
import 'RouteListPage.dart';
import 'ViewMap.dart';
import 'ui_functions/MainPageFunctions.dart';

String titleAppBar = "ITR - ";

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  late LoginDataStore _loginDataStore;
  DBHelper _helper = DBHelper();

  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation _animation;
  FocusNode _focusNode = FocusNode();
  Completer<GoogleMapController> _controller = Completer();

  late String _mapStyle;
  late LatLng _initialPosition;

  final Set<Polyline> _polylineSet = {};
  final Set<Marker> _markerSet = {};
  final Set<Polygon> _polygonSet = {};

  bool _stopLoop = false;
  bool _stopLoopEstrada = false;
  bool _stopLoopRotaEscolar = false;
  bool _stopLoopImovel = false;
  bool _stopLoopPonte = false;

  int _loopTimer = 3;

  TextEditingController timerEstradaController = TextEditingController();
  TextEditingController timerRotaController = TextEditingController();

  StreamSubscription? _mapIdleSubscription;
  InfoWidgetRoute? _infoWidgetRoute;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(vsync: this, duration: kThemeAnimationDuration, value: 1);
    _animation = Tween(begin: 300.0, end: 50.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
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
    _getUserLocation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _focusNode.dispose();

    _loginDataStore.fullDataClear();

    _stopLoop = true;
    _stopLoopEstrada = true;
    _stopLoopImovel = true;
    _stopLoopRotaEscolar = true;
    _stopLoopPonte = true;

    Wakelock.disable();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginDataStore = Provider.of<LoginDataStore>(context);
    _initialPosition = LatLng(double.parse(_loginDataStore.m.latitude!), double.parse(_loginDataStore.m.longitude!));
    print("height status bar:^${_loginDataStore.statusBarHeight}");
  }

  _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 17.5)));
    _loginDataStore.setUserPosition(position);
    setState(() {
      _polylineSet.clear();
      _polygonSet.clear();
      _markerSet.clear();
    });
  }

  _onMapCreated(GoogleMapController controller) {
    setState(() {
      controller.setMapStyle(_mapStyle);
      _controller.complete(controller);
      print("Map Ready $_initialPosition");
    });
  }

  Future<void> _showRoute() async {
    _polylineSet.clear();
    _loginDataStore.setRouteDone(false);
    _loginDataStore.clearButtons();
    //_loginDataStore.clearLatLngRoute();

    String geometryRoute = _loginDataStore.selectedImovelRoute.geometry!.replaceAll('type', '"type"').replaceAll('coordinates', '"coordinates"').replaceAll('MultiLineString', '"MultiLineString"');
    final multiLineFromJson = GeoJSONMultiLineString.fromJSON(geometryRoute);
    final MarkerId markerId = MarkerId("imovel");
    final MarkerId markerId2 = MarkerId("sede");
    final LatLng markerPositionImovel = new LatLng(_loginDataStore.selectedImovelRoute.coordenadas_imovel.longitude, _loginDataStore.selectedImovelRoute.coordenadas_imovel.latitude);
    final LatLng markerPositionSede = new LatLng(_loginDataStore.selectedImovelRoute.coordenadas_sede.longitude, _loginDataStore.selectedImovelRoute.coordenadas_sede.latitude);
    BitmapDescriptor pin = await bitmapDescriptorFromSvgAsset(context, 'assets/images/icons/home-location.svg');
    BitmapDescriptor pin2 = await bitmapDescriptorFromSvgAsset(context, 'assets/images/icons/city-hall.svg');

    final Marker marker = Marker(
      markerId: markerId,
      position: markerPositionImovel,
      infoWindow: InfoWindow(title: 'Destino: ${_loginDataStore.selectedImovelRoute.nome_imovel}'),
      icon: pin,
      onTap: () {
        print("TAPPED -> ${_loginDataStore.selectedImovelRoute.toString()}");
      },
    );

    final Marker marker2 = Marker(
      markerId: markerId2,
      position: markerPositionSede,
      infoWindow: InfoWindow(title: 'Origem: ${_loginDataStore.m.municipio_plus_uf()}'),
      icon: pin2,
      onTap: () {
        print("TAPPED -> ${_loginDataStore.selectedImovelRoute.toString()}");
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
    });

    setState(() {
      print("ADD MARKING IMOVEL ROUTE $marker");
      _markerSet.add(marker);
      _markerSet.add(marker2);
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
    _getUserLocation();

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
        _getUserLocation();

        _loginDataStore.setButtonIniciarNavegacaoText("INICIAR NAVEGAÇÃO");
        _stopLoop = true;
        _loginDataStore.setNavigationHeading(0);
      } else {
        _loginDataStore.setNavigationHeading(tmp.heading!);
        controller
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 18.5, bearing: _loginDataStore.navigationHeading, tilt: 90)));

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
        controller
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 18.5, bearing: _loginDataStore.navigationHeading, tilt: 90)));

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
                  _getUserLocation();
                },
              ),
            )
          ],
        );
      },
    );
  }

  /// ESTRADA CAPTURE FUNCTIONS

  void _exitCapture() {
    print("SAINDO DA CAPTURA");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Deseja sair da captura? A rota será cancelada e excluída.",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Text(""),
          actions: <Widget>[
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
                  });
                  _loginDataStore.setEstradaStart(false);
                  _helper.deleteAllPointsFromLevantamento(_loginDataStore);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _finalizeCapture() {
    FocusScope.of(context).unfocus();
    timerEstradaController.clear();

    print("FINALIZANDO CAPTURA");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Deseja finalizar e salvar a captura da estrada?",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Text(""),
          actions: <Widget>[
            // define os botões na base do dialogo
            new TextButton(
              child: new Text(
                "NÃO",
                style: FontsStyleCTRM.primaryFont20Dark,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text(
                "SIM",
                style: FontsStyleCTRM.primaryFont20Dark,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                _loginDataStore.setEstradaStart(false);
                _loginDataStore.clearEstradaData();
                Levantamento l = _loginDataStore.selectedLevantamento;
                l.status = "finalizado";
                print("selected -> $l");
                _loginDataStore.setSelectedLevantamento(l);
                var updated = await _helper.updateLevantamento(l);
                print(updated);

                _showGeneratedEstrada(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _startEstradaCapture() async {
    print(_loginDataStore.estradaPointTimer);
    print(_loginDataStore.estradaEstadoDeConservacao);
    print("INICIAR CAPTURA");

    _loginDataStore.setButtonIniciarCapturaEstrada("PAUSAR CAPTURA DA ESTRADA");
    _stopLoopEstrada = false;
    timer_estrada();
  }

  Future<void> _pauseEstradaCapture() async {
    print("PAUSAR CAPTURA");
    _loginDataStore.setButtonIniciarCapturaEstrada("INICIAR CAPTURA DA ESTRADA");
    _stopLoopEstrada = true;
  }

  Future<void> timer_estrada() async {
    //_loopTimer = int.parse(_loginDataStore.estradaPointTimer);
    _loopTimer = 3;

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 18.5,
    )));

    _loginDataStore.setUserPosition(position);
    if (!_stopLoopEstrada) {
      Timer(Duration(seconds: _loopTimer), () {
        print("TIMER ON -->");
        _saveEstradaPoint();
      });
    } else {
      _loginDataStore.setNavigationHeading(0);
      print("TIMER OFF");
    }
  }

  _saveEstradaPoint() async {
    print("GET USER LOCATION");

    if (!_stopLoopEstrada) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
      _loginDataStore.setUserPosition(position);

      final GoogleMapController controller = await _controller.future;

      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 18.5,
      )));

      EstradaPoint? estradaPoint = new EstradaPoint();
      estradaPoint.sincronizado = 0;
      estradaPoint.rodovia = _loginDataStore.estradaRodovia;
      estradaPoint.trecho = _loginDataStore.estradaTrecho;
      estradaPoint.jurisdicao = _loginDataStore.estradaJurisdicao;
      estradaPoint.estado_conservacao = _loginDataStore.estradaEstadoDeConservacao;
      estradaPoint.tipo_pavimentacao = _loginDataStore.estradaTipoDePavimentacao;
      estradaPoint.largura_aproximada = _loginDataStore.estradaLarguraAproximada.replaceAll(",", '.');
      estradaPoint.cod_ibge_m = _loginDataStore.m.cod_ibge_m;
      estradaPoint.idLevantamento = _loginDataStore.selectedLevantamento.id;
      estradaPoint.geom = LatLngWithAngle(position.latitude, position.longitude);

      _helper.saveEstradaPoint(estradaPoint);

      _showGeneratedEstrada(false);

      timer_estrada();
    } else {
      print("STOPPED TIMER");
    }
  }

  /// ROTA ESCOLAR CAPTURE

  void _exitCaptureRotaEscolar() {
    print("SAINDO DA CAPTURA");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Deseja sair da captura? A rota será cancelada e excluída.",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Text(""),
          actions: <Widget>[
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
                  });
                  _loginDataStore.setRotaEscolarStart(false);
                  _helper.deleteAllRotaPointsFromLevantamento(_loginDataStore);
                },
              ),
            )
            // define os botões na base do dialogo
          ],
        );
      },
    );
  }

  void _finalizeCaptureRotaEscolar() {
    FocusScope.of(context).unfocus();

    print("FINALIZANDO CAPTURA");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Deseja finalizar e salvar a captura da rota escolar?",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Text(""),
          actions: <Widget>[
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
                onPressed: () async {
                  Navigator.of(context).pop();
                  _loginDataStore.setRotaEscolarStart(false);
                  _loginDataStore.clearRotaEscolarData();
                  Levantamento l = _loginDataStore.selectedLevantamento;
                  l.status = "finalizado";
                  print("selected -> $l");
                  _loginDataStore.setSelectedLevantamento(l);
                  var updated = await _helper.updateLevantamento(l);
                  print(updated);
                  _showGeneratedRotaEscolar(true);
                },
              ),
            )
            // define os botões na base do dialogo
          ],
        );
      },
    );
  }

  Future<void> _startRotaEscolarCapture() async {
    print(_loginDataStore.rotaEscolarPointTimer);
    print(_loginDataStore.rotaEscolarEstadoDeConservacao);
    print("INICIAR CAPTURA ROTA ESCOLAR");

    _loginDataStore.setButtonIniciarCapturaRotaEscolar("PAUSAR CAPTURA DA ROTA ESCOLAR");
    _stopLoopRotaEscolar = false;
    timer_rotaEscolar();
  }

  Future<void> _pauseRotaEscolarCapture() async {
    print("PAUSAR CAPTURA");
    _loginDataStore.setButtonIniciarCapturaRotaEscolar("INICIAR CAPTURA DA ROTA ESCOLAR");
    _stopLoopRotaEscolar = true;
  }

  Future<void> timer_rotaEscolar() async {
    //int loopTimer = int.parse(_loginDataStore.rotaEscolarPointTimer);
    _loopTimer = 3;
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 18.5,
    )));

    _loginDataStore.setUserPosition(position);
    if (!_stopLoopRotaEscolar) {
      Timer(Duration(seconds: _loopTimer), () {
        print("TIMER ON -->");
        _saveRotaEscolarPoint();
      });
    } else {
      _loginDataStore.setNavigationHeading(0);
      print("TIMER OFF");
    }
  }

  _saveRotaEscolarPoint() async {
    print("GET USER LOCATION");

    if (!_stopLoopRotaEscolar) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
      _loginDataStore.setUserPosition(position);

      final GoogleMapController controller = await _controller.future;

      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 18.5,
      )));

      RotaEscolarPoint? rotaEscolarPoint = new RotaEscolarPoint();
      rotaEscolarPoint.sincronizado = 0;
      rotaEscolarPoint.rodovia = _loginDataStore.rotaEscolarRodovia;
      rotaEscolarPoint.trecho = _loginDataStore.rotaEscolarTrecho;
      rotaEscolarPoint.jurisdicao = _loginDataStore.rotaEscolarJurisdicao;
      rotaEscolarPoint.estado_conservacao = _loginDataStore.rotaEscolarEstadoDeConservacao;
      rotaEscolarPoint.tipo_pavimentacao = _loginDataStore.rotaEscolarTipoDePavimentacao;
      rotaEscolarPoint.largura_aproximada = _loginDataStore.rotaEscolarLarguraAproximada.replaceAll(",", '.');
      rotaEscolarPoint.cod_ibge_m = _loginDataStore.m.cod_ibge_m;
      rotaEscolarPoint.idLevantamento = _loginDataStore.selectedLevantamento.id;
      rotaEscolarPoint.geom = LatLngWithAngle(position.latitude, position.longitude);

      _helper.saveRotaEscolar(rotaEscolarPoint);

      _showGeneratedRotaEscolar(false);

      timer_rotaEscolar();
    } else {
      print("STOPPED TIMER");
    }
  }

  /// IMOVEL CAPTURE

  Future<void> _startImovelCapture() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Selecione o tipo de ponto",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Container(
            decoration: BoxDecoration(
              color: ColorsCTRM.primaryColorAlphaAA,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(16.0),
                bottomLeft: Radius.circular(16.0),
                topLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
            ),
            height: 100,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _toSedePage,
                        child: Container(
                          height: 70,
                          child: Center(
                            child: SvgPicture.asset(farm_house, height: 45),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _toVerticePage,
                        child: Container(
                          height: 70,
                          color: ColorsCTRM.primaryColorDarkAlpha66,
                          child: Center(
                            child: SvgPicture.asset(corner, height: 45),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _toAcessoPrincipalPage,
                        child: Container(
                          height: 70,
                          child: Center(
                            child: SvgPicture.asset(
                              ranch_gate,
                              height: 55,
                              color: Color(0xFF664426),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _toSedePage,
                        child: Container(
                          height: 30,
                          child: Center(child: Text("SEDE", style: FontsStyleCTRM.primaryFontMiniWhite)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _toVerticePage,
                        child: Container(
                          height: 30,
                          color: ColorsCTRM.primaryColorDarkAlpha66,
                          child: Center(child: Text("VÉRTICE", style: FontsStyleCTRM.primaryFontMiniWhite)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _toAcessoPrincipalPage,
                        child: Container(
                          height: 30,
                          child: Column(
                            children: [
                              Center(child: Text("ACESSO", style: FontsStyleCTRM.primaryFontMiniWhite)),
                              Center(child: Text("PRINCIPAL", style: FontsStyleCTRM.primaryFontMiniWhite)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: <Widget>[
            // define os botões na base do dialogo
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                child: Text(
                  "VOLTAR",
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
  }

  Future<void> _startImovelCaptureTimer() async {
    print("INICIANDO CAPTURA DO IMOVEL");

    _loginDataStore.setButtonIniciarCapturaImovel("PAUSAR CAPTURA DO PONTO");
    _stopLoopImovel = false;

    _loginDataStore.setColorStateValue(0);
    _loginDataStore.setCollected(false);

    the_timer();
  }

  Future<void> _cancelImovelCapture() async {
    print("CANCELAR CAPTURA");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Deseja cancelar esta captura do ponto?",
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
                  _loginDataStore.setButtonIniciarCapturaImovel("INICIAR CAPTURA DO PONTO");
                  _stopLoopImovel = true;
                },
              ),
            )
          ],
        );
      },
    );
  }

  Future<void> timer_imovel() async {
    //int loopTimer = int.parse(_loginDataStore.rotaEscolarPointTimer);

    print("THE COLOR STAT -> ${_loginDataStore.colorStateValue}");

    if (_loginDataStore.colorStateValue == 2) {
      print("END OF TIMER");
      _stopLoopImovel = true;
      _endOfTimerImovel();
    } else {
      print("START TIMER");
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _loginDataStore.setUserPosition(position);

      double distanceInMeters = Geolocator.distanceBetween(
          _loginDataStore.userPosition!.latitude, _loginDataStore.userPosition!.longitude, _loginDataStore.oldUserPosition!.latitude, _loginDataStore.oldUserPosition!.longitude);

      print("DISTANCE -> $distanceInMeters");

      if (distanceInMeters >= 3) {
        _loginDataStore.setColorStateValue(0);
      } else {
        if (_loginDataStore.colorStateValue == 1) {
          _loginDataStore.setColorStateValue(2);
        } else if (_loginDataStore.colorStateValue == 0) {
          _loginDataStore.setColorStateValue(1);
        }
      }

      the_timer();

      _loginDataStore.setUserPosition(position);
    }
  }

  void the_timer() {
    if (!_stopLoopImovel) {
      Timer(Duration(seconds: 5), () {
        print("TIMER ON");
        timer_imovel();
      });
    } else {
      print("TIMER OFF");
    }
  }

  void _endOfTimerImovel() {
    _loginDataStore.setButtonIniciarCapturaImovel("INICIAR CAPTURA DO PONTO");

    ImovelGeoPoint imovelGeoPoint = ImovelGeoPoint();
    imovelGeoPoint.tipo = _loginDataStore.imovelGeoPointTipo;
    imovelGeoPoint.cod_ibge_m = _loginDataStore.m.cod_ibge_m;
    imovelGeoPoint.descricao = _loginDataStore.imovelGeoPointDescricao;
    imovelGeoPoint.sincronizado = 0;
    imovelGeoPoint.geom = LatLngWithAngle(_loginDataStore.userPosition!.latitude, _loginDataStore.userPosition!.longitude);
    imovelGeoPoint.idLevantamento = _loginDataStore.selectedLevantamento.id;

    _helper.saveGeoPoint(imovelGeoPoint);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Captura realizada com sucesso!",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Text(""),
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
                },
              ),
            )
          ],
        );
      },
    );
  }

  void _finalizeCaptureImovel() {
    FocusScope.of(context).unfocus();

    print("FINALIZANDO CAPTURA IMOVEL");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Deseja finalizar e salvar a captura do imovel? Essa operação irá finalizar este levantamento.",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Text(""),
          actions: <Widget>[
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
                onPressed: () async {
                  Navigator.of(context).pop();
                  _loginDataStore.setImovelStart(false);
                  _loginDataStore.clearImovelGeoPointsData();
                  Levantamento l = _loginDataStore.selectedLevantamento;
                  l.status = "finalizado";
                  print("selected -> $l");
                  _loginDataStore.setSelectedLevantamento(l);
                  var updated = await _helper.updateLevantamento(l);
                  print(updated);
                  _showGeneratedImovel(true);
                },
              ),
            )
            // define os botões na base do dialogo
          ],
        );
      },
    );
  }

  void _exitCaptureImovel() {
    print("SAINDO DA CAPTURA");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Deseja sair da captura do imóvel? Você poderá retomar mais tarde.",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Text(""),
          actions: <Widget>[
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
                    _polygonSet.clear();
                  });
                  _loginDataStore.setImovelStart(false);
                },
              ),
            ) // define os botões na base do dialog
          ],
        );
      },
    );
  }

  ///PONTE

  Future<void> _startPonteCapture() async {
    var status = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PonteInfoEditPage()),
    );

    if (status == 'start-ponte') {
      print("INICIANDO CAPTURA DA PONTE");

      _loginDataStore.setButtonIniciarCapturaPonte("PAUSAR CAPTURA DA PONTE");
      _stopLoopPonte = false;

      _loginDataStore.setColorStateValue(0);
      _loginDataStore.setCollected(false);

      the_timerPonte();
    }


  }

  void the_timerPonte() {
    if (!_stopLoopPonte) {
      Timer(Duration(seconds: 5), () {
        print("TIMER ON");
        timer_ponte();
      });
    } else {
      print("TIMER OFF");
    }
  }

  Future<void> timer_ponte() async {
    //int loopTimer = int.parse(_loginDataStore.rotaEscolarPointTimer);

    print("THE COLOR STAT -> ${_loginDataStore.colorStateValue}");

    if (_loginDataStore.colorStateValue == 2) {
      print("END OF TIMER");
      _stopLoopPonte = true;
      _endOfTimerPonte();
    } else {
      print("START TIMER");
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _loginDataStore.setUserPosition(position);

      double distanceInMeters = Geolocator.distanceBetween(
          _loginDataStore.userPosition!.latitude, _loginDataStore.userPosition!.longitude, _loginDataStore.oldUserPosition!.latitude, _loginDataStore.oldUserPosition!.longitude);

      print("DISTANCE -> $distanceInMeters");

      if (distanceInMeters >= 3) {
        _loginDataStore.setColorStateValue(0);
      } else {
        if (_loginDataStore.colorStateValue == 1) {
          _loginDataStore.setColorStateValue(2);
        } else if (_loginDataStore.colorStateValue == 0) {
          _loginDataStore.setColorStateValue(1);
        }
      }

      the_timerPonte();

      _loginDataStore.setUserPosition(position);
    }
  }

  void _endOfTimerPonte() {
    _loginDataStore.setButtonIniciarCapturaPonte("INICIAR CAPTURA DA PONTE");

    PontePoint pontePoint = PontePoint();
    pontePoint.nomeRioRiacho = _loginDataStore.ponteRioRiacho;
    pontePoint.extensaoAproximada = _loginDataStore.ponteExtensaoAproximada;
    pontePoint.estadoConservacao = _loginDataStore.ponteEstadoConservacao;
    pontePoint.material = _loginDataStore.ponteMaterial;
    pontePoint.cod_ibge_m = _loginDataStore.m.cod_ibge_m;
    pontePoint.descricao = _loginDataStore.ponteDescricao;
    pontePoint.sincronizado = 0;
    pontePoint.geom = LatLngWithAngle(_loginDataStore.userPosition!.latitude, _loginDataStore.userPosition!.longitude);
    pontePoint.idLevantamento = _loginDataStore.selectedLevantamento.id;

    _helper.savePonte(pontePoint);

    print(pontePoint);

    _showGeneratedPonte(true);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Captura da ponte realizada com sucesso!",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Text(""),
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
                },
              ),
            )
          ],
        );
      },
    );
  }

  void _finalizeCapturePonte() {
    FocusScope.of(context).unfocus();

    print("FINALIZANDO CAPTURA PONTE");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Deseja finalizar e salvar a captura da ponte? Essa operação irá finalizar este levantamento.",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Text(""),
          actions: <Widget>[
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
                onPressed: () async {
                  Navigator.of(context).pop();
                  _loginDataStore.setPonteStart(false);
                  _loginDataStore.clearPonteData();
                  Levantamento l = _loginDataStore.selectedLevantamento;
                  l.status = "finalizado";
                  print("selected -> $l");
                  _loginDataStore.setSelectedLevantamento(l);
                  var updated = await _helper.updateLevantamento(l);
                  print(updated);
                },
              ),
            )
          ],
        );
      },
    );
  }

  void _exitCapturePonte() {
    print("SAINDO DA CAPTURA DA PONTE");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Deseja sair da captura da ponte? Os dados coletados ficarão salvos e você poderá retomar mais tarde.",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Text(""),
          actions: <Widget>[
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
                    _polygonSet.clear();
                  });
                  _loginDataStore.setPonteStart(false);
                },
              ),
            ),
            // define os botões na base do dialogo
          ],
        );
      },
    );
  }

  _capturePhotoWithCamera() async {
    Navigator.of(context).pop();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PonteCameraPickerPage()),
    ).then((value) async {
      //_loginDataStore.setButtonIniciarCapturaImovel("PAUSAR CAPTURA DO PONTO");
      if(value == "save-ponte-image"){

        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 17.5)));
        _loginDataStore.setUserPosition(position);

      }
      print("value -> $value");
    });
  }



  Future<void> _showGeneratedEstrada(bool fit) async {
    _loginDataStore.clearEstradaPointList();
    await _helper.getAllEstradaPointsByLevantamento(_loginDataStore.selectedLevantamento, _loginDataStore).then((value) async {
      _polylineSet.clear();
      List<LatLng> routeCoords = [];
      for (int i = 0; i < _loginDataStore.estradaPointList.length; i++) {
        LatLng coordPoint = new LatLng(_loginDataStore.estradaPointList[i].geom!.latitude, _loginDataStore.estradaPointList[i].geom!.longitude);

        routeCoords.add(coordPoint);

        print("Coord $i $routeCoords");

        String id = "estrada-${_loginDataStore.estradaPointList[i].idLevantamento}-${_loginDataStore.estradaPointList[i].id}";

        Polyline p = new Polyline(polylineId: PolylineId(id), visible: true, points: routeCoords, width: 4, color: Colors.blue, startCap: Cap.roundCap, endCap: Cap.buttCap);

        setState(() {
          _polylineSet.add(p);
        });
      }
      final GoogleMapController controller = await _controller.future;
      if (fit) {
        setState(() {
          MapUtils.setMapFitToTour(_polylineSet, controller);
        });
      }
    });
  }

  Future<void> _showGeneratedRotaEscolar(bool fit) async {
    _loginDataStore.clearRotaEscolarPointList();
    await _helper.getAllRotaEscolarPointsByLevantamento(_loginDataStore.selectedLevantamento, _loginDataStore).then((value) async {
      _polylineSet.clear();
      List<LatLng> routeCoords = [];
      for (int i = 0; i < _loginDataStore.rotaEscolarPointList.length; i++) {
        LatLng coordPoint = new LatLng(_loginDataStore.rotaEscolarPointList[i].geom!.latitude, _loginDataStore.rotaEscolarPointList[i].geom!.longitude);

        routeCoords.add(coordPoint);

        print("Coord $i $routeCoords");

        String id = "rota-escolar-${_loginDataStore.rotaEscolarPointList[i].idLevantamento}-${_loginDataStore.rotaEscolarPointList[i].id}";

        Polyline p = new Polyline(polylineId: PolylineId(id), visible: true, points: routeCoords, width: 4, color: Colors.blue, startCap: Cap.roundCap, endCap: Cap.buttCap);

        setState(() {
          _polylineSet.add(p);
        });
      }
      final GoogleMapController controller = await _controller.future;
      if (fit) {
        setState(() {
          MapUtils.setMapFitToTour(_polylineSet, controller);
        });
      }
    });
  }

  Future<void> _showGeneratedImovel(bool fit) async {
    _loginDataStore.clearImovelGeoPointList();

    await _helper.getAllGeoPointsByLevantamento(_loginDataStore.selectedLevantamento, _loginDataStore).then((value) async {
      setState(() {
        _polylineSet.clear();
        _polygonSet.clear();
        _markerSet.clear();
      });

      List<LatLngWithAngle> pointsCoords = [];
      for (int i = 0; i < _loginDataStore.imovelGeoPointList.length; i++) {
        LatLngWithAngle coordPoint = new LatLngWithAngle(_loginDataStore.imovelGeoPointList[i].geom!.latitude, _loginDataStore.imovelGeoPointList[i].geom!.longitude);

        if (_loginDataStore.imovelGeoPointList[i].tipo == "vertice") {
          pointsCoords.add(coordPoint);
        }

        if (_loginDataStore.imovelGeoPointList[i].tipo == "sede" || _loginDataStore.imovelGeoPointList[i].tipo == "acesso-principal") {
          final MarkerId markerId = MarkerId("ponto-$i");
          final BitmapDescriptor pin = await getPin(_loginDataStore.imovelGeoPointList[i].tipo!);
          final Marker marker = Marker(
            markerId: markerId,
            position: _loginDataStore.imovelGeoPointList[i].geom!,
            infoWindow: InfoWindow(title: _loginDataStore.imovelGeoPointList[i].descricao),
            icon: pin,
            onTap: () {
              print("TAPPED" + _loginDataStore.imovelGeoPointList[i].id.toString());
            },
          );

          setState(() {
            print("ADD MARKING");
            _markerSet.add(marker);
          });
        }

        print("Coord $i $pointsCoords");
      }

      final GoogleMapController controller = await _controller.future;

      if (fit && pointsCoords.length != 0) {
        setState(() {
          PolygonGenerator p = new PolygonGenerator(pointsCoords);
          print("SORTED LIST >>");
          print(p.getSortedList());

          final PolygonId polygonId = PolygonId("vertice-${_loginDataStore.imovelGeoPointList.first.idLevantamento}");

          final Polygon polygon = Polygon(
            polygonId: polygonId,
            points: p.getSortedList(),
            strokeWidth: 2,
            strokeColor: Colors.yellow,
            fillColor: Colors.yellow.withOpacity(0.15),
          );

          setState(() {
            _polygonSet.add(polygon);
          });

          MapUtils.setMapPolygonFitToTour(p.getSortedList(), controller);
        });
      }
    });
  }

  Future<void> _showGeneratedPonte(bool fit) async {
    _loginDataStore.clearPonteList();

    await _helper.getAllPontesByLevantamento(_loginDataStore.selectedLevantamento, _loginDataStore).then((value) async {
      setState(() {
        _polylineSet.clear();
        _polygonSet.clear();
        _markerSet.clear();
      });

      List<LatLngWithAngle> pointsCoords = [];
      for (int i = 0; i < _loginDataStore.ponteList.length; i++) {
        LatLngWithAngle coordPoint = new LatLngWithAngle(_loginDataStore.ponteList[i].geom!.latitude, _loginDataStore.ponteList[i].geom!.longitude);
        final GoogleMapController controller = await _controller.future;
        final MarkerId markerId = MarkerId("ponte-$i");
        final BitmapDescriptor pin = await getPin("ponte");
        PointObject p = PointObject();
        p.location = coordPoint;
        p.child = Text('Lorem Ipsum');

        final Marker marker = Marker(
          markerId: markerId,
          position: _loginDataStore.ponteList[i].geom!,
          icon: pin,
          onTap: () {
            _loginDataStore.setSelectedPonte(_loginDataStore.ponteList[i]);
            _loginDataStore.ponteMaterial = _loginDataStore.ponteList[i].material!;
            _loginDataStore.ponteDescricao = _loginDataStore.ponteList[i].descricao!;
            _loginDataStore.ponteEstadoConservacao = _loginDataStore.ponteList[i].estadoConservacao!;
            _loginDataStore.ponteRioRiacho = _loginDataStore.ponteList[i].nomeRioRiacho!;
            _loginDataStore.ponteExtensaoAproximada = _loginDataStore.ponteList[i].extensaoAproximada!;
            _helper.getAllPonteImagesByPontePoint(_loginDataStore.ponteList[i], _loginDataStore);
            _onTapPonte(p, controller);
          },
        );

        setState(() {
          print("ADD MARKING");
          _markerSet.add(marker);
        });

        print("Coord $i $pointsCoords");
      }

    });
  }

  _toPonteEdit() async{
    var status = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PonteInfoEditPage()),
    );
  }

  _onTapPonte(PointObject point, controller) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    Rect _itemRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;

    _infoWidgetRoute = InfoWidgetRoute(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _loginDataStore.selectedPontePoint!.descricao!.toUpperCase(),
                  style: FontsStyleCTRM.primaryFont20Dark,
                ),
              ),
              Container(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  color: ColorsCTRM.primaryColorAlphaAA,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16.0),
                    bottomLeft: Radius.circular(16.0),
                    topLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                ),
                height: 100,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _toPonteEdit,
                            child: Container(
                              height: 70,
                              child: Center(
                                child: SvgPicture.asset(bridge, height: 60),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: _capturePhotoWithCamera,
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorsCTRM.primaryColorDarkAlpha66,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(16.0),
                                ),
                              ),
                              height: 70,
                              child: Center(
                                child: SvgPicture.asset(camera, height: 45),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _toPonteEdit,
                            child: Container(
                                height: 30,
                                child: Column(
                                  children: [
                                    Center(child: Text("EDITAR", style: FontsStyleCTRM.primaryFontMiniWhite)),
                                    Center(child: Text("PONTE", style: FontsStyleCTRM.primaryFontMiniWhite)),
                                  ],
                                )
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: _capturePhotoWithCamera,
                            child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  color: ColorsCTRM.primaryColorDarkAlpha66,
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(16.0),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Center(child: Text("CAPTURAR", style: FontsStyleCTRM.primaryFontMiniWhite)),
                                    Center(child: Text("IMAGEM", style: FontsStyleCTRM.primaryFontMiniWhite)),
                                  ],
                                )
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      buildContext: context,
      textStyle: FontsStyleCTRM.primaryFont,
      mapsWidgetSize: _itemRect,
    );

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            point.location!.latitude - 0.0001,
            point.location!.longitude,
          ),
          zoom: 18,
        ),
      ),
    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            point.location!.latitude,
            point.location!.longitude,
          ),
          zoom: 18,
        ),
      ),
    );
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
                actions: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Observer(
                      builder: (_) {
                        return IconButton(
                          icon: Icon(
                            _loginDataStore.isAllSincronized ? Icons.done_outline : Icons.cloud_upload,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        );
                      },
                    ),
                  )
                ],
                title: Text(
                  "ITR - " + _loginDataStore.m.municipio_plus_uf(),
                  style: FontsStyleCTRM.primaryFontWhite,
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
                          Icons.map,
                          color: Colors.white,
                        ),
                        backgroundColor: ColorsCTRM.primaryColor,
                        label: "Mapa de Imóveis",
                        labelStyle: FontsStyleCTRM.primaryFont,
                        onTap: viewMap),

                    SpeedDialChild(
                      child: Icon(
                        Icons.alt_route,
                        color: Colors.white,
                      ),
                      backgroundColor: ColorsCTRM.primaryColor,
                      label: "Roteamento",
                      labelStyle: FontsStyleCTRM.primaryFont,
                      onTap: toRoutePage,
                    ),
                    /*if (_loginDataStore.hasSelectedRoute)
                          SpeedDialChild(
                            child: Icon(
                              Icons.linear_scale_outlined,
                              color: Colors.white,
                            ),
                            backgroundColor: ColorsCTRM.primaryColor,
                            label: "Visualizar Rota Selecionada",
                            onTap: _showRoute,
                          )*/
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
                      _mapIdleSubscription = Future.delayed(Duration(milliseconds: 150))
                          .asStream()
                          .listen((_) {
                        if (_infoWidgetRoute != null) {
                          Navigator.of(context, rootNavigator: true)
                              .push(_infoWidgetRoute!)
                              .then<void>(
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
              left: 20,
              bottom: 40,
              child: FloatingActionButton(
                heroTag: "btn1",
                child: Icon(Icons.location_searching),
                backgroundColor: ColorsCTRM.primaryColor,
                onPressed: _getUserLocation,
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
              return _loginDataStore.isImovelCaptureStarted
                  ? Container(
                      color: Colors.white24,
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: Observer(builder: (_) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _loginDataStore.colorStateValue == 0
                                    ? SvgPicture.asset(traffic_light_red, height: 150)
                                    : _loginDataStore.colorStateValue == 1
                                        ? SvgPicture.asset(traffic_light_orange, height: 150)
                                        : _loginDataStore.colorStateValue == 2
                                            ? SvgPicture.asset(traffic_light_green, height: 150)
                                            : SvgPicture.asset(traffic_light_red, height: 150)
                              ],
                            );
                          }),
                        ),
                      ),
                    )
                  : Container();
            }),
            Observer(builder: (_) {
              return _loginDataStore.isPonteCaptureStarted
                  ? Container(
                      color: Colors.white24,
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: Observer(builder: (_) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _loginDataStore.colorStateValue == 0
                                    ? SvgPicture.asset(traffic_light_red, height: 150)
                                    : _loginDataStore.colorStateValue == 1
                                        ? SvgPicture.asset(traffic_light_orange, height: 150)
                                        : _loginDataStore.colorStateValue == 2
                                            ? SvgPicture.asset(traffic_light_green, height: 150)
                                            : SvgPicture.asset(traffic_light_red, height: 150)
                              ],
                            );
                          }),
                        ),
                      ),
                    )
                  : Container();
            }),
            Observer(builder: (_) {
              return _loginDataStore.isEstradaStarted
                  ? Container(
                      color: _loginDataStore.isEstradaCaptureStarted ? Colors.white24 : null,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 50.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _loginDataStore.isEstradaCaptureStarted
                                  ? ConstrainedBox(
                                      constraints: BoxConstraints.tightFor(height: 50),
                                      child: ElevatedButton(
                                        child: Text(
                                          "PAUSAR CAPTURA DA ESTRADA",
                                          style: FontsStyleCTRM.primaryFontWhite,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: ColorsCTRM.primaryColorTetraticRed,
                                          elevation: 6,
                                          shadowColor: ColorsCTRM.primaryColor,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        ),
                                        onPressed: _pauseEstradaCapture,
                                      ))
                                  : ConstrainedBox(
                                      constraints: BoxConstraints.tightFor(height: 50),
                                      child: ElevatedButton(
                                        child: Text(
                                          "INICIAR CAPTURA DA ESTRADA",
                                          style: FontsStyleCTRM.primaryFontWhite,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: ColorsCTRM.primaryColorTetraticGreen,
                                          elevation: 6,
                                          shadowColor: ColorsCTRM.primaryColor,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        ),
                                        onPressed: _startEstradaCapture,
                                      )),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container();
            }),
            Observer(builder: (_) {
              return _loginDataStore.isRotaEscolarStarted
                  ? Container(
                      color: _loginDataStore.isRotaEscolarCaptureStarted ? Colors.white24 : null,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 50.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _loginDataStore.isRotaEscolarCaptureStarted
                                  ? ConstrainedBox(
                                      constraints: BoxConstraints.tightFor(height: 50),
                                      child: ElevatedButton(
                                        child: Text(
                                          "PAUSAR CAPTURA DA ROTA ESCOLAR",
                                          style: FontsStyleCTRM.primaryFontWhite,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: ColorsCTRM.primaryColorTetraticRed,
                                          elevation: 6,
                                          shadowColor: ColorsCTRM.primaryColor,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        ),
                                        onPressed: _pauseRotaEscolarCapture,
                                      ))
                                  : ConstrainedBox(
                                      constraints: BoxConstraints.tightFor(height: 50),
                                      child: ElevatedButton(
                                        child: Text(
                                          "INICIAR CAPTURA DA ROTA ESCOLAR",
                                          style: FontsStyleCTRM.primaryFontWhite,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: ColorsCTRM.primaryColorTetraticGreen,
                                          elevation: 6,
                                          shadowColor: ColorsCTRM.primaryColor,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        ),
                                        onPressed: _startRotaEscolarCapture,
                                      )),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container();
            }),
            Observer(builder: (_) {
              return _loginDataStore.isImovelStarted
                  ? Container(
                      color: _loginDataStore.isImovelCaptureStarted ? Colors.white24 : null,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 50.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _loginDataStore.isImovelCaptureStarted
                                  ? Container()
                                  : Container(
                                      height: 10,
                                    ),
                              _loginDataStore.isImovelCaptureStarted
                                  ? ConstrainedBox(
                                      constraints: BoxConstraints.tightFor(height: 50),
                                      child: ElevatedButton(
                                        child: Text(
                                          "CANCELAR CAPTURA DO PONTO",
                                          style: FontsStyleCTRM.primaryFontWhite,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: ColorsCTRM.primaryColorTetraticRed,
                                          elevation: 6,
                                          shadowColor: ColorsCTRM.primaryColor,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        ),
                                        onPressed: _cancelImovelCapture,
                                      ))
                                  : ConstrainedBox(
                                      constraints: BoxConstraints.tightFor(height: 50),
                                      child: ElevatedButton(
                                        child: Text(
                                          "INICIAR CAPTURA DO PONTO",
                                          style: FontsStyleCTRM.primaryFontWhite,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: ColorsCTRM.primaryColorTetraticGreen,
                                          elevation: 6,
                                          shadowColor: ColorsCTRM.primaryColor,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        ),
                                        onPressed: _startImovelCapture,
                                      )),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container();
            }),
            Observer(builder: (_) {
              return _loginDataStore.isPonteStarted
                  ? Container(
                      color: _loginDataStore.isPonteCaptureStarted ? Colors.white24 : null,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 50.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _loginDataStore.isPonteCaptureStarted
                                  ? Container()
                                  : Container(
                                      height: 10,
                                    ),
                              _loginDataStore.isPonteCaptureStarted
                                  ? ConstrainedBox(
                                      constraints: BoxConstraints.tightFor(height: 50),
                                      child: ElevatedButton(
                                        child: Text(
                                          "CANCELAR CAPTURA DA PONTE",
                                          style: FontsStyleCTRM.primaryFontWhite,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: ColorsCTRM.primaryColorTetraticRed,
                                          elevation: 6,
                                          shadowColor: ColorsCTRM.primaryColor,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        ),
                                        onPressed: () {},
                                      ))
                                  : ConstrainedBox(
                                      constraints: BoxConstraints.tightFor(height: 50),
                                      child: ElevatedButton(
                                        child: Text(
                                          "INICIAR CAPTURA DA PONTE",
                                          style: FontsStyleCTRM.primaryFontWhite,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: ColorsCTRM.primaryColorTetraticGreen,
                                          elevation: 6,
                                          shadowColor: ColorsCTRM.primaryColor,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        ),
                                        onPressed: _startPonteCapture,
                                      )),
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
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                height: 33,
                width: MediaQuery.of(context).size.width,
                color: ColorsCTRM.primaryColorDark,
                child: Divider(),
              ),
            ),
            Observer(builder: (_) {
              return _loginDataStore.isEstradaStarted
                  ? _loginDataStore.isEstradaCaptureStarted
                      ? Container()
                      : Positioned(
                          top: _loginDataStore.statusBarHeight,
                          right: 15,
                          child: Container(
                            height: 56,
                            width: 56,
                            color: ColorsCTRM.primaryColorDark,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: ColorsCTRM.primaryColorTetraticRed,
                                elevation: 6,
                                shadowColor: ColorsCTRM.primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              child: Icon(
                                Icons.close_outlined,
                                color: Colors.white,
                              ),
                              onPressed: _exitCapture,
                            ),
                          ),
                        )
                  : Container();
            }),
            Observer(builder: (_) {
              return _loginDataStore.isRotaEscolarStarted
                  ? _loginDataStore.isRotaEscolarCaptureStarted
                      ? Container()
                      : Positioned(
                          top: _loginDataStore.statusBarHeight,
                          right: 15,
                          child: Container(
                            height: 56,
                            width: 56,
                            color: ColorsCTRM.primaryColorDark,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: ColorsCTRM.primaryColorTetraticRed,
                                elevation: 6,
                                shadowColor: ColorsCTRM.primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              child: Icon(
                                Icons.close_outlined,
                                color: Colors.white,
                              ),
                              onPressed: _exitCaptureRotaEscolar,
                            ),
                          ),
                        )
                  : Container();
            }),
            Observer(builder: (_) {
              return _loginDataStore.isImovelStarted
                  ? _loginDataStore.isImovelCaptureStarted
                      ? Container()
                      : Positioned(
                          top: _loginDataStore.statusBarHeight,
                          right: 15,
                          child: Container(
                            height: 56,
                            width: 56,
                            color: ColorsCTRM.primaryColorDark,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: ColorsCTRM.primaryColorTetraticRed,
                                elevation: 6,
                                shadowColor: ColorsCTRM.primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              child: Icon(
                                Icons.close_outlined,
                                color: Colors.white,
                              ),
                              onPressed: _exitCaptureImovel,
                            ),
                          ),
                        )
                  : Container();
            }),
            Observer(builder: (_) {
              return _loginDataStore.isPonteStarted
                  ? _loginDataStore.isPonteCaptureStarted
                      ? Container()
                      : Positioned(
                          top: _loginDataStore.statusBarHeight,
                          right: 15,
                          child: Container(
                            height: 56,
                            width: 56,
                            color: ColorsCTRM.primaryColorDark,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: ColorsCTRM.primaryColorTetraticRed,
                                elevation: 6,
                                shadowColor: ColorsCTRM.primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              child: Icon(
                                Icons.close_outlined,
                                color: Colors.white,
                              ),
                              onPressed: _exitCapturePonte,
                            ),
                          ),
                        )
                  : Container();
            }),
            /*
            Observer(builder: (_) {
              return _loginDataStore.isEstradaStarted || _loginDataStore.isRotaEscolarStarted || _loginDataStore.isImovelStarted || _loginDataStore.isPonteStarted ?
              _loginDataStore.isEstradaCaptureStarted || _loginDataStore.isRotaEscolarCaptureStarted || _loginDataStore.isImovelCaptureStarted || _loginDataStore.isPonteCaptureStarted ?
              Container() :
              Positioned(
                top: _loginDataStore.statusBarHeight,
                right: 15,
                child: Container(
                  height: 56,
                  width: 56,
                  color: ColorsCTRM.primaryColorDark,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: ColorsCTRM.primaryColorTetraticRed,
                      elevation: 6,
                      shadowColor: ColorsCTRM.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    child: Icon(
                      Icons.close_outlined,
                      color: Colors.white,
                    ),
                    onPressed: _exitCaptureImovel,
                  ),
                ),
              )

                  : Container();
            }),*/
            Observer(builder: (_) {
              return _loginDataStore.isButtonIniciarNavegacaoVisible
                  ? _loginDataStore.isNavigationStarted
                      ? Container()
                      : _loginDataStore.isNavigationStartedWithoutCompass
                          ? Container()
                          : Positioned(
                              top: _loginDataStore.statusBarHeight,
                              right: 15,
                              child: Container(
                                height: 56,
                                width: 56,
                                color: ColorsCTRM.primaryColorDark,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: ColorsCTRM.primaryColorTetraticRed,
                                    elevation: 6,
                                    shadowColor: ColorsCTRM.primaryColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                  ),
                                  child: Icon(
                                    Icons.close_outlined,
                                    color: Colors.white,
                                  ),
                                  onPressed: _exitNavigation,
                                ),
                              ),
                            )
                  : Container();
            }),
            Observer(builder: (_) {
              return _loginDataStore.isEstradaStarted
                  ? _loginDataStore.isEstradaCaptureStarted
                      ? Container()
                      : Positioned(
                          right: 20,
                          bottom: 110,
                          child: FloatingActionButton(
                            heroTag: "btn2",
                            child: Icon(Icons.edit),
                            backgroundColor: ColorsCTRM.primaryColorAnalogBlue,
                            onPressed: _editEstradaInfo,
                          ),
                        )
                  : Container();
            }),
            Observer(builder: (_) {
              return _loginDataStore.isEstradaStarted
                  ? _loginDataStore.isEstradaCaptureStarted
                      ? Container()
                      : Positioned(
                          right: 21,
                          bottom: 40,
                          child: FloatingActionButton(
                            heroTag: "btn3",
                            child: Icon(Icons.done),
                            backgroundColor: ColorsCTRM.primaryColorAnalogGreen,
                            onPressed: _finalizeCapture,
                          ),
                        )
                  : Container();
            }),
            Observer(builder: (_) {
              return _loginDataStore.isRotaEscolarStarted
                  ? _loginDataStore.isRotaEscolarCaptureStarted
                      ? Container()
                      : Positioned(
                          right: 20,
                          bottom: 110,
                          child: FloatingActionButton(
                            heroTag: "btn4",
                            child: Icon(Icons.edit),
                            backgroundColor: ColorsCTRM.primaryColorAnalogBlue,
                            onPressed: _editRotaEscolarInfo,
                          ),
                        )
                  : Container();
            }),
            Observer(builder: (_) {
              return _loginDataStore.isRotaEscolarStarted
                  ? _loginDataStore.isRotaEscolarCaptureStarted
                      ? Container()
                      : Positioned(
                          right: 21,
                          bottom: 40,
                          child: FloatingActionButton(
                            heroTag: "btn5",
                            child: Icon(Icons.done),
                            backgroundColor: ColorsCTRM.primaryColorAnalogGreen,
                            onPressed: _finalizeCaptureRotaEscolar,
                          ),
                        )
                  : Container();
            }),
            Observer(builder: (_) {
              return _loginDataStore.isImovelStarted
                  ? _loginDataStore.isImovelCaptureStarted
                      ? Container()
                      : Positioned(
                          right: 21,
                          bottom: 40,
                          child: FloatingActionButton(
                            heroTag: "btn6",
                            child: Icon(Icons.done),
                            backgroundColor: ColorsCTRM.primaryColorAnalogGreen,
                            onPressed: _finalizeCaptureImovel,
                          ),
                        )
                  : Container();
            }),
            Observer(builder: (_) {
              return _loginDataStore.isPonteStarted
                  ? _loginDataStore.isPonteCaptureStarted
                      ? Container()
                      : Positioned(
                          right: 21,
                          bottom: 40,
                          child: FloatingActionButton(
                            heroTag: "btn7",
                            child: Icon(Icons.done),
                            backgroundColor: ColorsCTRM.primaryColorAnalogGreen,
                            onPressed: _finalizeCapturePonte,
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
    return true;
  }

  void viewMap() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewMapPage()));
  }

  void toLevantamentosPage() async {

    _loginDataStore.fullDataClear();
    _clearMapSet();

    var type_selected = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LevantamentosPage()),
    );

    if (type_selected == 'edit-estrada') {
      _clearMapSet();
      print("estrada");
      var status = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EstradaInfoEditPage()),
      );

      if (status == 'start-estrada') {
        print("estrada start");
        _loginDataStore.setEstradaStart(true);
        _showGeneratedEstrada(true);
      }
    }

    if (type_selected == 'show-estrada') {
      print("estrada show");
      _showGeneratedEstrada(true);
    } else {
      print("nothing");
    }

    if (type_selected == 'edit-rota-escolar') {
      _clearMapSet();
      print("rota-escolar");
      var status = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RotaEscolarInfoEditPage()),
      );

      if (status == 'start-rota-escolar') {
        print("rota-escolar start");
        _loginDataStore.setRotaEscolarStart(true);
        _showGeneratedRotaEscolar(true);
      }
    }

    if (type_selected == 'show-rota-escolar') {
      print("rota-escolar show");
      _showGeneratedRotaEscolar(true);
    } else {
      print("nothing");
    }

    if (type_selected == 'edit-ponto-imovel') {
      _clearMapSet();
      print("ponto-imovel");

      _loginDataStore.setImovelStart(true);
    }

    if (type_selected == 'show-ponto-imovel') {
      print("imovel show");
      _showGeneratedImovel(true);
    } else {
      print("nothing");
    }

    if (type_selected == 'edit-ponte') {
      _showGeneratedPonte(true);
      _loginDataStore.setPonteStart(true);
    }

    if (type_selected == 'show-ponte') {
      print("ponte show");
      _showGeneratedPonte(true);
    } else {
      print("nothing");
    }
  }

  void _editEstradaInfo() async {
    var status = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EstradaInfoEditPage()),
    );

    if (status == 'start-estrada') {
      print("estrada start");
      _loginDataStore.setEstradaStart(true);
    }
  }

  void _editRotaEscolarInfo() async {
    var status = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RotaEscolarInfoEditPage()),
    );

    if (status == 'start-rota-escolar') {
      print("rota-escolar start");
      _loginDataStore.setEstradaStart(true);
    }
  }

  void toRoutePage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RouteListPage()),
    ).then((value) => ({_showRoute()}));
  }

  void _toSedePage() async {
    Navigator.pop(context);
    _loginDataStore.setImovelTipo('sede');
    _loginDataStore.setImovelDescricao("");
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PontoImovelInfoEditPage()),
    ).then((value) {
      if (value == "start-ponto-imovel-vertice") {
        _startImovelCaptureTimer();
      }
    });
  }

  void _toVerticePage() async {
    Navigator.pop(context);
    _loginDataStore.setImovelTipo('vertice');
    _loginDataStore.setImovelDescricao("");

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PontoImovelInfoEditPage()),
    ).then((value) {
      //_loginDataStore.setButtonIniciarCapturaImovel("PAUSAR CAPTURA DO PONTO");
      if (value == "start-ponto-imovel-vertice") {
        _startImovelCaptureTimer();
      }
    });
  }

  void _toAcessoPrincipalPage() async {
    Navigator.pop(context);
    _loginDataStore.setImovelTipo('acesso-principal');
    _loginDataStore.setImovelDescricao("");
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PontoImovelInfoEditPage()),
    ).then((value) {
      //_loginDataStore.setButtonIniciarCapturaImovel("PAUSAR CAPTURA DO PONTO");
      if (value == "start-ponto-imovel-acesso-principal") {
        _startImovelCaptureTimer();
      }
    });
  }

  void _clearMapSet() {
    _polygonSet.clear();
    _markerSet.clear();
    _polylineSet.clear();
  }
}

