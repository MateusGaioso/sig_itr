import 'package:app_itr/helpers/classes/ImovelGeoPoint.dart';
import 'package:app_itr/helpers/classes/municipio.dart';
import 'package:app_itr/helpers/classes/user.dart';
import 'dart:convert';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:http/http.dart';
import 'dart:convert' show utf8;


const points_url = "https://www.itrfacil.com.br/ctrm/api/pontos-imoveis/";
final Uri points_uri = Uri.parse(points_url);

Future<String> postInsertPoints(LoginDataStore _data, List geoPoints) async {
  DBHelper helper = DBHelper();
  String token = _data.u.token;
  Client c = Client();
  int qtd = geoPoints.length;
  int aux = 0;

  print("INSERTING");
  print("GEOPOINTS -> $geoPoints");

  for (int i = 0; i < qtd; i++) {
    print('Point $i');
    print(geoPoints[i].toJson());

    Response response = await c.post(points_uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(<String, String>{
          'tipo': geoPoints[i].tipo,
          'descricao': geoPoints[i].descricao,
          'geom': geoPoints[i].getGeom()
        }),
        encoding: utf8);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      print("DATA RECEIVED");
      String _data = '';

      var body = response.body.toString();
      var decoded = utf8.decode(body.runes.toList());

      geoPoints[i].sincronizado = 1;
      helper.updateGeoPoint(geoPoints[i]);

      aux ++;

      print(decoded);

    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.

      print(response.statusCode);
      throw Exception('Failed to load User');
    }
  }

  if(aux == qtd){
    _data.setAllSincronized(true);
  }

  return "SUCESSO";
}
