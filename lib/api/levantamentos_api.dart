import 'dart:convert';
import 'dart:io';
import 'package:app_itr/etc/StaticUrls.dart';
import 'package:app_itr/helpers/classes/Levantamento.dart';
import 'package:app_itr/helpers/classes/PontePoint.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:dio/dio.dart' as _dio;
import 'package:http/http.dart';
import 'dart:convert' show utf8;
import 'package:http_parser/http_parser.dart';

Future<String> postInsertLevantamentos(LoginDataStore _data) async {
  DBHelper helper = DBHelper();
  String token = _data.u.token;
  Client c = Client();
  int qtd;

  print("token -> $token");

  await helper.getAllAsyncLevantamentos(_data).then((value) async {
    qtd = _data.levantamentosListAsync.length;

    int aux = 0;

    print("INSERTING");

    for (int i = 0; i < qtd; i++) {
      print('Levantamento $i');

      print(_data.levantamentosListAsync[i].toJson());

      Response response = await c.post(uri_levantamentosList,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Token $token',
          },
          body: jsonEncode(_data.levantamentosListAsync[i].toJson()),
          encoding: utf8);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // If the server did return a 201 CREATED response,
        // then parse the JSON.
        print("DATA RECEIVED");

        var body = response.body.toString();
        var decoded = utf8.decode(body.runes.toList());

        print("BODY -> $body");
        print("DECODED ->$decoded");

        Map<String, dynamic> levantamentoJson = jsonDecode(decoded);

        _data.levantamentosListAsync[i].sincronizado = 1;
        _data.levantamentosListAsync[i].idSistema = levantamentoJson['id'];

        print("THE DATA -> ${_data.levantamentosListAsync[i]}");
        helper.updateLevantamento(_data.levantamentosListAsync[i]);

        aux++;

        if (_data.levantamentosListAsync[i].tipoLevantamento == "estrada") {
          await _postLevantamentoEstradaPoint(_data, _data.levantamentosListAsync[i]).then((value) {
            helper.getAllLevantamentos(_data);
          });
        }

        if (_data.levantamentosListAsync[i].tipoLevantamento == "rota-escolar") {
          await _postLevantamentoRotaEscolarPoint(_data, _data.levantamentosListAsync[i]).then((value) {
            helper.getAllLevantamentos(_data);
          });
        }

        if (_data.levantamentosListAsync[i].tipoLevantamento == "ponto-imovel") {
          await _postLevantamentoImovelGeoPoint(_data, _data.levantamentosListAsync[i]).then((value) {
            helper.getAllLevantamentos(_data);
          });
        }

        if (_data.levantamentosListAsync[i].tipoLevantamento == "ponte") {
          await _postLevantamentoPonte(_data, _data.levantamentosListAsync[i]).then((value) {
            helper.getAllLevantamentos(_data);
          });
        }


      } else {
        // If the server did not return a 201 CREATED response,
        // then throw an exception.

        print(response.statusCode);
        throw Exception('Failed to post Levantamento');
      }
    }
  });

  return "SUCESSO";
}

Future<String> _postLevantamentoEstradaPoint(LoginDataStore _data, Levantamento l) async {
  DBHelper helper = DBHelper();
  String token = _data.u.token;
  Client c = Client();
  int qtd;

  await helper.getAllAsyncEstradaPointsByLevantamento(l, _data).then((value) async {
    qtd = _data.estradaPointListAsync.length;

    int aux = 0;

    print("INSERTING");

    for (int i = 0; i < qtd; i++) {
      print('Estrada Point $i');
      _data.estradaPointListAsync[i].idSistemaLevantamento = l.idSistema;
      print(_data.estradaPointListAsync[i].toJson());

      Response response = await c.post(uri_levantamentoEstrada,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Token $token',
          },
          body: jsonEncode(_data.estradaPointListAsync[i].toJson()),
          encoding: utf8);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // If the server did return a 201 CREATED response,
        // then parse the JSON.
        print("LEVANTAMENTO DATA RECEIVED");

        var body = response.body.toString();
        var decoded = utf8.decode(body.runes.toList());

        print("BODY -> $body");
        print("DECODED ->$decoded");

        Map<String, dynamic> estradaPointJson = jsonDecode(decoded);

        _data.estradaPointListAsync[i].sincronizado = 1;
        _data.estradaPointListAsync[i].idSistema = estradaPointJson['id'];

        print("THE DATA -> ${_data.estradaPointListAsync[i]}");
        helper.updateEstradaPoint(_data.estradaPointListAsync[i]);

        aux++;
      } else {
        // If the server did not return a 201 CREATED response,
        // then throw an exception.

        print(response.statusCode);
        throw Exception('Failed to post Estrada Point');
      }
    }
  });

  return "SUCESSO";
}

