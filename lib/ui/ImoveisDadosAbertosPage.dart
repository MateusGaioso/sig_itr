import 'dart:async';
import 'dart:io';

import 'package:app_itr/api/dados_abertos_api.dart';
import 'package:app_itr/api/route_api.dart';
import 'package:app_itr/etc/ConnectionChecker.dart';
import 'package:app_itr/etc/CircleProgress.dart';
import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/helpers/classes/ImovelDadosAbertos.dart';
import 'package:app_itr/helpers/classes/ImovelRoute.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:app_itr/ui/DadosAbertosMapPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const _url = 'https://wa.me/message/G6GKTCI5H5UFB1';

class ImoveisDadosAbertosPage extends StatefulWidget {
  ImoveisDadosAbertosPage({Key? key}) : super(key: key);

  @override
  _ImoveisDadosAbertosPage createState() {
    return _ImoveisDadosAbertosPage();
  }
}

class _ImoveisDadosAbertosPage extends State<ImoveisDadosAbertosPage> with TickerProviderStateMixin {
  late LoginDataStore _loginDataStore;
  String routeList = "LISTA DE IMÓVEIS - ";
  DBHelper helper = new DBHelper();
  double topContainer = 0;
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();
  bool closeButton = false;
  late AnimationController _progressController;
  late Animation<double> _animation;
  late AnimationController _progressController2;
  late Animation<double> _animation2;
  late AnimationController _containerController;
  late Animation<double> _animationContainer;
  double opacity = 0;
  double opacity2 = 0;
  String _carregandoImoveisText = "Carregando imóveis...";
  String _gerandoPoligonosText = "Gerando Polígonos...";
  int _auxCounter = 0;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      double value = _scrollController.offset / 220;

