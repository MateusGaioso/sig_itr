import 'package:app_itr/api/route_api.dart';
import 'package:app_itr/etc/ConnectionChecker.dart';
import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/helpers/classes/ImovelRoute.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class RouteListPage extends StatefulWidget {
  RouteListPage({Key? key}) : super(key: key);

  @override
  _RouteListPageState createState() {
    return _RouteListPageState();
  }
}

class _RouteListPageState extends State<RouteListPage> {
  late LoginDataStore _loginDataStore;
  String routeList = "LISTA DE ROTAS - ";
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
    // ignore: unrelated_type_equality_checks
    refreshImovelRoutes();
  }

  Future<Null> refreshImovelRoutes() async {
    var conn = await ConnectionChecker.checkConnection();
    if (conn) {
      return getImovelRoutes(_loginDataStore).then((list) {});
    } else {
      DBHelper helper = DBHelper();
      helper.getAllImovelRoutes(_loginDataStore);
    }
  }

  void setSelectedRoute(ImovelRoute i) {
    print("The route selected is: $i");
    _loginDataStore.setSelectedImovelRoute(i);
    _showOptionsDialog();
  }

  void _closeCurrentActivity() {
    Navigator.pop(context, "ROUTE SEL");
  }

  void _showOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Deseja selecionar a rota '${_loginDataStore.selectedImovelRoute.nome_imovel}'?", style: FontsStyleCTRM.primaryFont20Dark,),
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

  void _showInfoDialog(ImovelRoute i) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Informações".toUpperCase() , style: FontsStyleCTRM.primaryFont20Dark,),
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
                          "Nome da fazenda: ",
                          textAlign: TextAlign.start,
                          style: FontsStyleCTRM.primaryFontBoldBlack,
                        ),
                        Flexible(
                            child: Text(
                          "${i.nome_imovel}",
                                style: FontsStyleCTRM.primaryFontBlack,
                        ))
                      ],
                    ))
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Flexible(
                        child: Row(
                      children: [
                        Text(
                          "Origem da consulta: ",
                          textAlign: TextAlign.start,
                          style: FontsStyleCTRM.primaryFontBoldBlack,
                        ),
                        Flexible(
                            child: Text(
                          "${i.origem_consulta}",
                                style: FontsStyleCTRM.primaryFontBlack,
                        ))
                      ],
                    ))
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Flexible(
                        child: Row(
                      children: [
                        Text(
                          "Município de localização: ",
                          textAlign: TextAlign.start,
                          style: FontsStyleCTRM.primaryFontBoldBlack,
                        ),
                        Flexible(
                            child: Text(
                          "${_loginDataStore.m.nome} - ${_loginDataStore.m.sigla_uf}",
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(routeList + _loginDataStore.m.municipio_plus_uf(), style: FontsStyleCTRM.primaryFontWhite,),
        ),
        body: Padding(
          padding: EdgeInsets.all(0),
          child: Container(
            color: Colors.white,
            child: Observer(builder: (_) {
              return RefreshIndicator(
                  child: ListView.builder(
                    itemCount: _loginDataStore.imovelRouteList.length,
                    itemBuilder: (_, index) {
                      return Container(
                        height: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0)), color: ColorsCTRM.primaryColorAnalogBlue, boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
                        ]),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                child: ListTile(
                                  title: Text(
                                    '${_loginDataStore.imovelRouteList[index].nome_imovel}',
                                    style: FontsStyleCTRM.primaryFontListSpacing,
                                  ),
                                  onTap: () => setSelectedRoute(_loginDataStore.imovelRouteList[index]),
                                ),
                              ),
                            ),
                            TextButton(
                                onPressed: () => _showInfoDialog(_loginDataStore.imovelRouteList[index]),
                                child: Icon(
                                  Icons.info_rounded,
                                  size: 55,
                                  color: Colors.white,
                                ))
                          ],
                        ),
                      );
                    },
                  ),
                  // ignore: missing_return
                  onRefresh: refreshImovelRoutes);
            }),
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    _loginDataStore.selectedImovelRoute = ImovelRoute();
    Navigator.pop(context);


    throw true;
  }

}