Future<String> _postLevantamentoRotaEscolarPoint(LoginDataStore _data, Levantamento l) async {
  DBHelper helper = DBHelper();
  String token = _data.u.token;
  Client c = Client();
  int qtd;

  await helper.getAllAsyncRotaEscolarPointsByLevantamento(l, _data).then((value) async {
    qtd = _data.rotaEscolarPointListAsync.length;

    int aux = 0;

    print("INSERTING");

    for (int i = 0; i < qtd; i++) {
      print('Rota Escolar Point $i');
      _data.rotaEscolarPointListAsync[i].idSistemaLevantamento = l.idSistema;
      print(_data.rotaEscolarPointListAsync[i].toJson());

      Response response = await c.post(uri_levantamentoRotaEscolar,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Token $token',
          },
          body: jsonEncode(_data.rotaEscolarPointListAsync[i].toJson()),
          encoding: utf8);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // If the server did return a 201 CREATED response,
        // then parse the JSON.
        print("ROTA ESCOLAR DATA RECEIVED");

        var body = response.body.toString();
        var decoded = utf8.decode(body.runes.toList());

        print("BODY -> $body");
        print("DECODED ->$decoded");

        Map<String, dynamic> rotaEscolarPointJson = jsonDecode(decoded);

        _data.rotaEscolarPointListAsync[i].sincronizado = 1;
        _data.rotaEscolarPointListAsync[i].idSistema = rotaEscolarPointJson['id'];

        print("THE DATA -> ${_data.rotaEscolarPointListAsync[i]}");
        helper.updateRotaEscolar(_data.rotaEscolarPointListAsync[i]);

        aux++;
      } else {
        // If the server did not return a 201 CREATED response,
        // then throw an exception.

        print(response.statusCode);
        throw Exception('Failed to post Rota Escolar Point');
      }
    }
  });

  return "SUCESSO";
}


Future<String> _postLevantamentoImovelGeoPoint(LoginDataStore _data, Levantamento l) async {
  DBHelper helper = DBHelper();
  String token = _data.u.token;
  Client c = Client();
  int qtd;

  await helper.getAllAsyncGeoPointsByLevantamento(l, _data).then((value) async {
    qtd = _data.imovelGeoPointListAsync.length;

    int aux = 0;

    print("INSERTING");

    for (int i = 0; i < qtd; i++) {
      print('Imovel Point $i');
      _data.imovelGeoPointListAsync[i].idSistemaLevantamento = l.idSistema;
      print(_data.imovelGeoPointListAsync[i].toJson());

      Response response = await c.post(uri_levantamentoImovelPoint,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Token $token',
          },
          body: jsonEncode(_data.imovelGeoPointListAsync[i].toJson()),
          encoding: utf8);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // If the server did return a 201 CREATED response,
        // then parse the JSON.
        print("IMOVEL POINT DATA RECEIVED");

        var body = response.body.toString();
        var decoded = utf8.decode(body.runes.toList());

        print("BODY -> $body");
        print("DECODED ->$decoded");

        Map<String, dynamic> imovelPointJson = jsonDecode(decoded);

        _data.imovelGeoPointListAsync[i].sincronizado = 1;
        _data.imovelGeoPointListAsync[i].idSistema = imovelPointJson['id'];

        print("THE DATA -> ${_data.imovelGeoPointListAsync[i]}");
        helper.updateGeoPoint(_data.imovelGeoPointListAsync[i]);

        aux++;
      } else {
        // If the server did not return a 201 CREATED response,
        // then throw an exception.

        print(response.statusCode);
        throw Exception('Failed to post Imovel Point');
      }
    }
  });

  return "SUCESSO";
}

