import 'dart:developer';

import 'package:app_itr/api/login_api.dart';
import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/helpers/classes/user.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:app_itr/ui/SelectCityPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const entrar = "Entrar";
const _url = 'https://wa.me/message/G6GKTCI5H5UFB1';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userController = TextEditingController();
  TextEditingController passController = TextEditingController();

  late LoginDataStore _loginDataStore;

  DBHelper helper = DBHelper();
  late String _token;
  late String user;
  late String pass;
  String textUser = "";
  String errorLogin = "";
  late User u;
  late BuildContext dialogContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _loginDataStore = Provider.of<LoginDataStore>(context);
    _getUserLocation();
  }

  _getUserLocation() async {
    print("GET USER LOCATION");
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    print(position)
;  }


  void _login() async {

    print("entrou login");

    showDialog(context: context, barrierDismissible: false, builder: (context) {
      dialogContext = context;
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

    user = userController.text;
    pass = passController.text;
    // ignore: non_constant_identifier_names
    Future TokenFuture = returnToken(user, pass).catchError((error) {
      print("Error ocurred: $errorLogin");

      setState(() {
        textUser = "Error ocurred: $errorLogin";

        Navigator.pop(dialogContext);

        showDialog(context: context, builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0)),
            elevation: 16,
            child: Container(
              height: 140.0,
              width: 360.0,
              child: ListView(
                children: <Widget>[
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Usuário e/ou senha inválidos",
                      style: TextStyle(
                          fontSize: 20.0, color: Color(0xFF12a19a)),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Text(
                        "Por favor, verifique novamente seu usuário e/ou senha ou se há conexão com a internet."),)
                ],
              ),
            ),
          );
        });
      });


    });

    _token = await TokenFuture;

    if (_token != null) {
      print("TOKEN BEFORE $_token");

      u = await helper.saveUser(await returnUserData(_token, user, pass));

      print("THE TOKEN $_token");

      // ignore: unnecessary_null_comparison
      if (u.id != null) {

        Navigator.pop(dialogContext);
        FocusScope.of(context).unfocus();
        LoggedUser lg = LoggedUser();
        lg.idSistema = u.idSistema;
        await helper.saveLoggedUser(lg);
        _loginDataStore.login();
        _loginDataStore.setUser(u);

        await _getCities().then((value) =>  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SelectCityPage())));




      } else {
        print("Is null");
      }
    }
  }

  Future<String> _getCities() async {
    var response = await helper.getAllMunicipiosByUserList(_loginDataStore);
    print("GETCITIES RESPONSE -> $response");
    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Image(
                        image: AssetImage('assets/images/logo_verde.png'))),
                Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: "Usuário",
                          labelStyle:  FontsStyleCTRM.primaryFont,),
                      textAlign: TextAlign.center,
                      controller: userController,
                      style: FontsStyleCTRM.primaryFont,
                    )),
                Padding(
                    padding:
                    EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      enableSuggestions: false,
                      autocorrect: false,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: "Senha",
                          labelStyle:  FontsStyleCTRM.primaryFont,),
                      textAlign: TextAlign.center,
                      controller: passController,
                      style: FontsStyleCTRM.primaryFont,
                    )),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                    primary: ColorsCTRM.primaryColorAlphaAA, // background
                    onPrimary: Colors.white, // foreground
                  ),
                    onPressed: _login,
                    child: Text(
                      entrar.toUpperCase(),
                      style: FontsStyleCTRM.primaryFontWhite,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Ainda não tem acesso? Clique aqui.", style: FontsStyleCTRM.primaryFont,),
                      ],
                    ),
                    onTap: _launchURL,
                  ),
                ),
              ]),
        ));
  }

  void _launchURL() async =>
      await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
}
