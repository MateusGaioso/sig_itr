import 'dart:developer';
import 'dart:io';

import 'package:app_itr/etc/ConnectionChecker.dart';
import 'package:app_itr/etc/JsonGenerator.dart';
import 'package:app_itr/etc/PathReceiver.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

const google_map_url = "https://mt0.google.com/vt/lyrs=m&hl=en&x=\{x\}&y=\{y\}&z=\{z\}";
const geo_server_url = "https://mapas.itrfacil.com.br/geoserver/itrfacil/ows";

class JavaScriptGenerator {
  Future generateJS(LoginDataStore l) async {
    print("HERE");

    var conn = await ConnectionChecker.checkConnection();

    _generateFiles(l);

    String fileName = l.javaScriptFileName;
    if (conn) {
      JsonGenerator().generateGeoJson(l).then((value) async {
        String geoJsonFileName = l.geoJsonFileName;

        File f = await PathReceiver(geoJsonFileName).localFile();

        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

        String lat = position.latitude.toString();
        String lng = position.longitude.toString();
        int zoom = 18;
        int maxZoom = 20;

        String textJson = "geoJsonFile = '${f.readAsString()}';";

        String myMap = "var mymap = L.map('mapid').setView([$lat, $lng], $zoom);";

        String gstreets = "var gstreets = L.tileLayer('$google_map_url', "
            "{maxZoom: $maxZoom, attribution: 'google'});";

        String gstreetsAdd = "gstreets.addTo(mymap);";

        String varImoveis = "var imoveis = L.geoJson(geoJsonFeature, " +
         "{" +
        "onEachFeature: function (feature, layer) {" +
          "layer.bindPopup(feature.properties.nome_area);" +
        "}" +
      "});";


        String addTo = "imoveis.addTo(mymap);";

        String panTo = "mymap.panTo(new L.LatLng($lat, $lng)); var group = L.featureGroup();";



        String fullText =
            myMap + gstreets + gstreetsAdd  +  varImoveis + addTo + panTo;

        print("FULL JS -> $fullText");

        PathReceiver(fileName).writeString(fullText);

      });
    }
  }

  Future _generateFiles(LoginDataStore l) async {
    String mapHtml = "map.html";
    String leafletJs=  "leaflet.js";
    String leafletJsMap = "leaflet.js.map";
    String jquery351 = "jquery-3.5.1.min.js";
    String leafletCSS = "leaflet.css";
    String leafletEsmJs = "leaflet-src.esm.js";
    String leafletEsmJsMap = "leaflet-src.esm.js.map";
    String leafletSrcJs = "leaflet-src.js";
    String leafletSrcJsMap = "leaflet-src.js.map";

    String bodyLeafletJS = await rootBundle.loadString('assets/map/$leafletJs');
    String bodyLeafletJSMap = await rootBundle.loadString('assets/map/$leafletJsMap');
    String bodyJquery = await rootBundle.loadString('assets/map/$jquery351');
    String bodyLeafletCSS = await rootBundle.loadString('assets/map/$leafletCSS');
    String bodyLeafletEsmJs = await rootBundle.loadString('assets/map/$leafletEsmJs');
    String bodyLeafletEsmJsMap = await rootBundle.loadString('assets/map/$leafletEsmJsMap');
    String bodyLeafletSrcJs = await rootBundle.loadString('assets/map/$leafletSrcJs');
    String bodyLeafletSrcJsMap = await rootBundle.loadString('assets/map/$leafletSrcJsMap');

    PathReceiver(leafletJs).writeString(bodyLeafletJS);
    PathReceiver(leafletJsMap).writeString(bodyLeafletJSMap);
    PathReceiver(jquery351).writeString(bodyJquery);
    PathReceiver(leafletCSS).writeString(bodyLeafletCSS);
    PathReceiver(leafletEsmJs).writeString(bodyLeafletEsmJs);
    PathReceiver(leafletEsmJsMap).writeString(bodyLeafletEsmJsMap);
    PathReceiver(leafletSrcJs).writeString(bodyLeafletSrcJs);
    PathReceiver(leafletSrcJsMap).writeString(bodyLeafletSrcJsMap);


    String fileJsName = l.javaScriptFileName;

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;

    File fileLeaflet = await File('$path/$leafletJs');
    String leafletPath = fileLeaflet.path;

    File fileJquery = await File('$path/$jquery351');
    String jqueryPath = fileJquery.path;

    File fileJs = await File('$path/$fileJsName');
    String jsPath = fileJs.path;

    String bodyHtml = "<!DOCTYPE html>" + "\n" +
        "<html lang='en'>" + "\n" +
        "<head>" + "\n" +
        "<meta charset='UTF-8'>" + "\n" +
        "<meta name='viewport' content='width=device-width, initial-scale=1.0'>" + "\n" +
        "<title>Exemplo Leaflet</title>" + "\n" +
        "<link rel='stylesheet' href='leaflet.css'/>" + "\n" +
        " " + "\n" +
        " " + "\n" +
        "<style>" + "\n" +
        "#mapid{" + "\n" +
        "position: absolute; " + "\n" +
        "top: 0; " + "\n" +
        "left: 0; " + "\n" +
        "bottom: 0; " + "\n" +
        "width: 100%; " + "\n" +
        "} " + "\n" +
        " " + "\n" +
        "</style>" + "\n" +
        "" + "\n" +
        "</head>" + "\n" +
        "<body>" + "\n" +
        "<div id='mapid'>MAP</div>" + "\n" +
        "" + "\n" +

        "" + "\n" +
        "</body>";

        PathReceiver(mapHtml).writeString(bodyHtml);



    File f = await File('$path/map.html');

    log(f.toString());
    l.setPathHtml(f.path);
  }

}
