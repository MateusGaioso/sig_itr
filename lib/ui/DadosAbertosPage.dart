import 'dart:async';
import 'dart:io';

import 'package:app_itr/api/dados_abertos_api.dart';
import 'package:app_itr/etc/ConnectionChecker.dart';
import 'package:app_itr/etc/JavaScriptGenerator.dart';
import 'package:app_itr/etc/JsonGenerator.dart';
import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/helpers/classes/AppData.dart';
import 'package:app_itr/helpers/classes/Estado.dart';
import 'package:app_itr/helpers/classes/Municipio.dart';
import 'package:app_itr/helpers/classes/RegiaoAdministrativa.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:app_itr/ui/MainPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import 'ImoveisDadosAbertosPage.dart';
import 'LoginPage.dart';

final selecionar = "Selecionar";

class DadosAbertosPage extends StatefulWidget {
  @override
  _DadosAbertosPage createState() => _DadosAbertosPage();
}

class _DadosAbertosPage extends State<DadosAbertosPage> with TickerProviderStateMixin {
  DBHelper helper = DBHelper();
  late LoginDataStore _loginDataStore;
  double statusBarHeight = 0.0;
  late AnimationController controller;
  BuildContext? _dialogContext;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    _loginDataStore = Provider.of<LoginDataStore>(context);
    statusBarHeight = MediaQuery.of(context).padding.top;
    _loginDataStore.setStatusBarHeight(statusBarHeight);

    for (final e in _loginDataStore.municipiosList) {
      //
      if (e.slug == _loginDataStore.m.slug) {
        _loginDataStore.setMunicipio(e);

        _loginDataStore.setEstado(_loginDataStore.estadosList.firstWhere((element) => element.sigla_uf == e.sigla_uf));
        //_getRegiaoAdmnistrativa(_loginDataStore.m.cod_ibge_m!);
      }
    }

    try {
      var conn = await ConnectionChecker.checkConnection();
      if (conn) {
        if (_loginDataStore.isMunicipioJSFileLoaded) {
        } else {
          String nomeFile = "${_loginDataStore.m.municipio_plus_uf()}";
          _loginDataStore.setGeoJsonFileName("$nomeFile.json");
          _loginDataStore.setJavaScriptFileName("$nomeFile.js");

          JavaScriptGenerator().generateJS(_loginDataStore);
          _loginDataStore.setMunicipioJSFileLoaded(true);
        }
      }
    } catch (e) {
      print("Exception $e");
    }

