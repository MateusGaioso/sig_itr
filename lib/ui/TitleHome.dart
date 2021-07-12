import 'dart:async';

import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/helpers/classes/AppData.dart';
import 'package:app_itr/helpers/classes/RegiaoAdministrativa.dart';
import 'package:app_itr/helpers/classes/user.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'LoginPage.dart';
import 'SelectCityPage.dart';
import 'SelectSystemPage.dart';

class TitleHome extends StatefulWidget {
  @override
  _TitleHomeState createState() => _TitleHomeState();
}

class _TitleHomeState extends State<TitleHome> {

  DBHelper helper = DBHelper();
  late LoginDataStore _loginDataStore;


  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    _loginDataStore = Provider.of<LoginDataStore>(context);
    User? u = await helper.getLoggedUser();


    // ignore: unnecessary_null_comparison
    if(u == null){
      print("NOT LOGGED");
      _loginDataStore.loggedIn = false;
    } else{
      print("LOGGED");
      _loginDataStore.setUser(u);
      _loginDataStore.loggedIn = true;
    }

    helper.getAppData().then((value){
      if(value == null){
        AppData appData = AppData();
        appData.idPushMessage = 0;
        appData.pushMessage = null;
        appData.cod_ibge_m = null;
        appData.isImoveisListByUFLoaded = 0;
        appData.isMunicipiosListByUFLoaded = 0;
        helper.saveAppData(appData).then((value){

          RegiaoAdministrativa regiaoAdministrativa = RegiaoAdministrativa();
          regiaoAdministrativa.cod_ibge_m = "";
          regiaoAdministrativa.idSistema = -1;
          regiaoAdministrativa.idSistemaMunicipio = -1;
          regiaoAdministrativa.nome = "TODAS";
          helper.saveRegiaoAdmnistrativa(regiaoAdministrativa).then((value){
            helper.getAllRegAdmByCodIbgeM(_loginDataStore, "");
          });

          _loginDataStore.setAppData(value);

          print("APP DATA NULL");
          print(appData);
        });

      } else{
        print("APP DATA NOT NULL");
        print(value);
        _loginDataStore.setAppData(value);
        helper.getAllRegAdmByCodIbgeM(_loginDataStore, _loginDataStore.appData.cod_ibge_m!);

      }

    });



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
              child: Image(image: AssetImage('assets/images/logo_verde.png')),
              onTap: () {
              }
          )

        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      rebuild();
    });
  }

  Future<void> rebuild() async {
    if(_loginDataStore.loggedIn){
      await _getCities().then((value) =>  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SelectCityPage())));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SelectSystemPage()));
    }
  }

  Future<String> _getCities() async {
    var response = await helper.getAllMunicipiosByUserList(_loginDataStore);
    print("GETCITIES RESPONSE -> $response");
    return "Success";
  }

}


