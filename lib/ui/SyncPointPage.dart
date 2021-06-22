import 'dart:async';

import 'package:app_itr/etc/PolygonGenerator.dart';
import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/helpers/classes/ImovelGeoPoint.dart';
import 'package:app_itr/helpers/classes/imovel.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class SyncPointPage extends StatefulWidget {
  SyncPointPage({Key? key}) : super(key: key);

  @override
  _SyncPointPageState createState() {
    return _SyncPointPageState();
  }
}

class _SyncPointPageState extends State<SyncPointPage> {
  DBHelper helper = DBHelper();

  @override
  void initState() {
    super.initState();
    the_timer();
  }

  void the_timer() {
    if (!stopLoop) {
      Timer(Duration(seconds: 5), () {
        print("TIMER ON");
        _set_user_position();
      });
    } else {
      print("TIMER OFF");
    }
  }

  void _set_user_position() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _loginDataStore.setUserPosition(position);

    double distanceInMeters = Geolocator.distanceBetween(
        _loginDataStore.userPosition!.latitude,
        _loginDataStore.userPosition!.longitude,
        _loginDataStore.oldUserPosition!.latitude,
        _loginDataStore.oldUserPosition!.longitude);

    if (distanceInMeters >= 3) {
      _loginDataStore.setColorStateValue(0);
    } else {
      if (_loginDataStore.colorStateValue == 1) {
        _loginDataStore.setColorStateValue(2);
      } else if (_loginDataStore.colorStateValue == 0) {
        _loginDataStore.setColorStateValue(1);
      }
    }

