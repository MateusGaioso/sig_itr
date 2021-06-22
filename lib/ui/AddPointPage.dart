import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/helpers/classes/imovel.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:app_itr/ui/SyncPointPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class AddPointPage extends StatefulWidget {
  AddPointPage({Key? key}) : super(key: key);

  @override
  _AddPointPageState createState() {
    return _AddPointPageState();
  }
}

class _AddPointPageState extends State<AddPointPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    if(_loginDataStore.isImovelUsing){
      Imovel im = _loginDataStore.imovel;
      im.listGeoPoints = im.getGeoPointsId();
      im.idSistemaUser = _loginDataStore.u.idSistema;
      im.idSistemaMunicipio = _loginDataStore.m.idSistema;
      print("DISPOSED IMOVEL -> $im");
      helper.saveImovel(im);
      _loginDataStore.setImovel(new Imovel(false));
    }

  }


  @override
  void didChangeDependencies() {
    _loginDataStore = Provider.of<LoginDataStore>(context);
    _loginDataStore.setImovel(im);
  }

  List<bool> _selections = List.generate(3, (_) => false);
  late LoginDataStore _loginDataStore;
  Imovel im = new Imovel(false);
  DBHelper helper = new DBHelper();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Adicionar Ponto"),
      ),
      body: Container(
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
                      padding: EdgeInsets.only(bottom: 100),
                      child: Icon(
                        Icons.add_location_alt_outlined,
                        size: 150,
                      ),
                    )
                  ]),
                  TableRow(children: [
                    Text(
                      "Coletar Ponto",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32),
                    )
                  ]),
                  TableRow(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 40, bottom: 40),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                            ),
                            child: ToggleButtons(
                              borderWidth: 3,
                              borderRadius: BorderRadius.circular(30),
                              selectedColor: ColorsCTRM.primaryColorDark,
                              splashColor: ColorsCTRM.primaryColorDark,
                              color: ColorsCTRM.primaryColor,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                                  child: Text(
                                    "Vértices",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                                  child: Text(
                                    "Acesso Principal",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                                  child: Text(
                                    "Sede",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                              isSelected: _selections,
                              onPressed: (int index) {
                                setState(() {
                                  _selections[index] = !_selections[index];
                                  _loginDataStore.setTipo(index);

                                  Navigator.push(
                                      context, MaterialPageRoute(builder: (context) => SyncPointPage()));
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    )
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