      setState(() {
        topContainer = value;
        closeButton = _scrollController.offset > 220;
      });
    });

    _progressController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    _animation = Tween<double>(begin: 0, end: 100).animate(_progressController)
      ..addListener(() {
        setState(() {});
      });
    _progressController2 = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    _animation2 = Tween<double>(begin: 0, end: 100).animate(_progressController2)
      ..addListener(() {
        setState(() {});
      });
    _containerController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        //_animationController.forward();
      } else {
        //_animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _loginDataStore.resetSearchValue();
    _loginDataStore.setTotalImoveisCounter(-1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginDataStore = Provider.of<LoginDataStore>(context);
    helper.getAppData().then((value) {
      _loginDataStore.setAppData(value!);
    });

    refreshImoveis();

    if (_loginDataStore.isImoveisListToStart) {
      _scrollController.animateTo(0.0, curve: Curves.easeOut, duration: const Duration(milliseconds: 100)).then((value) {
        _loginDataStore.setImoveisListStartPosition(false);
      });
    }
    // ignore: unrelated_type_equality_checks
  }

  void _removeFocus() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  void rotate(bool forward) {
    Timer(Duration(milliseconds: 1000), () {
      setState(() {
        if (!_loginDataStore.isImovelPolygonsCounterFinished) {
          if (_auxCounter == 0) {
            _carregandoImoveisText = "Carregando Imóveis..";
            _gerandoPoligonosText = "Gerando Polígonos..";
            _auxCounter++;
          } else if (_auxCounter == 1) {
            _carregandoImoveisText = "Carregando Imóveis.";
            _gerandoPoligonosText = "Gerando Polígonos.";
            _auxCounter++;
          } else if (_auxCounter == 2) {
            _carregandoImoveisText = "Carregando Imóveis";
            _gerandoPoligonosText = "Gerando Polígonos";
            _auxCounter++;
          } else if (_auxCounter == 3) {
            _carregandoImoveisText = "Carregando Imóveis.";
            _gerandoPoligonosText = "Gerando Polígonos.";
            _auxCounter++;
          } else if (_auxCounter == 4) {
            _carregandoImoveisText = "Carregando Imóveis..";
            _gerandoPoligonosText = "Gerando Polígonos..";
            _auxCounter++;
          } else if (_auxCounter == 5) {
            _carregandoImoveisText = "Carregando Imóveis...";
            _gerandoPoligonosText = "Gerando Polígonos...";
            _auxCounter = 0;
          }

          if (forward) {
            _containerController.forward();
            rotate(false);
          } else {
            _containerController.reverse();
            rotate(true);
          }
        }
      });
    });
  }

  Future<Null> refreshImoveis() async {
    if (_loginDataStore.isImoveisDownloadStarted) {
      print("Download already started");
    } else {
      helper.getAppData().then((value) async {
        if (value!.isImoveisListByUFLoaded == 1) {
          print("IMOVEIS LOADED");
        } else {
          print("IMOVEIS NOT LOADED");
          var conn = await ConnectionChecker.checkConnection();
          if (conn) {
            DadosAbertosAPI(_loginDataStore, helper).getImoveisCount().then((value) {
              Timer(Duration(milliseconds: 100), () {
                setState(() {
                  opacity = 1;
                  rotate(true);
                });
              });
              print("COUNT FINISHED: ${_loginDataStore.totalImoveisDownload}");
              _loginDataStore.setImovelCounter(0);
              _loginDataStore.setImovelPolygonCounter(0);
              _loginDataStore.setStartImoveisDownload(true);
              _animation = Tween<double>(begin: _loginDataStore.counterImoveisDownload.toDouble(), end: _loginDataStore.totalImoveisDownload.toDouble()).animate(_progressController)
                ..addListener(() {
                  setState(() {});
                });
              _animation2 = Tween<double>(begin: _loginDataStore.counterImoveisPolygons.toDouble(), end: _loginDataStore.totalImoveisDownload.toDouble()).animate(_progressController2)
                ..addListener(() {
                  setState(() {
                    rotate(true);
                  });
                });
              DadosAbertosAPI(_loginDataStore, helper).getImoveisByMunicipio(_progressController, _progressController2).then((list) {});
            });
          } else {
            DBHelper helper = DBHelper();
            helper.getAllImoveisDadosAbertosByMunicipio(_loginDataStore);
          }
        }
      });
    }
  }

  _setSelectedImovel(ImovelDadosAbertos i) {
    _removeFocus();
    print("The imovel selected is: ${i.nome_imovel}");
    _loginDataStore.setSelectedImovelDadosAbertos(i);
    _showOptionsDialog();
  }

  void _closeCurrentActivity() async {
    bool conn = await ConnectionChecker.checkConnection();
    _loginDataStore.setImoveisListStartPosition(true);
    BuildContext? _dialogContext;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          _dialogContext = context;
          return WillPopScope(
            onWillPop: () => Future.value(false),
            child: Dialog(
              elevation: 16,
              backgroundColor: Color(0x0012a19a),
              child: Align(
                heightFactor: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 30.0,
                      width: 30.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        strokeWidth: 2.0,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "CARREGANDO ROTA...",
                      style: FontsStyleCTRM.primaryFont19White,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);

    if (_loginDataStore.selectedImovelDadosAbertos.geomRota != null) {
      if (conn) {
        DadosAbertosAPI(_loginDataStore, helper).getUserRoute(position, _loginDataStore.selectedImovelDadosAbertos.idSistema!).then((route) {
          Navigator.pop(_dialogContext!);
          Navigator.push(context, MaterialPageRoute(builder: (context) => DadosAbertosMapPage(userRoute: route)));
        }).onError((error, stackTrace) {
          print("ERRO $error -> $stackTrace");
          Navigator.pop(_dialogContext!);
          Navigator.push(context, MaterialPageRoute(builder: (context) => DadosAbertosMapPage()));
        });
      } else {
        _loginDataStore.setOfflineMessage(true);
        Navigator.pop(_dialogContext!);
        Navigator.push(context, MaterialPageRoute(builder: (context) => DadosAbertosMapPage()));
      }
    } else {
      if (conn) {
        DadosAbertosAPI(_loginDataStore, helper).getUserRoute(position, _loginDataStore.selectedImovelDadosAbertos.idSistema!).then((route) {
          Navigator.pop(_dialogContext!);
          Navigator.push(context, MaterialPageRoute(builder: (context) => DadosAbertosMapPage(userRoute: route)));
        }).onError((error, stackTrace) {
          print("ERRO $error -> $stackTrace");
          DadosAbertosAPI(_loginDataStore, helper).getImovelDadosAbertosRoute(_loginDataStore.selectedImovelDadosAbertos.idSistema!).then((value) {
            print(value);
            Navigator.pop(_dialogContext!);
            Navigator.push(context, MaterialPageRoute(builder: (context) => DadosAbertosMapPage()));
          });
        });
      } else {
        _loginDataStore.setOfflineMessage(true);
        Navigator.pop(_dialogContext!);
        Navigator.push(context, MaterialPageRoute(builder: (context) => DadosAbertosMapPage()));
      }
    }
  }

  void _showOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Deseja selecionar o imóvel '${_loginDataStore.selectedImovelDadosAbertos.nome_imovel}'?",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
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
                  _closeCurrentActivity();
                },
              ),
            )
          ],
        );
      },
    );
  }

  void _showInfoDialog(ImovelDadosAbertos i) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Informações".toUpperCase(),
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Wrap(
                        runSpacing: 4,
                        children: [
                          Text(
                            "Nome da fazenda: ",
                            textAlign: TextAlign.start,
                            style: FontsStyleCTRM.primaryFontBoldBlack,
                          ),
                          Text(
                            "${i.nome_imovel}",
                            style: FontsStyleCTRM.primaryFontBlack,
                          )
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Flexible(
                      child: Wrap(
                        runSpacing: 4,
                        children: [
                          Text(
                            "Região administrativa: ",
                            textAlign: TextAlign.start,
                            style: FontsStyleCTRM.primaryFontBoldBlack,
                          ),
                          Text(
                            i.reg_adm == "null" ? "Sem região administrativa".toUpperCase() : "${_loginDataStore.regAdm.nome}",
                            style: FontsStyleCTRM.primaryFontBlack,
                          )
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Flexible(
                      child: Wrap(
                        runSpacing: 4,
                        children: [
                          Text(
                            "Município de localização: ",
                            textAlign: TextAlign.start,
                            style: FontsStyleCTRM.primaryFontBoldBlack,
                          ),
                          Text(
                            "${_loginDataStore.m.nome} - ${_loginDataStore.m.sigla_uf}",
                            style: FontsStyleCTRM.primaryFontBlack,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // define os botões na base do dialogo
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    "VOLTAR",
                    style: FontsStyleCTRM.primaryFontWhite,
                  ),
                ),
                style: ElevatedButton.styleFrom(primary: ColorsCTRM.primaryColor),
                onPressed: () {
                  Navigator.of(context).pop();
                  _removeFocus();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Stack(
        children: [
          Observer(
            builder: (_) {
              return Scaffold(
                appBar: AppBar(
                  title: Container(
                    child: _loginDataStore.isImovelSearching
                        ? _imovelSearchWidget()
                        : Flex(direction: Axis.horizontal, children: [
                            Flexible(
                              child: RichText(
                                maxLines: 2,
                                text: TextSpan(
                                  text: "IMÓVEIS - " + _loginDataStore.m.municipio_plus_uf(),
                                  style: FontsStyleCTRM.primaryFontWhite,
                                ),
                              ),
                            ),
                          ]),
                  ),
                  actions: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: Observer(
                        builder: (_) {
                          return _loginDataStore.isImovelSearching
                              ? Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.search_off,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        _loginDataStore.stopSearching();
                                      },
                                    ),
                                  ],
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    _loginDataStore.startSearching();
                                  },
                                );
                        },
                      ),
                    )
                  ],
                ),
                body: Padding(
                  padding: EdgeInsets.all(0),
                  child: Container(
                    color: ColorsCTRM.primaryColorDarkAlpha66,
                    child: Observer(builder: (_) {
                      return Container(
                          child: _loginDataStore.isImovelDataLoaded
                              ? listImoveisWidget()
                              : _loginDataStore.isImoveisDownloadStarted
                                  ? _loginDataStore.isImovelCounterFinished
                                      ? _loginDataStore.isImovelPolygonsCounterFinished
                                          ? listImoveisWidget()
                                          : AnimatedOpacity(
                                              duration: const Duration(milliseconds: 2000),
                                              opacity: opacity2,
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 2000),
                                                height: _loginDataStore.isImoveisDownloadStarted ? MediaQuery.of(context).size.height : 300,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 500,
                                                      child: CustomPaint(
                                                        foregroundPainter: CircleProgress(_animation2.value, _loginDataStore), // this will add custom painter after child
                                                        child: Container(
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              print(_loginDataStore.totalImoveisDownload);
                                                            },
                                                            child: RotationTransition(
                                                              turns: Tween(begin: -0.005, end: 0.005).animate(_containerController),
                                                              child: Center(
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Text("${_animation2.value.toInt()} / ${_loginDataStore.totalImoveisDownload}", style: FontsStyleCTRM.primaryFont20Dark),
                                                                    Container(
                                                                      height: 10,
                                                                    ),
                                                                    Text("${((_animation2.value.toInt() / _loginDataStore.totalImoveisDownload) * 100).toStringAsFixed(2)} %", style: FontsStyleCTRM.primaryFont25SuperDark),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      _gerandoPoligonosText.toUpperCase(),
                                                      style: FontsStyleCTRM.primaryFont20Dark,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                      : AnimatedOpacity(
                                          duration: const Duration(milliseconds: 2000),
                                          opacity: opacity,
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 2000),
                                            height: _loginDataStore.isImoveisDownloadStarted ? MediaQuery.of(context).size.height : 300,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: 500,
                                                  child: CustomPaint(
                                                    foregroundPainter: CircleProgress(_animation.value, _loginDataStore), // this will add custom painter after child
                                                    child: Container(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          print(_loginDataStore.totalImoveisDownload);
                                                        },
                                                        child: RotationTransition(
                                                          turns: Tween(begin: -0.005, end: 0.005).animate(_containerController),
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Text("${_animation.value.toInt()} / ${_loginDataStore.totalImoveisDownload}", style: FontsStyleCTRM.primaryFont20Dark),
                                                                Container(
                                                                  height: 10,
                                                                ),
                                                                Text("${((_animation.value.toInt() / _loginDataStore.totalImoveisDownload) * 100).toStringAsFixed(2)} %", style: FontsStyleCTRM.primaryFont25SuperDark),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  _carregandoImoveisText.toUpperCase(),
                                                  style: FontsStyleCTRM.primaryFont20Dark,
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                  : listImoveisWidget());
                    }),
                  ),
                ),
                floatingActionButton: Opacity(
                  opacity: 0.85,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    height: closeButton ? 60 : 0,
                    child: FloatingActionButton(
                      child: closeButton ? Icon(Icons.arrow_upward) : Container(),
                      shape: RoundedRectangleBorder(),
                      backgroundColor: ColorsCTRM.primaryColorAnalogBlue,
                      onPressed: () {
                        _scrollController.animateTo(
                          0.0,
                          curve: Curves.easeOut,
                          duration: const Duration(milliseconds: 2000),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          Observer(builder: (_) {
            return Positioned(
              left: 20,
              bottom: 20,
              child: _loginDataStore.isImovelCounterFinished
                  ? _loginDataStore.isImoveisDownloadStarted
                      ? FloatingActionButton.extended(
                          heroTag: "btn1",
                          backgroundColor: Colors.white,
                          onPressed: null,
                          label: Row(
                            children: [
                              CircularProgressIndicator(),
                              Container(
                                width: 20,
                              ),
                              Text(
                                "CARREGANDO LISTA",
                                style: FontsStyleCTRM.primaryFont,
                              )
                            ],
                          ),
                        )
                      : Container()
                  : Container(),
            );
          }),
        ],
      ),
    );
  }

  Widget listImoveisWidget() {
    if (_loginDataStore.imovelDadosAbertosList.where((element) => element.nome_imovel!.toUpperCase().contains(_loginDataStore.searchImovelValue.toUpperCase())).toList().isEmpty) {
      print("VAZIO");
      return Container(
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: GestureDetector(
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Não encontrou o que procurava? Fale agora com a equipe do suporte. Clique aqui.",
                    style: FontsStyleCTRM.primaryFont20Dark,
                  ),
                ),
              ],
            ),
            onTap: _launchURL,
          ),
        ),
      );
    } else {
      print("CHEIO");
      return RefreshIndicator(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _loginDataStore.imovelDadosAbertosList.where((element) => element.nome_imovel!.toUpperCase().contains(_loginDataStore.searchImovelValue.toUpperCase())).length,
            itemBuilder: (_, index) {
              print("INDEX $index");
              double scale = 1.0;
              if (topContainer > 0) {
                scale = index + 1 - topContainer;
                if (scale < 0) {
                  scale = 0;
                } else if (scale > 1) {
                  scale = 1;
                }
              }

              double padding_bottom = 10.0;

              if (index == _loginDataStore.imovelDadosAbertosList.where((element) => element.nome_imovel!.toUpperCase().contains(_loginDataStore.searchImovelValue.toUpperCase())).length - 1) {
                padding_bottom = 40;
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _setSelectedImovel(_loginDataStore.imovelDadosAbertosList.where((element) => element.nome_imovel!.toUpperCase().contains(_loginDataStore.searchImovelValue.toUpperCase())).toList()[index]);
                      },
                      child: Opacity(
                        opacity: scale,
                        child: Transform(
                          transform: Matrix4.identity()..scale(scale, scale),
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            child: Container(
                              height: 200,
                              margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: padding_bottom),
                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0)), color: ColorsCTRM.primaryColor, boxShadow: [
                                BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
                              ]),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      child: ListTile(
                                        title: Text(
                                          '${_loginDataStore.imovelDadosAbertosList.where((element) => element.nome_imovel!.toUpperCase().contains(_loginDataStore.searchImovelValue.toUpperCase())).toList()[index].nome_imovel}',
                                          style: FontsStyleCTRM.primaryFontListSpacing,
                                        ),
                                        onTap: () {
                                          _setSelectedImovel(_loginDataStore.imovelDadosAbertosList.where((element) => element.nome_imovel!.toUpperCase().contains(_loginDataStore.searchImovelValue.toUpperCase())).toList()[index]);
                                        },
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                      onPressed: () => _showInfoDialog(_loginDataStore.imovelDadosAbertosList.where((element) => element.nome_imovel!.toUpperCase().contains(_loginDataStore.searchImovelValue.toUpperCase())).toList()[index]),
                                      child: Icon(
                                        Icons.info_rounded,
                                        size: 55,
                                        color: Colors.white,
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 200),
                      child: GestureDetector(
                        child: Wrap(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                "Não encontrou o que procurava? Fale agora com a equipe do suporte. Clique aqui.",
                                style: FontsStyleCTRM.primaryFont20Dark,
                              ),
                            ),
                          ],
                        ),
                        onTap: _launchURL,
                      ),
                    )
                  ],
                );
              } else {
                return GestureDetector(
                  onTap: () {
                    _setSelectedImovel(_loginDataStore.imovelDadosAbertosList.where((element) => element.nome_imovel!.toUpperCase().contains(_loginDataStore.searchImovelValue.toUpperCase())).toList()[index]);
                  },
                  child: Opacity(
                    opacity: scale,
                    child: Transform(
                      transform: Matrix4.identity()..scale(scale, scale),
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        child: Container(
                          height: 200,
                          margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: padding_bottom),
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0)), color: ColorsCTRM.primaryColor, boxShadow: [
                            BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
                          ]),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        '${_loginDataStore.imovelDadosAbertosList.where((element) => element.nome_imovel!.toUpperCase().contains(_loginDataStore.searchImovelValue.toUpperCase())).toList()[index].nome_imovel}',
                                        style: FontsStyleCTRM.primaryFontListSpacing,
                                      ),
                                    ),
                                    onTap: () {
                                      _setSelectedImovel(_loginDataStore.imovelDadosAbertosList.where((element) => element.nome_imovel!.toUpperCase().contains(_loginDataStore.searchImovelValue.toUpperCase())).toList()[index]);
                                    },
                                  ),
                                ),
                              ),
                              TextButton(
                                  onPressed: () => _showInfoDialog(_loginDataStore.imovelDadosAbertosList.where((element) => element.nome_imovel!.toUpperCase().contains(_loginDataStore.searchImovelValue.toUpperCase())).toList()[index]),
                                  child: Icon(
                                    Icons.info_rounded,
                                    size: 55,
                                    color: Colors.white,
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          // ignore: missing_return
          onRefresh: refreshImoveis);
    }
  }

  void _launchURL() async => await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';

  Future<bool> _onBackPressed() async {
    if (_loginDataStore.isImoveisDownloadStarted) {
      print("WAIT");
    } else {
      print("MUNICIPIO -> ${_loginDataStore.m}");
      await helper.getMunicipioByCodIbge(_loginDataStore.m.cod_ibge_m!).then((value) async {
        _loginDataStore.setMunicipio(value!);
        await helper.getAllMunicipiosByUF(_loginDataStore).then((value) {
          Navigator.pop(context);
        });
      });
    }
    return false;
  }

  Widget _imovelSearchWidget() {
    bool collapsed = false;
    double padding_value = 10.0;
    if (Platform.isAndroid) {
      collapsed = true;
      padding_value = 16.0;
    }

    return TextFormField(
      onChanged: (value) {
        _loginDataStore.setSearchValue(value);
        _scrollController.animateTo(
          0.0,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 200),
        );
      },
      controller: _searchController,
      style: FontsStyleCTRM.primaryFont20Dark,
      cursorColor: ColorsCTRM.primaryColor,
      cursorHeight: 30,
      decoration: InputDecoration(
          fillColor: Colors.white70,
          filled: true,
          hintText: "PESQUISAR IMÓVEL",
          hintStyle: FontsStyleCTRM.primaryFont18Dark,
          isCollapsed: collapsed,
          isDense: true,
          contentPadding: new EdgeInsets.only(top: 10.0, bottom: padding_value, left: 15.0, right: 15.0),
          focusColor: Colors.red,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: ColorsCTRM.primaryColorHalfDark,
              )),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: ColorsCTRM.primaryColor))),
    );
  }
}

class TextBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.white,
      child: TextField(
        decoration: InputDecoration(border: InputBorder.none, hintText: 'Search'),
      ),
    );
  }
}
