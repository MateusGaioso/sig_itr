import 'dart:developer';
import 'dart:io';
import 'package:app_itr/etc/PathReceiver.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

import 'ConnectionChecker.dart';

const map_url = "https://mapas.itrfacil.com.br/geoserver/itrfacil/ows?service=WFS&version=1.0.0";

class JsonGenerator {
  Future generateGeoJson(LoginDataStore l) async {
    var conn = await ConnectionChecker.checkConnection();

    String fileName = l.geoJsonFileName;


    if (conn) {
      int qtd = 2000;
      String reqType = '&request=getFeature';
      String typeName = '&typeName=itrfacil%3Amapas_incrasigef';
      String maxFeatures = '&maxFeatures=' + qtd.toString();
      String outPutFormat = '&outputFormat=application%2Fjson';
      String type = '&type=geojson';
      String format = '&format=geojson';
      String srsName = '&srsName=EPSG%3A4326';
      String cqlFilter = '&cql_filter=%22municipio%22%3D%27${l.m.cod_ibge_m}%27';

      String finalUrl =
          map_url + reqType + typeName + maxFeatures + outPutFormat + type + format + srsName + cqlFilter;

      print("$finalUrl");

      Client c = Client();
      Response response = await c.get(Uri.parse(finalUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        // If the server did return a 201 CREATED response,
        // then parse the JSON.

        String body = response.body.toString();
        log("decode");
        //debugPrint(body, wrapWidth: 1024);

        String jsonFinal = "var geoJsonFeature=$body;";


        PathReceiver(fileName).writeString(jsonFinal);

        print("geojson pass");

      } else {
        // If the server did not return a 201 CREATED response,
        // then throw an exception.

        print(response.statusCode);
        throw Exception('Failed to load User');
      }
    }
  }
}
