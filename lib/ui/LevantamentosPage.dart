import 'package:app_itr/api/levantamentos_api.dart';
import 'package:app_itr/api/route_api.dart';
import 'package:app_itr/etc/ConnectionChecker.dart';
import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/helpers/classes/ImovelRoute.dart';
import 'package:app_itr/helpers/classes/Levantamento.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import 'AddLevantamentoPage.dart';

class LevantamentosPage extends StatefulWidget {
  LevantamentosPage({Key? key}) : super(key: key);

  @override
  _LevantamentosPageState createState() {
    return _LevantamentosPageState();
  }
}

class _LevantamentosPageState extends State<LevantamentosPage> {
  late LoginDataStore _loginDataStore;
  String routeList = "Lista de Rotas - ";
  DBHelper helper = new DBHelper();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginDataStore = Provider.of<LoginDataStore>(context);
    _loginDataStore.clearRotaEscolarPointList();
    _loginDataStore.clearEstradaPointList();
    refreshLevantamentos();

    // ignore: unrelated_type_equality_checks
  }

  void _closeCurrentActivity(String action) {
    Navigator.pop(context, "$action-${_loginDataStore.selectedLevantamento.tipoLevantamento}");
  }

  void _navigateAndRefresh(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddLevantamentoPage()));

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result == "refresh") {
      refreshLevantamentos();
    }
  }

  String selectedTipo() {
    print("SELECIONADO -> ${_loginDataStore.selectedLevantamento}");

    if (_loginDataStore.selectedLevantamento.tipoLevantamento == "ponte") {
      return "Ponte";
    } else if (_loginDataStore.selectedLevantamento.tipoLevantamento == "estrada") {
      return "Estrada";
    } else if (_loginDataStore.selectedLevantamento.tipoLevantamento == "rota-escolar") {
      return "Rota Escolar";
    } else if (_loginDataStore.selectedLevantamento.tipoLevantamento == "ponto-imovel") {
      return "Ponto de imóvel";
    }

    return "NONE";
  }

  Future<Null> refreshLevantamentos() async {
    var conn = await ConnectionChecker.checkConnection();
    if (conn) {
      DBHelper helper = DBHelper();
      helper.getAllLevantamentos(_loginDataStore);
    } else {
      DBHelper helper = DBHelper();
      helper.getAllLevantamentos(_loginDataStore);
    }
  }

  void setSelectedLevantamento(Levantamento l) {
    print("The levantamento selected is: $l");
    _loginDataStore.setSelectedLevantamento(l);

    if (l.status != "finalizado") {
      _showOptionsDialog();
    } else {
      _showOptionsDialogFinal();
    }
  }

  void setSelectedLevantamentoInfo(Levantamento l) {
    print("The levantamento selected is: $l");
    _loginDataStore.setSelectedLevantamento(l);
    _showInfoDialog(l);
  }

  void _showOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Deseja selecionar o levantamento '${_loginDataStore.selectedLevantamento.descricao}'?",
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
                  _closeCurrentActivity("edit");
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showOptionsDialogFinal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Deseja visualizar o levantamento finalizado '${_loginDataStore.selectedLevantamento.descricao}'?",
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
                  _closeCurrentActivity("show");
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showOptionsDialogSync() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Deseja sincronizar todos os levantamentos?",
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
                  _postLevantamentos();
                  Navigator.of(context).pop();
                },
              ),
            )
          ],
        );
      },
    );
  }

  Future<void> _postLevantamentos() async {
    await postInsertLevantamentos(_loginDataStore).then((value) {
      if (value == "SUCESSO") {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text(
                "Levantamentos sincronizados com sucesso!",
                style: FontsStyleCTRM.primaryFont20Dark,
              ),
              content: Text(""),
              actions: <Widget>[
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
    });
  }

  void _showOfflineDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Não foi possível sincronizar, verifique a conexão com a internet.",
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

  Future<void> _sincronizarTudo() async {
    bool conn = await ConnectionChecker.checkConnection();
    if (conn) {
      _showOptionsDialogSync();
    } else {
      _showOfflineDialog();
    }
  }

  void _novoLevantamento() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Deseja adicionar um novo levantamento?",
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
                  _navigateAndRefresh(context);
                },
              ),
            )
          ],
        );
      },
    );
  }

  void _showInfoDialog(Levantamento l) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Levantamento '${l.descricao}'",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Container(
            height: 100,
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                        child: Row(
                      children: [
                        Text(
                          "Descrição: ",
                          textAlign: TextAlign.start,
                          style: FontsStyleCTRM.primaryFontBoldBlack,
                        ),
                        Flexible(
                            child: Text(
                          "${l.descricao}",
                          style: FontsStyleCTRM.primaryFontBlack,
                        ))
                      ],
                    ))
                  ],
                ),
                Observer(
                  builder: (_) {
                    return Row(
                      children: [
                        Flexible(
                            child: Row(
                          children: [
                            Text(
                              "Tipo do levantamento: ",
                              textAlign: TextAlign.start,
                              style: FontsStyleCTRM.primaryFontBoldBlack,
                            ),
                            Flexible(
                                child: Text(
                              selectedTipo(),
                              style: FontsStyleCTRM.primaryFontBlack,
                            ))
                          ],
                        ))
                      ],
                    );
                  },
                ),
                Observer(
                  builder: (_) {
                    return Row(
                      children: [
                        Flexible(
                            child: Row(
                          children: [
                            Text(
                              "Sincronizado com o sistema?",
                              textAlign: TextAlign.start,
                              style: FontsStyleCTRM.primaryFontBoldBlack,
                            ),
                            Flexible(
                                child: Text(
                              _loginDataStore.isLevantamentoSincronizado ? "SIM" : "NÃO",
                              style: FontsStyleCTRM.primaryFontBlack,
                            ))
                          ],
                        ))
                      ],
                    );
                  },
                ),
                Row(
                  children: [
                    Flexible(
                        child: Row(
                      children: [
                        Text(
                          "Status: ",
                          textAlign: TextAlign.start,
                          style: FontsStyleCTRM.primaryFontBoldBlack,
                        ),
                        Flexible(
                            child: Text(
                          l.status!.capitalize(),
                          style: FontsStyleCTRM.primaryFontBlack,
                        ))
                      ],
                    ))
                  ],
                )
              ],
            ),
          ),
          actions: <Widget>[
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
                  // ignore: unnecessary_statements
                  _navigateAndRefresh;
                },
              ),
            )

          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Levantamentos - " + _loginDataStore.m.municipio_plus_uf(),
        style: FontsStyleCTRM.primaryFontWhite,
      )),
      body: Container(
        color: ColorsCTRM.primaryColorDarkAlpha66,
        child: Padding(
          padding: EdgeInsets.only(right: 1.0, left: 1.0, bottom: 100.0, top: 1.0),
          child: Container(
            child: Observer(builder: (_) {
              return RefreshIndicator(
                  child: ListView.builder(
                    itemCount: _loginDataStore.levantamentosList.length,
                    itemBuilder: (_, index) {
                      return Container(
                        height: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  _loginDataStore.levantamentosList[index].tipoLevantamento == "ponte" ?
                                  'assets/images/foto-ponte.jpg' :
                                  _loginDataStore.levantamentosList[index].tipoLevantamento == "estrada" ?
                                  'assets/images/foto-estrada.jpg' :
                                  _loginDataStore.levantamentosList[index].tipoLevantamento == "ponto-imovel" ?
                                  'assets/images/foto-imovel.jpg' :
                                  _loginDataStore.levantamentosList[index].tipoLevantamento == "rota-escolar" ?
                                  'assets/images/foto-rota-escolar.jpg' :
                                      ''
                              ),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                            color: ColorsCTRM.primaryColor,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
                            ]),
                        child: Stack(children: [
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setSelectedLevantamento(_loginDataStore.levantamentosList[index]),
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 20,
                                          child: ListTile(
                                            title: Text(
                                              '${_loginDataStore.levantamentosList[index].status!.toUpperCase()}',
                                              style: _loginDataStore.levantamentosList[index].status == "aberto"
                                                  ? FontsStyleCTRM.primaryFontListSpacingBlue
                                                  : _loginDataStore.levantamentosList[index].status == "finalizado"
                                                      ? FontsStyleCTRM.primaryFontListSpacingGreen
                                                      : null,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 20,
                                          child: ListTile(
                                            title: Text(
                                              '${_loginDataStore.levantamentosList[index].descricao}',
                                              style: FontsStyleCTRM.primaryFontListSpacing,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 20,
                            top: 15,
                            child: TextButton(
                                onPressed: () => setSelectedLevantamentoInfo(_loginDataStore.levantamentosList[index]),
                                child: Icon(
                                  Icons.info_rounded,
                                  size: 55,
                                  color: Colors.white,
                                )),
                          ),
                          Observer(builder: (_) {
                            return Positioned(
                              right: 5,
                              top: 5,
                              height: 25,
                              width: 25,
                              child: _loginDataStore.levantamentosList[index].sincronizado == 1
                                  ? Icon(
                                      Icons.check_circle,
                                      color: Colors.lightGreenAccent,
                                    )
                                  : Icon(
                                      Icons.remove_circle,
                                      color: ColorsCTRM.primaryColorComplementary,
                                    ),
                            );
                          })
                        ]),
                      );
                    },
                  ),
                  // ignore: missing_return
                  onRefresh: refreshLevantamentos);
            }),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: FloatingActionButton(
              child: Icon(Icons.sync),
              onPressed: _sincronizarTudo,
              backgroundColor: ColorsCTRM.primaryColor,
            ),
          ),
          Spacer(),
          FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: _novoLevantamento,
            backgroundColor: ColorsCTRM.primaryColor,
          )
        ],
      ),
    );
  }
}