Future<String> _postLevantamentoPonte(LoginDataStore _data, Levantamento l) async {
  DBHelper helper = DBHelper();
  String token = _data.u.token;
  Client c = Client();
  int qtd;

  await helper.getAllAsyncPontesByLevantamento(l, _data).then((value) async {
    qtd = _data.ponteListAsync.length;

    int aux = 0;

    print("INSERTING");

    for (int i = 0; i < qtd; i++) {
      print('Ponte Point $i');
      _data.ponteListAsync[i].idSistemaLevantamento = l.idSistema;
      print(_data.ponteListAsync[i].toJson());

      Response response = await c.post(uri_levantamentoPontePoint,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Token $token',
          },
          body: jsonEncode(_data.ponteListAsync[i].toJson()),
          encoding: utf8);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // If the server did return a 201 CREATED response,
        // then parse the JSON.
        print("PONTE POINT DATA RECEIVED");

        var body = response.body.toString();
        var decoded = utf8.decode(body.runes.toList());

        print("BODY -> $body");
        print("DECODED ->$decoded");

        Map<String, dynamic> pontePointJson = jsonDecode(decoded);

        _data.ponteListAsync[i].sincronizado = 1;
        _data.ponteListAsync[i].idSistema = pontePointJson['id'];

        print("THE DATA -> ${_data.ponteListAsync[i]}");
        helper.updatePonte(_data.ponteListAsync[i]);

        _postPonteImages(_data, _data.ponteListAsync[i]);

        aux++;
      } else {
        // If the server did not return a 201 CREATED response,
        // then throw an exception.

        print(response.statusCode);
        throw Exception('Failed to post Ponte Point');
      }
    }
  });

  return "SUCESSO";
}

Future<String> _postPonteImages(LoginDataStore _data, PontePoint pp) async {
  DBHelper helper = DBHelper();
  String token = _data.u.token;
  Client c = Client();
  int qtd;

  var d = _dio.Dio();


  await helper.getAllPonteImagesByPontePoint(pp, _data).then((value) async {
    qtd = _data.ponteImages.length;

    int aux = 0;

    print("INSERTING");

    for (int i = 0; i < qtd; i++) {
      if(_data.ponteImages[i] is PonteImage){
        PonteImage ponteImage = _data.ponteImages[i] as PonteImage;
        print('Ponte Image $i');
        ponteImage.idSistemaPonte = pp.idSistema;
        print(await ponteImage.toJson());
        String filename = "ponte-${ponteImage.idSistemaPonte}-${ponteImage.id}.jpg";

        var formData = _dio.FormData.fromMap(
            {
              'ponte': ponteImage.idSistemaPonte,
              'foto': await _dio.MultipartFile.fromFile(ponteImage.imagePath!, filename: filename, contentType: new MediaType('image', 'jpg'))
        });
        var the_response;
        try {
          the_response = await d.post(url_levantamentoFotosPonte, data: formData, options: _dio.Options(
              headers: {
                "Authorization": "Token $token",
              }
          ));
        } catch(e) {
          print("ERRORCATCH $e");
          print(the_response);
        }

          /*Response response = await c.post(uri_levantamentoFotosPonte,
            headers: <String, String>{
              'Content-Type': 'multipart/form-data; charset=UTF-8',
              'Authorization': 'Token $token',
            },
            body: jsonEncode(ponteImage.toJson()),
            encoding: utf8);*/

          if (the_response.statusCode == 201 || the_response.statusCode == 200) {
            // If the server did return a 201  response,
            // then parse the JSON.
            print("PONTE IMAGE DATA RECEIVED");

            var body = the_response.data.toString();
            var decoded = utf8.decode(body.runes.toList());

            print("BODY -> $body");
            print("DECODED ->$decoded");

            Map<String, dynamic> ponteImageJson = jsonDecode(decoded);

            ponteImage.sincronizado = 1;
            ponteImage.idSistema = ponteImageJson['id'];

            print("THE DATA -> $ponteImage");
            helper.updatePonteImage(ponteImage);

            aux++;
          } else {
            // If the server did not return a 201 CREATED response,
            // then throw an exception.
            print("ERROR RESPONSE");
            print(the_response.statusCode);
            throw Exception('Failed to post PONTE IMAGE');
          }
        }
      }

  });

  return "SUCESSO";
}
