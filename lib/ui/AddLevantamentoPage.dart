import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/helpers/classes/Levantamento.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddLevantamentoPage extends StatefulWidget {
  AddLevantamentoPage({Key? key}) : super(key: key);

  @override
  _AddLevantamentoPageState createState() {
    return _AddLevantamentoPageState();
  }
}

class _AddLevantamentoPageState extends State<AddLevantamentoPage> {

  TextEditingController descricaoController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  late LoginDataStore _loginDataStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginDataStore = Provider.of<LoginDataStore>(context);
    // ignore: unrelated_type_equality_checks
  }

  String dropdownValue = 'estrada';

  final listTipo = {
    'estrada': 'Estrada',
    'rota-escolar': 'Rota escolar',
    'ponte': 'Ponte',
    'ponto-imovel': 'Ponto de imóvel',
  };

  final focusNode = FocusNode();

  void adicionarLevantamento(){
    DBHelper db = new DBHelper();

    Levantamento levantamento = new Levantamento();
    levantamento.descricao = _loginDataStore.levantamentoDescricao;
    levantamento.tipoLevantamento = dropdownValue;
    levantamento.idSistemaUser = _loginDataStore.u.idSistema;
    levantamento.idSistemaMunicipio = _loginDataStore.m.idSistema;
    levantamento.status = "aberto";
    levantamento.sincronizado = 0;

    print("LEVANTAMENTO SAVED -> ${levantamento.toString()}");

    db.saveLevantamento(levantamento);

    Navigator.pop(context, "refresh");

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "NOVO LEVANTAMENTO",
          style: GoogleFonts.concertOne(),
        ),
      ),
      body: GestureDetector(
        onTap: (){descricaoController.clear();},
        child: Padding(
          padding: EdgeInsets.only(right: 1.0, left: 1.0, bottom: 1.0, top: 1.0),
          child: Container(
            color: ColorsCTRM.primaryColorDarkAlpha66,
            child: Container(
              color: ColorsCTRM.primaryColorDarkAlpha66,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top:50.0, left: 50.0, bottom: 8.0),
                      child: Text("TIPO", style: GoogleFonts.concertOne(fontSize: 25, color: ColorsCTRM.primaryColorSuperDark),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 15),
                    child: Container(
                      height: 55.0,
                      decoration: BoxDecoration(border: Border.all(color: ColorsCTRM.primaryColor), borderRadius: BorderRadius.circular(12), color: Colors.white60),
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 20, top: 8),
                          child: Icon(Icons.arrow_drop_down_sharp, color: ColorsCTRM.primaryColor,),
                        ),
                        iconSize: 24,
                        underline: Container(),
                        elevation: 16,
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                            print("dropdownValue = $dropdownValue");
                          });
                        },
                        items:listTipo.entries
                            .map<DropdownMenuItem<String>>(
                                (MapEntry<String, String> e) => DropdownMenuItem<String>(
                              value: e.key,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Text(e.value, style: GoogleFonts.concertOne(color: ColorsCTRM.primaryColorDark, fontSize: 20),),
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
                      child: Text("DESCRIÇÃO", style: GoogleFonts.concertOne(fontSize: 25, color: ColorsCTRM.primaryColorSuperDark),
                      ),
                    ),
                  ),
                  Observer(
                    builder: (_){
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(40, 20, 40, 15),
                        child: TextFormField(
                          onChanged: _loginDataStore.setLevantamentoDescricao,
                          onFieldSubmitted: (value){
                            print("VALUE: $value");
                            descricaoController.clear();
                          },
                          style: GoogleFonts.concertOne(color: ColorsCTRM.primaryColorDark, fontSize: 20),
                          cursorColor: ColorsCTRM.primaryColor,
                          cursorHeight: 20,
                          decoration: InputDecoration(
                              fillColor: Colors.white60,
                              filled: true,
                              hintText: "Descrição",
                              hintStyle: GoogleFonts.concertOne(color: ColorsCTRM.primaryColorDark, fontSize: 20),
                              contentPadding: EdgeInsets.symmetric(vertical: 19, horizontal: 25),
                              focusColor: Colors.red,
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: ColorsCTRM.primaryColorHalfDark,
                                  )
                              ),
                              enabledBorder:  OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: ColorsCTRM.primaryColor)
                              )

                          ),
                        ),
                      );
                    }
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Observer(
        builder: (_){
          return Padding(
            padding: EdgeInsets.only(right: 10, bottom: 10),
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                child: Text(
                  "ADICIONAR",
                  style: GoogleFonts.concertOne(),
                ),
                style: ElevatedButton.styleFrom(
                  primary: ColorsCTRM.primaryColor,
                  elevation: 6,
                  shadowColor: ColorsCTRM.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                onPressed: _loginDataStore.isLevantamentoFormValid ? adicionarLevantamento : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
