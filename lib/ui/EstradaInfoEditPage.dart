import 'dart:io';

import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/helpers/classes/EstradaPoint.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EstradaInfoEditPage extends StatefulWidget {
  EstradaInfoEditPage({Key? key}) : super(key: key);

  @override
  _EstradaInfoEditPageState createState() {
    return _EstradaInfoEditPageState();
  }
}

class _EstradaInfoEditPageState extends State<EstradaInfoEditPage> with SingleTickerProviderStateMixin {
  late LoginDataStore _loginDataStore;
  TextEditingController rodoviaController = TextEditingController();
  TextEditingController trechoController = TextEditingController();
  TextEditingController larguraController = TextEditingController();
  late AnimationController _animationController;
  late Animation _animation;
  FocusNode _focusNode = FocusNode();
  String estadoDeConservacaoValue = "otimo";
  String tipoDePavimentacaoValue = "asfalto";
  String jurisdicaoValue = "municipal";

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

    rodoviaController.value = TextEditingValue(
      text: _loginDataStore.estradaRodovia,
      selection: TextSelection.fromPosition(
        TextPosition(offset: _loginDataStore.estradaRodovia.length),
      ),
    );

    trechoController.value = TextEditingValue(
      text: _loginDataStore.estradaTrecho,
      selection: TextSelection.fromPosition(
        TextPosition(offset: _loginDataStore.estradaTrecho.length),
      ),
    );

    larguraController.value = TextEditingValue(
      text: _loginDataStore.estradaLarguraAproximada,
      selection: TextSelection.fromPosition(
        TextPosition(offset: _loginDataStore.estradaLarguraAproximada.length),
      ),
    );

    if (_loginDataStore.estradaEstadoDeConservacao != "") {
      estadoDeConservacaoValue = _loginDataStore.estradaEstadoDeConservacao;
    }
    if (_loginDataStore.estradaTipoDePavimentacao != "") {
      tipoDePavimentacaoValue = _loginDataStore.estradaTipoDePavimentacao;
    }
    if (_loginDataStore.estradaJurisdicao != "") {
      jurisdicaoValue = _loginDataStore.estradaJurisdicao;
    }
  }

  final listEstadoDeConservacao = {
    'otimo': 'Ótimo',
    'regular': 'Regular',
    'bom': 'Bom',
    'ruim': 'Ruim',
  };

  final listTipoDePavimentacao = {
    'asfalto': 'Asfalto',
    'concreto': 'Concreto',
    'paralelepipedo': 'Paralelepípedo',
    'leito-natural': 'Leito Natural',
  };

  final listJurisdicao = {
    'municipal': 'Municipal',
    'estadual': 'Estadual',
    'federal': 'Federal',
  };

  Future<void> _iniciarCaptura() async {
    print(_loginDataStore.estradaRodovia);
    print(_loginDataStore.estradaTrecho);
    print(_loginDataStore.estradaJurisdicao);
    print(_loginDataStore.estradaEstadoDeConservacao);
    print(_loginDataStore.estradaTipoDePavimentacao);
    print(_loginDataStore.estradaLarguraAproximada);

    EstradaPoint? estradaPoint = new EstradaPoint();
    estradaPoint.sincronizado = 0;
    estradaPoint.rodovia = _loginDataStore.estradaRodovia;
    estradaPoint.trecho = _loginDataStore.estradaTrecho;
    estradaPoint.jurisdicao = jurisdicaoValue;
    estradaPoint.estado_conservacao = estadoDeConservacaoValue;
    estradaPoint.tipo_pavimentacao = tipoDePavimentacaoValue;
    estradaPoint.largura_aproximada = _loginDataStore.estradaLarguraAproximada.replaceAll(",", '.');
    estradaPoint.cod_ibge_m = _loginDataStore.m.cod_ibge_m;
    estradaPoint.idLevantamento = _loginDataStore.selectedLevantamento.id;

    _loginDataStore.setEstradaConservacao(estadoDeConservacaoValue);
    _loginDataStore.setEstradaPavimentacao(tipoDePavimentacaoValue);
    _loginDataStore.setEstradaJurisdicao(jurisdicaoValue);

    print(estradaPoint);

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
          "Editar informações da estrada",
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
                      child: Text("RODOVIA", style: FontsStyleCTRM.primaryFont25SuperDark),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 15),
                    child: TextFormField(
                      onChanged: _loginDataStore.setEstradaRodovia,
                      onFieldSubmitted: (value) {
                        print("VALUE: $value");
                      },
                      controller: rodoviaController,
                      style: FontsStyleCTRM.primaryFont20Dark,
                      cursorColor: ColorsCTRM.primaryColor,
                      cursorHeight: 20,
                      decoration: InputDecoration(
                          fillColor: Colors.white60,
                          filled: true,
                          hintText: "Rodovia",
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
                      child: Text("TRECHO", style: FontsStyleCTRM.primaryFont25SuperDark),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 15),
                    child: TextFormField(
                      onChanged: _loginDataStore.setEstradaTrecho,
                      onFieldSubmitted: (value) {
                        print("VALUE: $value");
                      },
                      controller: trechoController,
                      style: FontsStyleCTRM.primaryFont20Dark,
                      cursorColor: ColorsCTRM.primaryColor,
                      cursorHeight: 20,
                      decoration: InputDecoration(
                          fillColor: Colors.white60,
                          filled: true,
                          hintText: "Trecho",
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
                        "JURISDIÇÃO",
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
                        value: jurisdicaoValue,
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
                            jurisdicaoValue = newValue!;
                            _loginDataStore.setEstradaJurisdicao(jurisdicaoValue);
                            print("dropdownValue = $jurisdicaoValue");
                          });
                        },
                        onTap: _removeFocus,
                        items: listJurisdicao.entries
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
                            _loginDataStore.setEstradaConservacao(estadoDeConservacaoValue);
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
                        "TIPO DE PAVIMENTAÇÃO",
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
                        value: tipoDePavimentacaoValue,
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
                            tipoDePavimentacaoValue = newValue!;
                            _loginDataStore.setEstradaPavimentacao(tipoDePavimentacaoValue);
                            print("dropdownValue = $tipoDePavimentacaoValue");
                          });
                        },
                        onTap: _removeFocus,
                        items: listTipoDePavimentacao.entries
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
                      child: Text("LARGURA APROXIMADA (m)", style: FontsStyleCTRM.primaryFont25SuperDark),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 15),
                    child: TextFormField(
                      controller: larguraController,
                      onChanged: _loginDataStore.setEstradaLargura,
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
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Observer(
        builder: (_) {
          return _loginDataStore.isEstradaFormValid
              ? Padding(
                  padding: EdgeInsets.only(right: 10, bottom: 10),
                  child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        child: Text(
                          "INICIAR CAPTURA DA ESTRADA",
                          style: FontsStyleCTRM.primaryFontWhite,
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: ColorsCTRM.primaryColor,
                          elevation: 6,
                          shadowColor: ColorsCTRM.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        onPressed: _loginDataStore.isEstradaFormValid ? _iniciarCaptura : null,
                      )),
                )
              : Container();
        },
      ),
    );
  }
}
