import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:app_itr/etc/ConnectionChecker.dart';
import 'package:app_itr/etc/JsonGenerator.dart';
import 'package:app_itr/etc/PathReceiver.dart';
import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:app_itr/ui/AddPointPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

String titleAppBar = "CTRM - ";

class ViewMapPage extends StatefulWidget {
  ViewMapPage({Key? key}) : super(key: key);

  @override
  _ViewMapPageState createState() {
    return _ViewMapPageState();
  }
}

class _ViewMapPageState extends State<ViewMapPage> {
  late LoginDataStore _loginDataStore;
  DBHelper helper = DBHelper();
  String url = "";
  double progress = 0;

  @override
  void initState() {
    super.initState();
    getChilder();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginDataStore = Provider.of<LoginDataStore>(context);

  }

  Future<void> refreshMap() async {
    _webView.evaluateJavascript(source: 'mymap.removeLayer(group);');
  }

  late InAppWebViewController _webView;

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();

    return directory!.path;
  }

  bool stopLoop = false;

  void the_timer() {
    if (!stopLoop) {
      Timer(Duration(seconds: 1), () async {
        print("Refreshing User Position");

        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        _loginDataStore.setUserPosition(position);
        String layer = "var group= L.featureGroup();  var circle1 = L.circle([${_loginDataStore.userPosition!.latitude}, ${_loginDataStore.userPosition!.longitude}],"
            "{radius: 5, color:'white',weight:.5, opacity:1,fillColor: '#1261a1',fillOpacity:0.5}).addTo(group); mymap.addLayer(group);";

        print("STRINGER -> $layer");
        File f = await PathReceiver('tempUserPosition.js').writeString(layer);

        String css = ".content{display: none !important;}";

        _webView.injectJavascriptFileFromUrl(urlFile: Uri.file(f.path));
        _webView.injectCSSCode(source: css);

        _loginDataStore.setMapLoading(false);
      });
    } else {
      print("TIMER OFF");
    }
  }

  late Widget w;

  Widget getChilder() {
    w = InAppWebView(
      initialFile: 'assets/map/ex_map.html',
      initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
          )),
      onWebViewCreated: (InAppWebViewController controller) {
        _webView = controller;
        _startFiles(controller);
      },
    );

    return w;
  }

  Future<File> _startFiles(InAppWebViewController controller) async {
    ConnectionChecker.checkConnection();

    final path = await _localPath;
    print("PATH -> $path");

    String filename = _loginDataStore.geoJsonFileName;
    String fileJS = _loginDataStore.javaScriptFileName;
    File f = await File('$path/$filename');
    File f2 = await File('$path/$fileJS');
    print("gefname -> $filename");
    try {
      // Read the file.
      String contents = await f.readAsString();
      String contents2 = await f2.readAsString();
      print("CONTENTS -- $contents");
      //debugPrint(contents2, wrapWidth: 1024);

      controller.evaluateJavascript(source: contents);
      //controller.injectJavascriptFileFromUrl(urlFile: f2.path);
      Timer(Duration(seconds: 2), () {
        print("TIMER ON Evaluate");
        controller.injectJavascriptFileFromUrl(urlFile: Uri.file(f2.path));
      });

      the_timer();
    } catch (e) {
      // If encountering an error, return 0.
      print("Error -> $e");
      f.writeAsString(_loginDataStore.m.toString());
    }

    throw true;
  }

  Future<bool> _onBackPressed() {
    stopLoop = true;
    Navigator.of(context).pop(true);
    _loginDataStore.setMapLoading(true);
    throw true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                actions: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Observer(
                      builder: (_) {
                        return Container();
                      },
                    ),
                  )
                ],
                title: Text("ITR - " + _loginDataStore.m.municipio_plus_uf(), style: FontsStyleCTRM.primaryFontWhite,),
                centerTitle: true,
                backgroundColor: Theme
                    .of(context)
                    .primaryColor,
              ),
              body: Stack(
                children: [
                  Observer(builder: (_) {
                    return w;
                  })
                ],
              ),
            ),
          ],
        ),
        onWillPop: _onBackPressed);
  }
}