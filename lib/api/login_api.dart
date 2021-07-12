import 'package:app_itr/helpers/classes/Municipio.dart';
import 'package:app_itr/helpers/classes/user.dart';
import 'dart:convert';
import 'package:app_itr/helpers/db.dart';
import 'package:http/http.dart';

import 'dart:convert' show utf8;


const login_url = "https://www.itrfacil.com.br/entrar/api/";
const user_data_url =
    "https://www.itrfacil.com.br/seguranca/api/usuarios/dados/";
final String failed = "fail";
final Uri login_uri = Uri.parse(login_url);
final Uri user_data_uri = Uri.parse(user_data_url);
const geo_url = "http://3.234.102.34/geoserver/itrfacil/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=itrfacil%3Actrm_imovelctrm&maxFeatures=1000000&outputFormat=application%2Fjson&cod_ibge_m=5002704";
final Uri geo_uri = Uri.parse(geo_url);

Future<String> returnToken(String user, String pass) async {

  Client c = Client();
  Response response = await c.post(login_uri, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  },
      body: jsonEncode(<String, String>{
        'username': user,
        'password': pass,
      }),
      encoding: utf8);

  print("NEW RESPONSE IS: $response");


  if (response.statusCode == 201 || response.statusCode == 200) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.

    print("USER RECEIVED");
    String token = jsonDecode(response.body)["token"];
    print(token);
    return token;
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    print(response.statusCode);
    throw Exception('Failed to load Token');
  }
}

Future<User> returnUserData(String token, String user, String pass) async {


  Client c = Client();
  Response response = await c.get(user_data_uri, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Token $token',
  });



  if (response.statusCode == 201 || response.statusCode == 200) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.

    DBHelper helper = DBHelper();

    print("DATA RECEIVED");
    String _data = '';

    var body = response.body.toString();
    var decoded= utf8.decode(body.runes.toList());

    print(decoded);

    User u = User();
    u.idSistema = jsonDecode(response.body)["id"];
    u.user = user;
    u.pass = pass;
    u.nome = utf8.decode(jsonDecode(response.body)["nome"].toString().runes.toList());
    u.email = utf8.decode(jsonDecode(response.body)["email"].toString().runes.toList());
    u.cpf = utf8.decode(jsonDecode(response.body)["cpf"].toString().runes.toList());
    u.rg = utf8.decode(jsonDecode(response.body)["rg"].toString().runes.toList());
    u.telefone = utf8.decode(jsonDecode(response.body)["telefone"].toString().runes.toList());
    u.imovel = utf8.decode(jsonDecode(response.body)["imovel"].toString().runes.toList());
    u.municipios = "";

    u.token = token;

    final List t = json.decode(response.body)["municipios"];
    final List<Municipio> mList =
    t.map((item) => Municipio.fromJson(item)).toList();

    for (int i = 0; i < mList.length; i++) {

      String muni = mList[i].nome!;
      print("MUNICIPIO SALVO $i -> $muni");
      helper.saveMunicipio(mList[i]);
      String auxId = mList[i].idSistema.toString();
      u.municipios += "$auxId,";
    }

    return u;

  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.

    print(response.statusCode);
    throw Exception('Failed to load User');
  }


}

Future<void> returnGeo() async {
  print("here is");

  Client c = Client();
  Response response = await c.get(geo_uri,  headers: <String, String>{
    'Content-Type': 'application/Fjson; charset=UTF-8',
  });

  print("THE RESPONSE -> $response");
  if (response.statusCode == 201 || response.statusCode == 200) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.

    DBHelper helper = DBHelper();

    print("DATA RECEIVED");
    String _data = '';

    print(response);


  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.

    print(response.statusCode);
    throw Exception('Failed to load User');
  }


}