    if (_loginDataStore.defaultMunicipio) {
      _showDefaultMunicipioDialog();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  List<RegiaoAdministrativa> _sortReg() {
    //_loginDataStore.regiaoAdministrativaList.sort((a, b) => a.nome!.compareTo(b.nome!));
    return _loginDataStore.regiaoAdministrativaList;
  }

  _pushToImoveis() {
    Navigator.pop(_dialogContext!);
    Navigator.push(context, MaterialPageRoute(builder: (context) => ImoveisDadosAbertosPage()));
  }

  void _start_app() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          _dialogContext = context;
          return Dialog(
            elevation: 16,
            backgroundColor: Color(0x0012a19a),
            child: Align(
              heightFactor: 0,
              child: Container(
                height: 30.0,
                width: 30.0,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  strokeWidth: 2.0,
                ),
              ),
            ),
          );
        });

    Timer(Duration(milliseconds: 300), () {
      print("MUNICIPIO -> ${_loginDataStore.m}");
      _loginDataStore.startSearching();
      if (_loginDataStore.m.allImoveisDownloaded == 0) {
        if (_loginDataStore.regAdm.nome == "TODAS") {
          _loginDataStore.clearImovelDadosAbertos();
          _loginDataStore.resetSearchValue();

          _loginDataStore.setAppDataImoveisLoaded(0);
          _loginDataStore.setAppDataMunicipiosLoaded(1);
          helper.updateAppData(_loginDataStore.appData).then((data) {
            _pushToImoveis();
          });
        } else {
          helper.checkIfHasImoveisByCodIbge(_loginDataStore).then((value) {
            if (value) {
              _loginDataStore.setAppDataImoveisLoaded(1);
              _loginDataStore.setAppDataMunicipiosLoaded(1);
              helper.updateAppData(_loginDataStore.appData).then((valueData) {
                helper.getAllImoveisDadosAbertosByMunicipio(_loginDataStore).then((data) {
                  _pushToImoveis();
                });
              });
            } else {
              _loginDataStore.clearImovelDadosAbertos();
              _loginDataStore.resetSearchValue();

              _loginDataStore.setAppDataImoveisLoaded(0);
              _loginDataStore.setAppDataMunicipiosLoaded(1);
              helper.updateAppData(_loginDataStore.appData).then((data) {
                _pushToImoveis();
              });
            }
          });
        }
      } else {
        _loginDataStore.setAppDataImoveisLoaded(1);
        _loginDataStore.setAppDataMunicipiosLoaded(1);
        helper.updateAppData(_loginDataStore.appData).then((valueData) {
          helper.getAllImoveisDadosAbertosByMunicipio(_loginDataStore).then((data) {
            _pushToImoveis();
          });
        });
      }
    });
  }

  Future<bool> _onBackPressed() async {
    Navigator.pop(context);

    return true;
  }

  void _removeFocus() {
    FocusScope.of(context).unfocus();
  }

  void _getMunicipios(String uf) async {
    print("changed");
    helper.checkIfHasMunicipiosByUF(_loginDataStore, uf).then((value) async {
      if (value) {
        _loginDataStore.setMunicipiosLoading(true);
        helper.getAllMunicipiosByUFOffline(_loginDataStore, uf).then((value) {
          _loginDataStore.setMunicipiosLoading(false);
          _getRegiaoAdmnistrativa(_loginDataStore.m.cod_ibge_m!);
        });
      } else {
        var conn = await ConnectionChecker.checkConnection();
        _loginDataStore.setMunicipiosLoading(true);

        if (conn) {
          await DadosAbertosAPI(_loginDataStore, helper).getMunicipiosByUF(uf).whenComplete(() {
            _loginDataStore.setMunicipio(_loginDataStore.municipiosList.first);
            _loginDataStore.setMunicipiosLoading(false);
            _getRegiaoAdmnistrativa(_loginDataStore.m.cod_ibge_m!);
          });
        } else {
          _loginDataStore.setMunicipiosLoading(true);
          helper.getAllMunicipiosByUFOffline(_loginDataStore, uf).then((value) {
            _loginDataStore.setMunicipiosLoading(false);
            _getRegiaoAdmnistrativa(_loginDataStore.m.cod_ibge_m!);
          });
        }
      }
    });
  }

  void _getRegiaoAdmnistrativa(String cod_ibg_m) async {
    _loginDataStore.setRegAdmLoading(true);
    Timer(Duration(milliseconds: 100), () {
      print("changed");
      helper.checkIfHasRegAdmByCodIbgeM(_loginDataStore, cod_ibg_m).then((value) async {
        if (value) {
          helper.getAllRegAdmByCodIbgeM(_loginDataStore, cod_ibg_m).then((value) {
            _loginDataStore.setRegAdm(_loginDataStore.regiaoAdministrativaList.first);
            _loginDataStore.setRegAdmLoading(false);
          });
        } else {
          var conn = await ConnectionChecker.checkConnection();

          if (conn) {
            await DadosAbertosAPI(_loginDataStore, helper).getRegAdmByMunicipio(cod_ibg_m).whenComplete(() {
              _loginDataStore.setRegAdm(_loginDataStore.regiaoAdministrativaList.first);
              _loginDataStore.setRegAdmLoading(false);
            });
          } else {
            helper.getAllRegAdmByCodIbgeM(_loginDataStore, cod_ibg_m).then((value) {
              _loginDataStore.setRegAdm(_loginDataStore.regiaoAdministrativaList.first);
              _loginDataStore.setRegAdmLoading(false);
            });
          }
        }
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
                    Padding(padding: EdgeInsets.only(), child: Image(image: AssetImage('assets/images/recurso_grafico.png'))),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 20, 40, 0),
                      child: Text(
                        "Estado".toUpperCase(),
                        style: FontsStyleCTRM.primaryFont17White,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 40, 12),
                      child: Container(
                        height: 55.0,
                        decoration: BoxDecoration(border: Border.all(color: ColorsCTRM.primaryColor), borderRadius: BorderRadius.circular(12), color: Colors.white),
                        child: Observer(
                          builder: (_) {
                            return DropdownButton<Estado>(
                              value: _loginDataStore.e,
                              icon: Padding(
                                padding: const EdgeInsets.only(right: 20, top: 12),
                                child: Icon(
                                  Icons.arrow_drop_down_sharp,
                                  color: ColorsCTRM.primaryColor,
                                ),
                              ),
                              iconSize: 24,
                              underline: Container(),
                              elevation: 16,
                              isExpanded: true,
                              onChanged: _loginDataStore.isMunicipioLoading
                                  ? null
                                  : _loginDataStore.isRegAdmLoading
                                      ? null
                                      : (Estado? estado) {
                                          _loginDataStore.setEstado(estado!);
                                          _getMunicipios(_loginDataStore.e.sigla_uf!);
                                        },
                              onTap: _showMunicipioChangedDialog,
                              items: _loginDataStore.estadosList.map<DropdownMenuItem<Estado>>((Estado item) {
                                return DropdownMenuItem<Estado>(
                                  value: item,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 25),
                                    child: Text(
                                      item.nome!,
                                      style: FontsStyleCTRM.primaryFont18Dark,
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 20, 40, 0),
                      child: Text(
                        "Município".toUpperCase(),
                        style: FontsStyleCTRM.primaryFont17White,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 40, 12),
                      child: Container(
                        height: 55.0,
                        decoration: BoxDecoration(border: Border.all(color: ColorsCTRM.primaryColor), borderRadius: BorderRadius.circular(12), color: Colors.white),
                        child: Observer(
                          builder: (_) {
                            return _loginDataStore.isMunicipioLoading
                                ? Container(
                                    width: 10,
                                    height: 10,
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                      strokeWidth: 2.0,
                                    ),
                                  )
                                : DropdownButton<Municipio>(
                                    onTap: _showMunicipioChangedDialog,
                                    value: _loginDataStore.m,
                                    icon: Padding(
                                      padding: const EdgeInsets.only(right: 20, top: 8),
                                      child: Icon(
                                        Icons.arrow_drop_down_sharp,
                                        color: ColorsCTRM.primaryColor,
                                      ),
                                    ),
                                    iconSize: 24,
                                    underline: Container(),
                                    elevation: 16,
                                    isExpanded: true,
                                    onChanged: _loginDataStore.isRegAdmLoading
                                        ? null
                                        : (Municipio? newValue) {
                                            if (newValue!.idSistema != 0) {
                                              _loginDataStore.setAppDataImoveisLoaded(0);
                                              helper.updateAppData(_loginDataStore.appData);

                                              _loginDataStore.setMunicipio(newValue);
                                              _loginDataStore.setMunicipioJSFileLoaded(false);

                                              _getRegiaoAdmnistrativa(newValue.cod_ibge_m!);

                                              try {
                                                String nomeFile = "${newValue.municipio_plus_uf()}";
                                                _loginDataStore.setGeoJsonFileName("$nomeFile.json");
                                                _loginDataStore.setJavaScriptFileName("$nomeFile.js");

                                                JavaScriptGenerator().generateJS(_loginDataStore);
                                              } catch (e) {
                                                print("Exception $e");
                                              }
                                            }
                                          },
                                    items: _loginDataStore.municipiosList.map<DropdownMenuItem<Municipio>>((Municipio item) {
                                      return DropdownMenuItem<Municipio>(
                                        value: item,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 25),
                                          child: Text(
                                            item.nome!,
                                            style: FontsStyleCTRM.primaryFont18Dark,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 20, 40, 0),
                      child: Text(
                        "Região Administrativa".toUpperCase(),
                        style: FontsStyleCTRM.primaryFont17White,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 40, 0),
                      child: Container(
                        height: 55.0,
                        decoration: BoxDecoration(border: Border.all(color: ColorsCTRM.primaryColor), borderRadius: BorderRadius.circular(12), color: Colors.white),
                        child: Observer(
                          builder: (_) {
                            return _loginDataStore.isRegAdmLoading
                                ? Container(
                                    width: 10,
                                    height: 10,
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                      strokeWidth: 2.0,
                                    ),
                                  )
                                : DropdownButton<RegiaoAdministrativa>(
                                    value: _loginDataStore.regAdm,
                                    selectedItemBuilder: (_) {
                                      return _sortReg()
                                          .map((e) => Container(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 25),
                                                  child: Text(e.nome!, style: FontsStyleCTRM.primaryFont18Dark),
                                                ),
                                              ))
                                          .toList();
                                    },
                                    icon: Padding(
                                      padding: const EdgeInsets.only(right: 20, top: 8),
                                      child: Icon(
                                        Icons.arrow_drop_down_sharp,
                                        color: ColorsCTRM.primaryColor,
                                      ),
                                    ),
                                    iconSize: 24,
                                    underline: Container(),
                                    elevation: 16,
                                    isExpanded: true,
                                    onChanged: (RegiaoAdministrativa? newValue) {
                                      if (newValue!.idSistema != 0) {
                                        _loginDataStore.setAppDataImoveisLoaded(0);
                                        helper.updateAppData(_loginDataStore.appData);
                                        _loginDataStore.setRegAdm(newValue);
                                      }
                                    },
                                    items: _sortReg().map<DropdownMenuItem<RegiaoAdministrativa>>((RegiaoAdministrativa item) {
                                      return DropdownMenuItem<RegiaoAdministrativa>(
                                        value: item,
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.nome!,
                                                style: FontsStyleCTRM.primaryFont18Dark,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 25.0, bottom: 25.0),
                                                child: Container(height: 1, color: ColorsCTRM.primaryColor,),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 40.0, right: 40.0, top: 40.0),
                      child: RaisedButton(
                        disabledColor: ColorsCTRM.primaryColorDarkAlpha66,
                        onPressed: _start_app,
                        color: ColorsCTRM.primaryColorAlphaAA,
                        child: Text(
                          "SELECIONAR",
                          style: FontsStyleCTRM.primaryFontWhite,
                        ),
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
                  children: [Text('VOLTAR')],
                ),
                icon: Icon(Icons.arrow_back),
                backgroundColor: ColorsCTRM.primaryColorAnalogBlue,
                onPressed: _onBackPressed,
              ),
            )
          ],
        ),
        onWillPop: _onBackPressed);
  }

  void _showMunicipioChangedDialog() {
    if (_loginDataStore.isMunicipioLocalizedChanged) {
    } else {
      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: new Text(
              "Você está alterando o município em que está localizado, deseja continuar mesmo assim?",
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
                    _removeFocus();
                    Navigator.of(dialogContext).pop();
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
                    _loginDataStore.setMunicipioLocalize(true);
                    _loginDataStore.setStartImoveisDownload(false);
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void _showDefaultMunicipioDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () => Future.value(false),
          child: AlertDialog(
            title: new Text(
              "Não foi possível encontrar sua localização.",
              style: FontsStyleCTRM.primaryFont20Dark,
            ),
            content: Text("Seu município não está habilitado em nosso sistema. Por favor, entre em contato com nossa equipe."),
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
                    _loginDataStore.setDefaultMunicipio(false);
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _loginDataStore.setMunicipioLocalize(false);
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
