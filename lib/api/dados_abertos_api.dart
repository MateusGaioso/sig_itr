import 'dart:developer';

import 'package:app_itr/etc/PolygonGenerator.dart';
import 'package:app_itr/etc/StaticUrls.dart';
import 'package:app_itr/helpers/classes/Estado.dart';
import 'package:app_itr/helpers/classes/ImovelDadosAbertos.dart';
import 'package:app_itr/helpers/classes/RegiaoAdministrativa.dart';
import 'package:app_itr/helpers/classes/Municipio.dart';
import 'dart:convert';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:flutter/animation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'dart:convert' show utf8;

class DadosAbertosAPI{

  DBHelper _helper;
  LoginDataStore _loginDataStore;

  DadosAbertosAPI(this._loginDataStore, this._helper);

  static const Duration _duration = Duration(seconds: 30);


  Future<Municipio> getMunicipioByLocation(Position position, {String? hasNextUrl}) async {
    print("init");

    Client c = Client();

    Response response;

    String finalUrl = url_municipioByLocation + "?longitude=${position.longitude.toString()}&latitude=${position.latitude.toString()}";
    print("URL-> $finalUrl");
    Uri finalUri = Uri.parse(finalUrl);

    if (hasNextUrl == null) {
      response = await c.get(finalUri, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }).timeout(_duration);
    } else {
      response = await c.get(Uri.parse(hasNextUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }).timeout(_duration);
    }

    print(response);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      final List data = jsonDecode(response.body);

      for (int i = 0; i < data.length; i++) {
        Municipio m = Municipio();
        try {
          m.idSistema = data[i]["id"];
          m.nome = utf8.decode(data[i]["nome"].toString().runes.toList());
          m.sigla_uf = data[i]["sigla_uf"];
          m.cod_ibge_m = data[i]["cod_ibge_m"];
          m.slug = utf8.decode(data[i]["slug"].toString().runes.toList());
          m.latitude = data[i]["lat_sede"].toString();
          m.longitude = data[i]["lng_sede"].toString();
          Municipio? municipio = await _helper.saveMunicipio(m);
          print(municipio);
          _loginDataStore.setMunicipio(municipio!);
          _loginDataStore.setAppDataCodIbge(m.cod_ibge_m);
          _helper.updateAppData(_loginDataStore.appData);

        } catch (e) {
          throw Exception("ERROR->  $e");
        }
      }

