import 'dart:io';

import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/helpers/classes/EstradaPoint.dart';
import 'package:app_itr/helpers/classes/ImovelGeoPoint.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PontoImovelInfoEditPage extends StatefulWidget {
  PontoImovelInfoEditPage({Key? key}) : super(key: key);

  @override
  _PontoImovelInfoEditPage createState() {
    return _PontoImovelInfoEditPage();
  }
}

class _PontoImovelInfoEditPage extends State<PontoImovelInfoEditPage> with SingleTickerProviderStateMixin {
  late LoginDataStore _loginDataStore;
  TextEditingController descricaoController = TextEditingController();
  late AnimationController _animationController;
  late Animation _animation;
  FocusNode _focusNode = FocusNode();
  String tipoPontoValue = "sede";

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: kThemeAnimationDuration, value: 1);
    _animation = Tween(begin: 300.0, end: 50.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _animationController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginDataStore = Provider.of<LoginDataStore>(context);

    descricaoController.value = TextEditingValue(
      text: _loginDataStore.imovelGeoPointDescricao,
      selection: TextSelection.fromPosition(
        TextPosition(offset: _loginDataStore.imovelGeoPointDescricao.length),
      ),
    );

    if (_loginDataStore.imovelGeoPointTipo != "") {
      tipoPontoValue = _loginDataStore.imovelGeoPointTipo;
    }
  }

  final listTipoDePonto = {
    'sede': 'Sede',
    'vertice': 'Vértice',
    'acesso': 'Principal',
  };

  Future<void> _iniciarCaptura() async {
    print(_loginDataStore.imovelGeoPointDescricao);

    ImovelGeoPoint? imovelGeoPoint = new ImovelGeoPoint();
    imovelGeoPoint.sincronizado = 0;
    imovelGeoPoint.descricao = _loginDataStore.imovelGeoPointDescricao;
    imovelGeoPoint.tipo = _loginDataStore.imovelGeoPointTipo;
    imovelGeoPoint.cod_ibge_m = _loginDataStore.m.cod_ibge_m;
    imovelGeoPoint.idLevantamento = _loginDataStore.selectedLevantamento.id;

    _loginDataStore.setImovelTipo(tipoPontoValue);

    print(imovelGeoPoint);

    Navigator.pop(context, "start-${_loginDataStore.selectedLevantamento.tipoLevantamento}-${_loginDataStore.imovelGeoPointTipo}");

    /*
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Sending Message"),
    ));*/
  }

  void _removeFocus() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Observer(
          builder: (_){ return Text(
            _loginDataStore.imovelGeoPointTipo == "sede"
                ? "Editar informações da sede"
                : _loginDataStore.imovelGeoPointTipo == "vertice"
                    ? "Editar informações do vértice"
                    : _loginDataStore.imovelGeoPointTipo == "acesso-principal"
                        ? "Editar informações do acesso principal"
                        : "Editar informações",
            style: FontsStyleCTRM.primaryFontWhite,
          );}
        ),
      ),
      body: GestureDetector(
        onTap: _removeFocus,
        child: Padding(
          padding: EdgeInsets.only(right: 1.0, left: 1.0, bottom: 1.0, top: 1.0),
          child: Container(
            color: ColorsCTRM.primaryColorDarkAlpha66,
            child: Container(
              color: ColorsCTRM.primaryColorDarkAlpha66,
              child: ListView(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 50.0, bottom: 8.0, top: 40),
                      child: Text("DESCRIÇÃO", style: FontsStyleCTRM.primaryFont25SuperDark),
                    ),
                  ),
                  Observer(
                    builder: (_){
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(40, 20, 40, 15),
                        child: TextFormField(
                          onChanged: _loginDataStore.setImovelDescricao,
                          onFieldSubmitted: (value) {
                            print("VALUE: $value");
                          },
                          controller: descricaoController,
                          style: FontsStyleCTRM.primaryFont20Dark,
                          cursorColor: ColorsCTRM.primaryColor,
                          cursorHeight: 20,
                          decoration: InputDecoration(
                              fillColor: Colors.white60,
                              filled: true,
                              hintText: "Descrição",
                              hintStyle: FontsStyleCTRM.primaryFont20Dark,
                              contentPadding: EdgeInsets.symmetric(vertical: 19, horizontal: 25),
                              focusColor: Colors.red,
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: ColorsCTRM.primaryColorHalfDark,
                                  )),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorsCTRM.primaryColor))),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Observer(
        builder: (_) {
          return _loginDataStore.isGeoPointFormValid
              ? Padding(
                  padding: EdgeInsets.only(right: 10, bottom: 10),
                  child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        child: Text(
                          _loginDataStore.imovelGeoPointTipo == "sede"
                              ? "INICIAR CAPTURA DA SEDE"
                              : _loginDataStore.imovelGeoPointTipo == "vertice"
                              ? "INICIAR CAPTURA DO VÉRTICE"
                              : _loginDataStore.imovelGeoPointTipo == "acesso-principal"
                              ? "INICIAR CAPTURA DO ACESSO PRINCIPAL"
                              : "INICIAR CAPTURA",
                          style: FontsStyleCTRM.primaryFontWhite,
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: ColorsCTRM.primaryColor,
                          elevation: 6,
                          shadowColor: ColorsCTRM.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        onPressed: _loginDataStore.isGeoPointFormValid ? _iniciarCaptura : null,
                      )),
                )
              : Container();
        },
      ),
    );
  }
}
