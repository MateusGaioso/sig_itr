import 'dart:async';

import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/helpers/classes/user.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'LoginPage.dart';
import 'SelectCityPage.dart';

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
    User u = (await helper.getLoggedUser())!;

    _loginDataStore.setUser(u);

    // ignore: unnecessary_null_comparison
    if(u == null){
      _loginDataStore.loggedIn = false;
    } else{
      _loginDataStore.loggedIn = true;
    }

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

  void rebuild() {
    setState(() async {
      if(_loginDataStore.loggedIn){
        await _getCities().then((value) =>  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SelectCityPage())));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    });
  }

  Future<String> _getCities() async {
    var response = await helper.getAllMunicipiosByUserList(_loginDataStore);
    print("GETCITIES RESPONSE -> $response");
    return "Success";
  }
}


