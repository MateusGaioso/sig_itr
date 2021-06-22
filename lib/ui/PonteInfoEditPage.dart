import 'dart:io';

import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/helpers/classes/PontePoint.dart';
import 'package:app_itr/helpers/classes/RotaEscolarPoint.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class PonteInfoEditPage extends StatefulWidget {
  PonteInfoEditPage({Key? key}) : super(key: key);

  @override
  _PonteInfoEditPage createState() {
    return _PonteInfoEditPage();
  }
}

class _PonteInfoEditPage extends State<PonteInfoEditPage> with SingleTickerProviderStateMixin {
  late LoginDataStore _loginDataStore;
  TextEditingController descricaoController = TextEditingController();
  TextEditingController extensaoAproximadaController = TextEditingController();
  TextEditingController rioRiachoController = TextEditingController();
  late AnimationController _animationController;
  late Animation _animation;
  FocusNode _focusNode = FocusNode();
  String estadoDeConservacaoValue = "otimo";
  String materialValue = "alvenaria";

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
      text: _loginDataStore.ponteDescricao,
      selection: TextSelection.fromPosition(
        TextPosition(offset: _loginDataStore.ponteDescricao.length),
      ),
    );

    extensaoAproximadaController.value = TextEditingValue(
      text: _loginDataStore.ponteExtensaoAproximada,
      selection: TextSelection.fromPosition(
        TextPosition(offset: _loginDataStore.ponteExtensaoAproximada.length),
      ),
    );

    rioRiachoController.value = TextEditingValue(
      text: _loginDataStore.ponteRioRiacho,
      selection: TextSelection.fromPosition(
        TextPosition(offset: _loginDataStore.ponteRioRiacho.length),
      ),
    );

    if (_loginDataStore.ponteEstadoConservacao != "") {
      estadoDeConservacaoValue = _loginDataStore.ponteEstadoConservacao;
    }
    if (_loginDataStore.ponteMaterial != "") {
      materialValue = _loginDataStore.ponteMaterial;
    }
  }

  final listEstadoDeConservacao = {
    'otimo': 'Ótimo',
    'regular': 'Regular',
    'bom': 'Bom',
    'ruim': 'Ruim',
  };

  final listMaterial = {
    'alvenaria': 'Alvenaria',
    'metalica': 'Metálica',
    'madeira': 'Madeira',
  };

  Future<void> _iniciarCaptura() async {
    print(_loginDataStore.ponteDescricao);
    print(_loginDataStore.ponteEstadoConservacao);
    print(_loginDataStore.ponteMaterial);
    print(_loginDataStore.ponteExtensaoAproximada);
    print(_loginDataStore.ponteRioRiacho);

    PontePoint? pontePoint = new PontePoint();
    pontePoint.sincronizado = 0;
    pontePoint.descricao = _loginDataStore.ponteDescricao;
    pontePoint.estadoConservacao = estadoDeConservacaoValue;
    pontePoint.material = materialValue;
    pontePoint.extensaoAproximada = _loginDataStore.ponteExtensaoAproximada.replaceAll(",", '.');
    pontePoint.nomeRioRiacho = _loginDataStore.ponteRioRiacho;
    pontePoint.cod_ibge_m = _loginDataStore.m.cod_ibge_m;
    pontePoint.idLevantamento = _loginDataStore.selectedLevantamento.id;


    if(_loginDataStore.selectedPontePoint != null){

        DBHelper db = new DBHelper();

        _loginDataStore.selectedPontePoint!.descricao = _loginDataStore.ponteDescricao;
        _loginDataStore.selectedPontePoint!.estadoConservacao = estadoDeConservacaoValue;
        _loginDataStore.selectedPontePoint!.material = materialValue;
        _loginDataStore.selectedPontePoint!.extensaoAproximada = _loginDataStore.ponteExtensaoAproximada.replaceAll(",", '.');
        _loginDataStore.selectedPontePoint!.nomeRioRiacho = _loginDataStore.ponteRioRiacho;


        db.updatePonte( _loginDataStore.selectedPontePoint!);

    }


    _loginDataStore.setPonteMaterial(materialValue);
    _loginDataStore.setPonteEstadoConservacao(estadoDeConservacaoValue);

    print(pontePoint);

    Navigator.pop(context, "start-${_loginDataStore.selectedLevantamento.tipoLevantamento}");

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
        title: Text(
          "Editar informações da ponte",
          style: FontsStyleCTRM.primaryFontWhite,
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 15),
                    child: TextFormField(
                      onChanged: _loginDataStore.setPonteDescricao,
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
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 50.0, bottom: 8.0),
                      child: Text(
                        "ESTADO DE CONSERVAÇÃO",
                        style: FontsStyleCTRM.primaryFont25SuperDark,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 15),
                    child: Container(
                      height: 55.0,
                      decoration: BoxDecoration(border: Border.all(color: ColorsCTRM.primaryColor), borderRadius: BorderRadius.circular(12), color: Colors.white60),
                      child: DropdownButton<String>(
                        value: estadoDeConservacaoValue,
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
                        onChanged: (String? newValue) {
                          setState(() {
                            estadoDeConservacaoValue = newValue!;
                            _loginDataStore.setPonteEstadoConservacao(estadoDeConservacaoValue);
                            print("dropdownValue = $estadoDeConservacaoValue");
                          });
                        },
                        onTap: _removeFocus,
                        items: listEstadoDeConservacao.entries
                            .map<DropdownMenuItem<String>>((MapEntry<String, String> e) => DropdownMenuItem<String>(
                                  value: e.key,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 25),
                                    child: Text(
                                      e.value,
                                      style: FontsStyleCTRM.primaryFont20Dark,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 50.0, bottom: 8.0),
                      child: Text(
                        "MATERIAL",
                        style: FontsStyleCTRM.primaryFont25SuperDark,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 15),
                    child: Container(
                      height: 55.0,
                      decoration: BoxDecoration(border: Border.all(color: ColorsCTRM.primaryColor), borderRadius: BorderRadius.circular(12), color: Colors.white60),
                      child: DropdownButton<String>(
                        value: materialValue,
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
                        onChanged: (String? newValue) {
                          setState(() {
                            materialValue = newValue!;
                            _loginDataStore.setPonteMaterial(materialValue);
                            print("dropdownValue = $materialValue");
                          });
                        },
                        onTap: _removeFocus,
                        items: listMaterial.entries
                            .map<DropdownMenuItem<String>>((MapEntry<String, String> e) => DropdownMenuItem<String>(
                                  value: e.key,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 25),
                                    child: Text(
                                      e.value,
                                      style: FontsStyleCTRM.primaryFont20Dark,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 50.0, bottom: 8.0, top: 20),
                      child: Text("EXTENSÃO APROXIMADA (m)", style: FontsStyleCTRM.primaryFont25SuperDark),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 15),
                    child: TextFormField(
                      controller: extensaoAproximadaController,
                      onChanged: _loginDataStore.setPonteExtensaoAproximada,
                      onFieldSubmitted: (value) {
                        print("VALUE: $value");
                      },
                      style: FontsStyleCTRM.primaryFont20Dark,
                      cursorColor: ColorsCTRM.primaryColor,
                      cursorHeight: 20,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          fillColor: Colors.white60,
                          filled: true,
                          hintText: "0.0",
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
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 50.0, bottom: 8.0, top: 20),
                      child: Text("NOME DO RIO/RIACHO", style: FontsStyleCTRM.primaryFont25SuperDark),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 15),
                    child: TextFormField(
                      controller: rioRiachoController,
                      onChanged: _loginDataStore.setPonteRioRiacho,
                      onFieldSubmitted: (value) {
                        print("VALUE: $value");
                      },
                      style: FontsStyleCTRM.primaryFont20Dark,
                      cursorColor: ColorsCTRM.primaryColor,
                      cursorHeight: 20,
                      decoration: InputDecoration(
                          fillColor: Colors.white60,
                          filled: true,
                          hintText: "Nome do rio/riacho",
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Observer(
        builder: (_) {
          return _loginDataStore.isPonteFormValid
              ? Padding(
                  padding: EdgeInsets.only(right: 10, bottom: 10),
                  child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        child: Text(
                          "INICIAR CAPTURA DA PONTE",
                          style: FontsStyleCTRM.primaryFontWhite,
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: ColorsCTRM.primaryColor,
                          elevation: 6,
                          shadowColor: ColorsCTRM.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        onPressed: _loginDataStore.isPonteFormValid ? _iniciarCaptura : null,
                      )),
                )
              : Container();
        },
      ),
    );
  }
}