      return _loginDataStore.m;

    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      print(response.statusCode);
      throw Exception('Failed to load Municipio');
    }
  }

  Future<List<Municipio>> getMunicipiosByUF(String uf, {String? hasNextUrl}) async {

    _loginDataStore.clearMunicipioList();

    Client c = Client();
    Response response;

    String finalUrl = url_municipiosByUF + "$uf";
    Uri finalUri = Uri.parse(finalUrl);

    if (hasNextUrl == null) {
      response = await c.get(finalUri, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }).timeout(_duration);
    } else {
      response = await c.get(Uri.parse(hasNextUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }).timeout(_duration);
    }

    print(response);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.


      final List data = jsonDecode(response.body);

      for (int i = 0; i < data.length; i++) {
        Municipio m = Municipio();
        try {
          m.idSistema = data[i]["id"];
          m.nome = utf8.decode(data[i]["nome"].toString().runes.toList());
          m.sigla_uf = data[i]["sigla_uf"];
          m.cod_ibge_m = data[i]["cod_ibge_m"];
          m.slug = utf8.decode(data[i]["slug"].toString().runes.toList());
          m.latitude = data[i]["lat_sede"].toString();
          m.longitude = data[i]["lng_sede"].toString();
        } catch (e) {
          print("ERROR->  $e");
          m = Municipio();
        } finally {
          Municipio municipio = (await _helper.saveMunicipio(m))!;
          _loginDataStore.addMunicipioList(municipio);
          print(municipio);
        }
      }

      return _loginDataStore.municipiosList;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      print(response.statusCode);
      throw Exception('Failed to load Municipio');
    }
  }

  Future<List<Estado>> getEstados({String? hasNextUrl}) async {

    _loginDataStore.clearEstadosList();

    Client c = Client();
    Response response;

    if (hasNextUrl == null) {
      response = await c.get(uri_estados, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }).timeout(_duration);
    } else {
      response = await c.get(Uri.parse(hasNextUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }).timeout(_duration);
    }

    print(response);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      final List data = jsonDecode(response.body);

      for (int i = 0; i < data.length; i++) {
        Estado estado = Estado();
        try {
          estado.idSistema = data[i]["id"];
          estado.nome = utf8.decode(data[i]["nome"].toString().runes.toList());
          estado.sigla_uf = data[i]["abreviacao"];
        } catch (e) {
          print("ERROR->  $e");
          estado = Estado();
        } finally {
          _helper.saveEstado(estado).then((value){
            print(value);
          });
        }
      }

      return _loginDataStore.estadosList;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      print(response.statusCode);
      throw Exception('Failed to load Estados');
    }
  }

  Future<List<RegiaoAdministrativa>> getRegAdmByMunicipio(String cod_ibge_m, {String? hasNextUrl}) async {

    _loginDataStore.clearRegAdmListAndKeepFirst();

    Client c = Client();
    Response response;

    String finalUrl = url_regAdm + "$cod_ibge_m";
    Uri finalUri = Uri.parse(finalUrl);
    print("URL -> $finalUrl");


    if (hasNextUrl == null) {
      response = await c.get(finalUri, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }).timeout(_duration);
    } else {
      response = await c.get(Uri.parse(hasNextUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }).timeout(_duration);
    }

    print(response);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      final List data = jsonDecode(response.body)["results"];

      for (int i = 0; i < data.length; i++) {
        RegiaoAdministrativa regiaoAdministrativa = RegiaoAdministrativa();
        print("DATA $i -> ${data[i]}");
        try {
          regiaoAdministrativa.idSistema = data[i]["id"];
          regiaoAdministrativa.nome = utf8.decode(data[i]["nome"].toString().runes.toList());
          regiaoAdministrativa.idSistemaMunicipio = data[i]["municipio"];
          regiaoAdministrativa.cod_ibge_m = utf8.decode(data[i]["cod_ibge_m"].toString().runes.toList());
        } catch (e) {
          print("ERROR->  $e");
          regiaoAdministrativa = RegiaoAdministrativa();
        } finally {
          RegiaoAdministrativa? regAdm = await _helper.saveRegiaoAdmnistrativa(regiaoAdministrativa);
          _loginDataStore.addRegAdmList(regAdm!);
          print(regAdm);
        }
      }

      List regList = await _helper.getAllRegAdmByCodIbgeM(_loginDataStore, cod_ibge_m);
      print("List -> $regList");

      return _loginDataStore.regiaoAdministrativaList;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      print(response.statusCode);
      throw Exception('Failed to load Região Administrativa');
    }
  }

  Future<List<Municipio>> getImoveisByMunicipio(AnimationController progressController, AnimationController progressController2, {String? hasNextUrl}) async {

    _loginDataStore.clearMunicipioList();

    Client c = Client();
    Response response;

    String? cod_ibge_m = _loginDataStore.m.cod_ibge_m;

    print("COD IBGE $cod_ibge_m");

    String finalUrl = "";

    if(_loginDataStore.regAdm.nome == "TODAS"){
      finalUrl = url_imoveisByMunicipio + "?cod_ibge_m=$cod_ibge_m&format=json&limit=${_loginDataStore.totalImoveisDownload}";
    } else{
      finalUrl = url_imoveisByMunicipio + "?cod_ibge_m=$cod_ibge_m&format=json&limit=${_loginDataStore.totalImoveisDownload}&reg_adm=${_loginDataStore.regAdm.idSistema}";
    }


    print("URL FINAL -> $finalUrl");
    Uri finalUri = Uri.parse(finalUrl);

    if (hasNextUrl == null) {
      response = await c.get(finalUri, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }).timeout(_duration);
    } else {
      response = await c.get(Uri.parse(hasNextUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }).timeout(_duration);
    }

    print(response);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      String? hasNext = jsonDecode(response.body)["next"];

      if(hasNext != null){
        print("HAS NEXT $hasNext");
        getImoveisByMunicipio(progressController, progressController2, hasNextUrl: hasNext);

      } else{

      }

      _loginDataStore.setTotalImoveisCounter(jsonDecode(response.body)["count"]);

      final List features = jsonDecode(response.body)["results"]["features"];

      for (int i = 0; i < features.length; i++) {
        _loginDataStore.imovelCounterAdd();
        progressController.value = _loginDataStore.counterImoveisDownload.toDouble()/_loginDataStore.totalImoveisDownload.toDouble();
        ImovelDadosAbertos im = ImovelDadosAbertos();
        try{
          im.idSistema = features[i]["id"];
          im.idSistemaBaseConsolidada = features[i]["properties"]["base_consolidada_id"];
          im.nome_imovel = utf8.decode(features[i]["properties"]["nome_imove"].toString().runes.toList());
          im.cod_imovel = utf8.decode(features[i]["properties"]["cod_imovel"].toString().runes.toList());
          im.num_certif = utf8.decode(features[i]["properties"]["num_certif"].toString().runes.toList());
          im.car = utf8.decode(features[i]["properties"]["car"].toString().runes.toList());
          im.reg_adm = utf8.decode(features[i]["properties"]["reg_adm"].toString().runes.toList());
          im.cod_ibge_m = utf8.decode(features[i]["properties"]["cod_ibge_m"].toString().runes.toList());
          im.sincronizado = 1;

          final List pontoCoordList = features[i]["geometry"]["coordinates"];
          LatLngWithAngle pontoImovel = LatLngWithAngle(pontoCoordList[0], pontoCoordList[1]);

          im.geom = pontoImovel;
        } catch(e){

          print(e);
          im = ImovelDadosAbertos();

        }  finally{

          if(im.idSistema != null){
            //im.geomMultipolygon = await getImovelBounds(loginDataStore, im.idSistemaBaseConsolidada!);
            im = await _helper.saveImovelDadosAbertos(im);
            im = ImovelDadosAbertos();
          }
        }
      }


      if(_loginDataStore.counterImoveisDownload == _loginDataStore.totalImoveisDownload){

        startImoveisBounds(progressController2);

      }

      return _loginDataStore.municipiosList;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      print(response.statusCode);
      throw Exception('Failed to load Municipio');
    }
  }

  startImoveisBounds(AnimationController progressController2){

    _helper.getAllImoveisDadosAbertosByMunicipio(_loginDataStore).then((value) async {
    _loginDataStore.setImovelPolygonCounter(_loginDataStore.totalImoveisDownload);

    getImovelBounds(progressController2);

    });

  }

  Future<void> getImovelBounds(AnimationController progressController2, {String? hasNextUrl}) async {

    Client c = Client();

    Response response;

    String? cod_ibge_m = _loginDataStore.m.cod_ibge_m;

    print("COD IBGE $cod_ibge_m");

    String finalUrl = "";

    if(_loginDataStore.regAdm.nome == "TODAS"){
      finalUrl = url_imovelBounds + "?cod_ibge_m=$cod_ibge_m&format=json&limit=${_loginDataStore.totalImoveisDownload}";
    } else{
      finalUrl = url_imovelBounds + "?cod_ibge_m=$cod_ibge_m&format=json&limit=${_loginDataStore.totalImoveisDownload}&reg_adm=${_loginDataStore.regAdm.idSistema}";
    }

    print("URL FINAL -> $finalUrl");
    Uri finalUri = Uri.parse(finalUrl);

    if (hasNextUrl == null) {
      response = await c.get(finalUri, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }).timeout(_duration);
    } else {
      response = await c.get(Uri.parse(hasNextUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }).timeout(_duration);
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      String? hasNext = jsonDecode(response.body)["next"];

      if(hasNext != null){
        print("HAS NEXT $hasNext");
        getImovelBounds(progressController2, hasNextUrl: hasNext);

      } else{

      }

      final List features = jsonDecode(response.body)["results"]["features"];

      for (int i = 0; i < features.length; i++) {
        _loginDataStore.setAppDataImoveisLoaded(0);
        //_loginDataStore.imovelPolygonCounterAdd();
        //progressController2.value = _loginDataStore.counterImoveisPolygons.toDouble()/_loginDataStore.totalImoveisDownload.toDouble();

        ImovelDadosAbertos im = await _helper.getImovelDadosAbertosByPolygonID(features[i]["id"]);
        print("IM -> ${im.idSistemaBaseConsolidada}");

        try{

          im.geomMultipolygon = features[i]["geometry"].toString();

        } catch(e){

          print(e);
          im = ImovelDadosAbertos();

        }  finally{

          _helper.updateImovelDadosAbertos(im);

        }
      }


      if(_loginDataStore.counterImoveisPolygons == _loginDataStore.totalImoveisDownload){
        _loginDataStore.setImoveisListStartPosition(true);
        print("FINISH DOWNLOAD");
        if(_loginDataStore.regAdm.nome == "TODAS"){
          Municipio m = _loginDataStore.m;
          m.allImoveisDownloaded = 1;
          _helper.updateMunicipio(m);
          _helper.getAllImoveisDadosAbertosByMunicipio(_loginDataStore);
        }
        _loginDataStore.setAppDataImoveisLoaded(1);
        _helper.updateAppData(_loginDataStore.appData);
        _loginDataStore.setStartImoveisDownload(false);
      }


    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      print(response.statusCode);
      throw Exception('Failed to load Municipio');
    }
  }

  Future<int> getImoveisCount() async {

    Client c = Client();
    Response response;

    String? cod_ibge_m = _loginDataStore.m.cod_ibge_m;

    print("COD IBGE $cod_ibge_m");

    String finalUrl = "";

    if(_loginDataStore.regAdm.nome == "TODAS"){
      finalUrl = url_imoveisByMunicipio + "?cod_ibge_m=$cod_ibge_m&limit=1";
      print("URL --> $finalUrl");

    } else{
      finalUrl = url_imoveisByMunicipio + "?cod_ibge_m=$cod_ibge_m&limit=1&reg_adm=${_loginDataStore.regAdm.idSistema}";
      print("URL --> $finalUrl");

    }

    print("URL --> $finalUrl");
    Uri finalUri = Uri.parse(finalUrl);

    response = await c.get(finalUri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    }).timeout(_duration);

    print(response);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      _loginDataStore.setTotalImoveisCounter(jsonDecode(response.body)["count"]);
      int count = _loginDataStore.totalImoveisDownload;

      return count;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      print(response.statusCode);
      throw Exception('Failed to load Municipio');
    }
  }

  Future<String?> getImovelDadosAbertosRoute(int id_imovel) async {

    Client c = Client();
    Response response;


    String finalUrl = url_imoveisByMunicipio + "${id_imovel.toString()}/rota/";
    print("URL ROTA -> $finalUrl");
    Uri finalUri = Uri.parse(finalUrl);

    response = await c.get(finalUri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    }).timeout(_duration);

    print(response);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      String routeGeom = jsonDecode(response.body)["geom_rota"].toString();

      final List sedeCoordList = jsonDecode(response.body)["geom_municipio"]["coordinates"];
      final List imovelCoordList = jsonDecode(response.body)["geom_imovel"]["coordinates"];

      print("SEDE COORD -> $sedeCoordList");
      print("IMOVEL COORD -> $imovelCoordList");

      LatLngWithAngle sede = LatLngWithAngle(sedeCoordList[0], sedeCoordList[1]);
      LatLngWithAngle imovel = LatLngWithAngle(imovelCoordList[0], imovelCoordList[1]);

      print("SEDE COORD -> $sede");
      print("IMOVEL COORD -> $imovel");

      print("ROTA -> $routeGeom");

      ImovelDadosAbertos im = await _helper.getImovelDadosAbertos(id_imovel);
      im.geomRota = routeGeom;
      im.coordenadas_sede = sede;
      im.coordenadas_imovel = imovel;

      ImovelDadosAbertos im2 = await _helper.updateImovelDadosAbertos(im);
      _loginDataStore.setSelectedImovelDadosAbertos(im2);
      print("IMOVEL FULL -> $imovel");

      return im2.nome_imovel;

    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      print(response.statusCode);
      throw Exception('Failed to load Municipio');
    }
  }


  Future<String?> getUserRoute(Position position, int id_imovel) async {

    Client c = Client();
    Response response;

    String finalUrl = url_userRoute + "&imovel_id=$id_imovel&latitude=${position.latitude}&longitude=${position.longitude}";
    print("URL ROTA -> $finalUrl");
    Uri finalUri = Uri.parse(finalUrl);

    response = await c.get(finalUri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    }).timeout(_duration);

    log(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      String result = jsonDecode(response.body)["geom_rota"].toString();

      print(result);

      return result;

    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      print(response.statusCode);
      throw Exception('Failed to load Municipio -> ${response.body}');
    }
  }

  Future<Municipio> getDefaultMunicipio() async {
    print("init");

    Client c = Client();

    Response response;

    response = await c.get(uri_get_default_municipio, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    }).timeout(_duration);

    print(response);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      final List data = jsonDecode(response.body);

      for (int i = 0; i < data.length; i++) {
        Municipio m = Municipio();
        try {
          m.idSistema = data[i]["id"];
          m.nome = utf8.decode(data[i]["nome"].toString().runes.toList());
          m.sigla_uf = data[i]["sigla_uf"];
          m.cod_ibge_m = data[i]["cod_ibge_m"];
          m.slug = utf8.decode(data[i]["slug"].toString().runes.toList());
          m.latitude = data[i]["lat_sede"].toString();
          m.longitude = data[i]["lng_sede"].toString();
          Municipio? municipio = await _helper.saveMunicipio(m);
          print(municipio);
          _loginDataStore.setMunicipio(municipio!);
          _loginDataStore.setDefaultMunicipio(true);

        } catch (e) {
          throw Exception("ERROR->  $e");
        }
      }

      return _loginDataStore.m;

    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      print(response.statusCode);
      throw Exception('Failed to load Default');
    }
  }

}


