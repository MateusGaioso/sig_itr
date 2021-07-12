import 'dart:async';
import 'dart:developer';

import 'package:app_itr/api/dados_abertos_api.dart';
import 'package:app_itr/api/login_api.dart';
import 'package:app_itr/etc/ConnectionChecker.dart';
import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/helpers/classes/AppData.dart';
import 'package:app_itr/helpers/classes/Estado.dart';
import 'package:app_itr/helpers/classes/Municipio.dart';
import 'package:app_itr/helpers/classes/user.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:app_itr/ui/DadosAbertosPage.dart';
import 'package:app_itr/ui/LoginPage.dart';
import 'package:app_itr/ui/SelectCityPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const entrar = "Entrar";
const _url = 'https://wa.me/message/G6GKTCI5H5UFB1';

class SelectSystemPage extends StatefulWidget {
  @override
  _SelectSystemPageState createState() => _SelectSystemPageState();
}

class _SelectSystemPageState extends State<SelectSystemPage> {
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
  BuildContext? _dialogContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _loginDataStore = Provider.of<LoginDataStore>(context);
    //_getUserLocation();
  }

  Future<Position> _getUserLocation() async {
    print("GET USER LOCATION");
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    _loginDataStore.setUserPosition(position);
    print(position);
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
          backgroundColor: Colors.white,
          body: Stack(children: [
            SingleChildScrollView(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 20.0, right: 20.0), child: Image(image: AssetImage('assets/images/logo_verde.png'))),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: ColorsCTRM.primaryColorAnalogBlue, // background
                      onPrimary: Colors.white, // foreground
                    ),
                    onPressed: _dadosAbertos,
                    child: Container(
                      height: 60,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            "DADOS ABERTOS",
                            style: FontsStyleCTRM.primaryFont22White,
                          ),
                        ),
                      ),
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
                        Text(
                          "Para mais informações, clique aqui.",
                          style: FontsStyleCTRM.primaryFont18Dark,
                        ),
                      ],
                    ),
                    onTap: _launchURL,
                  ),
                )
              ]),
            ),
          ])),
    ]);
  }

  void _launchURL() async => await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';

  Future<void> _dadosAbertos() async {
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
            ),
          );
        });

    _getUserLocation().then((value) {
      Timer(Duration(milliseconds: 300), () {
        print("TIMER ON");

        _getMunicipioDataChecking();
      });
    });
  }

  _getMunicipioDataChecking() {
    ConnectionChecker.checkConnection().then((conn) {
      if (conn) {
        helper.deleteAllMunicipios(_loginDataStore).then((i) {
          helper.deleteAllEstados(_loginDataStore).then((j) {
            DadosAbertosAPI(_loginDataStore, helper).getEstados().then((value) {
              helper.getAllEstados(_loginDataStore);
            });
            Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation).then((position) {
              print("GETTING POSITION");
              print("CONNECTED");
              DadosAbertosAPI(_loginDataStore, helper).getMunicipioByLocation(position).then((value) {
                print("VALUE---> $value");
                if (value.idSistema == null) {
                  DadosAbertosAPI(_loginDataStore, helper).getDefaultMunicipio().then((defaultM) {
                    _getMunicipioData(defaultM);
                  });
                } else {
                  _getMunicipioData(value);
                }
              });
            });
          });
        });

      } else {
        helper.getAllEstados(_loginDataStore);
        print("NOT CONNECTED");
        helper.getMunicipioByCodIbge(_loginDataStore.appData.cod_ibge_m!).then((value) {
          _loginDataStore.setMunicipio(value!);
          _loginDataStore.setEstado(_loginDataStore.estadosList.firstWhere((element) => element.sigla_uf == value.cod_ibge_m));
          helper.getAllRegAdmByCodIbgeM(_loginDataStore, value.cod_ibge_m!);
          Navigator.pop(_dialogContext!);
          Navigator.push(context, MaterialPageRoute(builder: (context) => DadosAbertosPage()));
        });
      }
    });
  }

  _getMunicipioData(Municipio value) async {

    DadosAbertosAPI(_loginDataStore, helper).getRegAdmByMunicipio(value.cod_ibge_m!).then((value) async {
      Estado? e = await helper.getEstadoByUF(_loginDataStore.m.sigla_uf!.toUpperCase());
      _loginDataStore.setEstado(e!);

      DadosAbertosAPI(_loginDataStore, helper).getMunicipiosByUF(_loginDataStore.m.sigla_uf!).then((value) {
        _loginDataStore.setAppDataMunicipiosLoaded(1);
        helper.updateAppData(_loginDataStore.appData);
        print("TIMER OFF");
        Navigator.pop(_dialogContext!);
        Navigator.push(context, MaterialPageRoute(builder: (context) => DadosAbertosPage()));
      }).onError((error, stackTrace) {
        print("ERROR -> $error -- $stackTrace");
        _loginDataStore.setAppDataMunicipiosLoaded(0);
        helper.updateAppData(_loginDataStore.appData);
      });
    });
  }
}
