import 'dart:developer';

import 'package:app_itr/etc/PolygonGenerator.dart';
import 'package:app_itr/helpers/classes/ImovelRoute.dart';
import 'package:app_itr/helpers/classes/municipio.dart';
import 'package:app_itr/helpers/classes/user.dart';
import 'dart:convert';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:http/http.dart';
import 'dart:convert' show utf8;

const route_url = "https://sigctrm.com.br/rotas/api/rotas-usuario/";
final Uri route_uri = Uri.parse(route_url);

Future<List<ImovelRoute>> getImovelRoutes(LoginDataStore loginDataStore, {String? hasNextUrl}) async {

  print("init");

  DBHelper helper = new DBHelper();

  Client c = Client();

  Response response;

  if(hasNextUrl == null){
    response = await c.get(route_uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token ${loginDataStore.u.token}',
    });
  } else{
     response = await c.get(Uri.parse(hasNextUrl), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token ${loginDataStore.u.token}',
    });
  }


  print(response);

  if (response.statusCode == 201 || response.statusCode == 200) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.

    DBHelper helper = DBHelper();

    var body = response.body.toString();
    var decoded= utf8.decode(body.runes.toList());
    List<ImovelRoute> list = [];

    final List features = jsonDecode(response.body)["results"]["features"];

    for(int i = 0; i < features.length; i++){
        ImovelRoute r = ImovelRoute();
        try{


          r.idSistemaRoute = features[i]["id"];
          r.idSistemaUser = features[i]["properties"]["usuario"];
          r.idSistemaMunicipio = features[i]["properties"]["municipio"];
          r.idSistemaImovel = features[i]["properties"]["imovel_id"];
          r.origem_consulta = utf8.decode(features[i]["properties"]["origem_consulta"].toString().runes.toList());
          r.nome_imovel = utf8.decode(features[i]["properties"]["nome_imovel"].toString().runes.toList());

          final List sedeCoordList = features[i]["properties"]["coordenadas_sede"]["coordinates"];
          final List imovelCoordList = features[i]["properties"]["coordenadas_imovel"]["coordinates"];
          LatLngWithAngle sede = LatLngWithAngle(sedeCoordList[0], sedeCoordList[1]);
          LatLngWithAngle imovel = LatLngWithAngle(imovelCoordList[0], imovelCoordList[1]);

          r.coordenadas_sede = sede;
          r.coordenadas_imovel = imovel;
          r.sincronizado = 1;
          r.geometry = features[i]["geometry"].toString();

          list.add(r);


        } catch(e){

          print(e);
          r = ImovelRoute();

        }  finally{

          if(r.idSistemaUser != null){
            helper.saveImovelRoute(r);

          }
        }
    }

    helper.getAllImovelRoutes(loginDataStore);

    String hasNext = jsonDecode(response.body)["next"];

    if(hasNext != null){
      print("HAS NEXT $hasNext");
      getImovelRoutes(loginDataStore, hasNextUrl: hasNext);

    }

    return list;

  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.

    print(response.statusCode);
    throw Exception('Failed to load User');
  }




}
