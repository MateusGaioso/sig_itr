import 'package:app_itr/etc/DBColumnNames.dart';
import 'package:app_itr/etc/PolygonGenerator.dart';
import 'package:app_itr/helpers/classes/ImovelGeoPoint.dart';
import '../db.dart';
import 'ImovelGeoPoint.dart';


class Imovel {
  int ? id;
  int ? idSistemaUser;
  int ? idSistemaMunicipio;
  List<ImovelGeoPoint> ? geoPoints = [];
  String ? listGeoPoints;
  bool  using = false;

  String getGeoPointsId(){
    String geo = "";

    for(int i = 0; i < geoPoints!.length; i++){
      String aux = geoPoints![i].id.toString();
      geo += "$aux,";
    }

    print('GEOFINAL -> $geo');

    return geo;
  }


  Future<List<LatLngWithAngle>> listLatLng() async{

    DBHelper db = new DBHelper();
    final listG =listGeoPoints;
    final split = listG!.split(',');
    final Map<int, String> values = {
      for (int i = 0; i < split.length - 1; i++)
        i: split[i]
    };
    for(int x = 0; x < values.length; x ++){
     ImovelGeoPoint gp = (await db.getGeoPoint(int.parse(values[x]!)))!;
      geoPoints!.add(gp);
    }; // {0: grubs, 1:  sheep}

    List<LatLngWithAngle> list = [];
    for(int i = 0; i<geoPoints!.length; i++){
      LatLngWithAngle l = geoPoints![i].geom!;
      l.id = geoPoints![i].id!;
      list.add(geoPoints![i].geom!);
    }

    return list;
  }

  bool isUsing(){
    return using;
  }

  Imovel(bool use){
    this.using = use;
  }

  Imovel.fromMap(Map map) {
    id = map[idImovelColumn];
    idSistemaUser = map[idSistemaUserColumn];
    idSistemaMunicipio = map[idSistemaMunicipioColumn];
    listGeoPoints = map[listGeoPointsColumn];

  }

  Map<String, Object?> toMap() {
    Map<String, dynamic> map = {
      idSistemaUserColumn: idSistemaUser,
      idSistemaMunicipioColumn: idSistemaMunicipio,
      listGeoPointsColumn: listGeoPoints,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }


  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'listGeoPoints': listGeoPoints,
      };

  @override
  String toString() {
    return "Imovel(id: $id, GeoPoints: $geoPoints), Stringed: $listGeoPoints";
  }
}