    if (_loginDataStore.colorStateValue == 2) {
      stopLoop = true;
    }
    the_timer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _loginDataStore = Provider.of<LoginDataStore>(context);
    startController();
  }

  TextEditingController controllerIdent = TextEditingController();
  TextEditingController controllerIdentVertice = TextEditingController();
  late LoginDataStore _loginDataStore;
  String text = "";
  int maxLength = 10;
  bool stopLoop = false;

  Future<bool> _onBackPressed() {
    stopLoop = true;
    _loginDataStore.resetValues();
    Navigator.of(context).pop(true);
    _loginDataStore.setCollected(false);
    throw true;
  }

  Color getColor() {
    if (_loginDataStore.colorStateValue == 0) {
      return Colors.red;
    } else if (_loginDataStore.colorStateValue == 1) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String textHelp() {
    double distanceInMeters = Geolocator.distanceBetween(
        _loginDataStore.userPosition!.latitude,
        _loginDataStore.userPosition!.longitude,
        _loginDataStore.oldUserPosition!.latitude,
        _loginDataStore.oldUserPosition!.longitude);

    if (_loginDataStore.colorStateValue == 0) {
      return "Localizando satélites";
    } else if (_loginDataStore.colorStateValue == 1) {
      return "Preparando";
    } else {
      return "Satélite Localizado!";
    }
  }

  late int verticeValue;

  void startController() {
    if (_loginDataStore.isTipoVertice) {
      if (_loginDataStore.verticeActualValue == 0) {
        _loginDataStore.setVerticeActualValue(1);
        verticeValue = _loginDataStore.verticeActualValue;
      }
      controllerIdentVertice.text = "P$verticeValue";
      _loginDataStore.setIdent(controllerIdentVertice.text);
    }
  }

  void newGeopoint() {
    stopLoop = false;

    _loginDataStore.setColorStateValue(0);
    _loginDataStore.setCollected(false);

    verticeValue++;
    _loginDataStore.setVerticeActualValue(verticeValue);
    controllerIdentVertice.text = "P$verticeValue";
    _loginDataStore.setIdent(controllerIdentVertice.text);

    the_timer();
  }

  void salvarPonto() {
    ImovelGeoPoint gp = ImovelGeoPoint();

    print("collected is -> " + _loginDataStore.colected.toString());

    if (_loginDataStore.tipo_ponto == 0) {
      print("Tipo Vértice");

      gp.tipo = "vertice";
      gp.descricao = controllerIdentVertice.text;
      gp.geom = LatLngWithAngle(_loginDataStore.userPosition!.latitude, _loginDataStore.userPosition!.longitude);
      gp.sincronizado = 0;

      helper.saveGeoPoint(gp);

      _loginDataStore.setAllSincronized(false);

      _loginDataStore.setCollected(true);

      if(!_loginDataStore.isImovelUsing){
        print("FIRST IMOVEL POINT");
          Imovel im = _loginDataStore.imovel;
          im.using = true;
          im.geoPoints!.add(gp);
          _loginDataStore.setImovel(im);

      } else{
        print("NEW IMOVEL POINT");
        Imovel im = _loginDataStore.imovel;
        im.geoPoints!.add(gp);
        _loginDataStore.setImovel(im);
      }

    } else if (_loginDataStore.tipo_ponto == 1) {
      print("Tipo Acesso");
      gp.tipo = "acesso";
      gp.descricao = controllerIdent.text;
      gp.geom = LatLngWithAngle(_loginDataStore.userPosition!.latitude, _loginDataStore.userPosition!.longitude);
      gp.sincronizado = 0;

      helper.saveGeoPoint(gp);

      _loginDataStore.setAllSincronized(false);

      _onBackPressed();
    } else if (_loginDataStore.tipo_ponto == 2) {
      print("Tipo Sede");

      gp.tipo = "sede";
      gp.descricao = controllerIdent.text;
      gp.geom = LatLngWithAngle(_loginDataStore.userPosition!.latitude, _loginDataStore.userPosition!.longitude);
      gp.sincronizado = 0;

      helper.saveGeoPoint(gp);

      _loginDataStore.setAllSincronized(false);

      _onBackPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Sincronizar Ponto"),
            centerTitle: true,
          ),
          body: Observer(
            builder: (_) {
              return Container(
                color: ColorsCTRM.primaryColorAlphaAA,
                padding: EdgeInsets.all(7.0),
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(5.0),
                  child: Center(
                    child: Container(
                      child: Table(
                        children: [
                          TableRow(children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 25),
                              child: Icon(
                                Icons.lightbulb,
                                size: 150,
                                color: getColor(),
                              ),
                            )
                          ]),
                          TableRow(children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 25),
                              child: Container(
                                width: 50,
                                alignment: Alignment.center,
                                child: _loginDataStore.isColorFinished
                                    ? Icon(
                                        Icons.done_outline,
                                        color: Colors.green,
                                      )
                                    : CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                              ),
                            )
                          ]),
                          TableRow(children: [
                            Text(
                              textHelp(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24),
                            )
                          ]),
                          TableRow(children: [
                            _loginDataStore.isColorFinished
                                ? Padding(
                                    padding: EdgeInsets.only(top: 40.0),
                                    child: Text(
                                      "Identificação",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  )
                                : Container(),
                          ]),
                          TableRow(children: [
                            Padding(
                              padding: EdgeInsets.only(top: 15.0, right: 50.0, left: 50.0),
                              child: _loginDataStore.isColorFinished
                                  ? _loginDataStore.isTipoVertice
                                      ? Container(
                                          height: 40,
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: TextField(
                                              keyboardType: TextInputType.text,
                                              enabled: false,
                                              textAlign: TextAlign.center,
                                              maxLength: 10,
                                              maxLengthEnforced: true,
                                              decoration: InputDecoration(counterText: ""),
                                              onChanged: _loginDataStore.setIdent,
                                              controller: controllerIdentVertice,
                                              inputFormatters: [
                                                LengthLimitingTextInputFormatter(10),
                                              ]),
                                        )
                                      : Container(
                                          height: 40,
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: TextField(
                                              keyboardType: TextInputType.text,
                                              enabled: _loginDataStore.isColorFinished,
                                              textAlign: TextAlign.center,
                                              maxLength: 10,
                                              maxLengthEnforced: true,
                                              decoration: InputDecoration(counterText: ""),
                                              onChanged: _loginDataStore.setIdent,
                                              controller: controllerIdent,
                                              inputFormatters: [
                                                LengthLimitingTextInputFormatter(10),
                                              ]),
                                        )
                                  : Container(),
                            )
                          ]),
                          _loginDataStore.isTipoVertice
                              ? TableRow(children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 15.0, right: 80.0, left: 80.0),
                                    child: _loginDataStore.isColorFinished
                                        ? Container(
                                            height: 42,
                                            padding: EdgeInsets.only(bottom: 10),
                                            child: RaisedButton(
                                              onPressed:
                                                  _loginDataStore.isIdentValid && !_loginDataStore.isColected
                                                      ? salvarPonto
                                                      : null,
                                              color: Color(0xAA12a19a),
                                              child: Text(
                                                _loginDataStore.isColected ? "COLETADO" : "COLETAR",
                                                style: TextStyle(color: Colors.white, fontSize: 15.0),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  )
                                ])
                              : TableRow(children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 15.0, right: 80.0, left: 80.0),
                                    child: _loginDataStore.isColorFinished
                                        ? Container(
                                            height: 42,
                                            padding: EdgeInsets.only(bottom: 10),
                                            child: RaisedButton(
                                              onPressed: _loginDataStore.isIdentValid ? salvarPonto : null,
                                              color: Color(0xAA12a19a),
                                              child: Text(
                                                "COLETAR",
                                                style: TextStyle(color: Colors.white, fontSize: 15.0),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  )
                                ]),
                          TableRow(children: [
                            Padding(
                              padding: EdgeInsets.only(left: 80.0, right: 80.0, top: 10.0),
                              child: _loginDataStore.isColected
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(),
                                          child: _loginDataStore.isColorFinished
                                              ? Container(
                                                  height: 42,
                                                  padding: EdgeInsets.only(bottom: 10),
                                                  child: RaisedButton(
                                                    onPressed:
                                                        _loginDataStore.isIdentValid ? newGeopoint : null,
                                                    color: Color(0xAA12a19a),
                                                    child: Icon(Icons.add, color: Colors.white),
                                                  ),
                                                )
                                              : Container(),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(),
                                          child: _loginDataStore.isColorFinished
                                              ? Container(
                                                  height: 42,
                                                  padding: EdgeInsets.only(bottom: 10),
                                                  child: RaisedButton(
                                                    onPressed:
                                                        _loginDataStore.isIdentValid ? _onBackPressed : null,
                                                    color: Color(0xAA12a19a),
                                                    child: Icon(Icons.save, color: Colors.white),
                                                  ),
                                                )
                                              : Container(),
                                        )
                                      ],
                                    )
                                  : Container(),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        onWillPop: _onBackPressed);
  }
}
