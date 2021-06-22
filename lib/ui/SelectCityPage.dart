import 'dart:io';

import 'package:app_itr/etc/JavaScriptGenerator.dart';
import 'package:app_itr/etc/JsonGenerator.dart';
import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/helpers/classes/municipio.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:app_itr/ui/MainPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import 'LoginPage.dart';

final selecionar = "Selecionar";

class SelectCityPage extends StatefulWidget {
  @override
  _SelectCityPageState createState() => _SelectCityPageState();
}

class _SelectCityPageState extends State<SelectCityPage> {

  DBHelper helper = DBHelper();
  late LoginDataStore _loginDataStore;
  double statusBarHeight = 0.0;
  Municipio _aux = new Municipio();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginDataStore = Provider.of<LoginDataStore>(context);
    statusBarHeight = MediaQuery.of(context).padding.top;
    _loginDataStore.setStatusBarHeight(statusBarHeight);
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarBrightness: Brightness.light) // Or Brightness.dark
    );
  }

  @override
  void initState() {

    super.initState();
  }



  String dropdownValue = 'One';


  late Position _currentPosition;
  late String _currentAddress;


  Future<Municipio?> getMunicipio(int id) async {
    return await helper.getMunicipio(id);
  }

  void _start_app() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
  }

  Future<bool> _onBackPressed() async {
    BuildContext dialogContext;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          dialogContext = context;
          return WillPopScope(
              child: Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
                elevation: 16,
                child: Container(
                  height: 140.0,
                  width: 360.0,
                  child: ListView(
                    children: <Widget>[
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          "Deseja sair do CTRM?",
                          style: FontsStyleCTRM.primaryFont25SuperDark,
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: RaisedButton(
                                child: Text(
                                  "SIM",
                                  style: FontsStyleCTRM.primaryFontWhite,
                                ),
                                color: ColorsCTRM.primaryColorDark,
                                onPressed: () {
                                  SystemChannels.platform.invokeMapMethod('SystemNavigator.pop');
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: RaisedButton(
                                color: ColorsCTRM.primaryColorTetraticRed,
                                child: Text(
                                  "NÃO",
                                  style:  FontsStyleCTRM.primaryFontWhite,
                                ),
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              onWillPop: () {
                throw true;
              });
        });

    throw true;
  }

  void _logout() {
    helper.deleteLoggedUser();
    _loginDataStore.logout();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  void logout() {
    BuildContext dialogContext;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          dialogContext = context;
          return WillPopScope(
              child: Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
                elevation: 16,
                child: Container(
                  height: 140.0,
                  width: 360.0,
                  child: ListView(
                    children: <Widget>[
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          "Deseja fazer o logout?",
                          style: FontsStyleCTRM.primaryFont20Dark
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: RaisedButton(
                                child: Text(
                                  "SIM",
                                  style: FontsStyleCTRM.primaryFontWhite
                                ),
                                color: ColorsCTRM.primaryColorDark,
                                onPressed: _logout,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: RaisedButton(
                                color: ColorsCTRM.primaryColorTetraticRed,
                                child: Text(
                                  "NÃO",
                                  style:  FontsStyleCTRM.primaryFontWhite
                                ),
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              onWillPop: () {
                throw true;
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    print("INITIAL -> " + _loginDataStore.isCidadeValid.toString() + "VALUE ");
    return WillPopScope(
        child: Stack(
          children: [
            Scaffold(
                backgroundColor: Colors.white,
                body: SingleChildScrollView(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 20.0, right: 20.0), child: Image(image: AssetImage('assets/images/logo_verde.png'))),
                    Padding(
                        padding: EdgeInsets.only(left: 40.0, right: 40.0),
                        child: Observer(
                          builder: (_) {
                            return DropdownButton<Municipio>(
                              value: _loginDataStore.m,
                              selectedItemBuilder: (_) {
                                return _loginDataStore.municipiosList
                                    .map((e) => Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            e.municipio_plus_uf(),
                                            style: FontsStyleCTRM.primaryFont
                                          ),
                                        ))
                                    .toList();
                              },
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              style: FontsStyleCTRM.primaryFont,
                              isExpanded: true,
                              underline: Container(
                                height: 2,
                                color: ColorsCTRM.primaryColorDark,
                              ),
                              onChanged: (Municipio? newValue) {
                                if(newValue!.idSistema != 0){

                                  _loginDataStore.setMunicipio(newValue!);

                                  try{
                                    String nomeFile = "${newValue.municipio_plus_uf()}";
                                    _loginDataStore.setGeoJsonFileName("$nomeFile.json");
                                    _loginDataStore.setJavaScriptFileName("$nomeFile.js");

                                    JavaScriptGenerator().generateJS(_loginDataStore);

                                  } catch(e){
                                    print("Exception $e");
                                  }
                                }
                              },
                              items: _loginDataStore.municipiosList
                                  .map<DropdownMenuItem<Municipio>>((Municipio item) {
                                return DropdownMenuItem<Municipio>(
                                  value: item,
                                  child: new Text(
                                    item.municipio_plus_uf(),
                                    style: FontsStyleCTRM.primaryFont18Dark
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        )),
                    Padding(
                      padding: EdgeInsets.only(left: 40.0, right: 40.0, top: 40.0),
                      child: Observer(
                        builder: (_) {
                          return RaisedButton(
                            disabledColor: ColorsCTRM.primaryColorDarkAlpha66,
                            onPressed: _loginDataStore.isCidadeValid ? _start_app : null,
                            color: ColorsCTRM.primaryColorAlphaAA,
                            child: Text(
                              "SELECIONAR",
                              style: FontsStyleCTRM.primaryFontWhite,
                            ),
                          );
                        },
                      ),
                    )
                  ]),
                )),
            Positioned(
              right: 20,
              bottom: 40,
              child: FloatingActionButton.extended(
                shape: _CustomBorder(),
                label: Row(
                  children: [Text('LOGOUT')],
                ),
                icon: Icon(Icons.logout),
                backgroundColor: ColorsCTRM.primaryColorTetraticRed,
                onPressed: logout,
              ),
            )
          ],
        ),
        onWillPop: _onBackPressed);
  }
}

class _CustomBorder extends ShapeBorder {
  const _CustomBorder();

  @override
  EdgeInsetsGeometry get dimensions {
    return const EdgeInsets.only();
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.right - rect.width / 2, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    // TODO: implement scale
    throw UnimplementedError();
  }
}
