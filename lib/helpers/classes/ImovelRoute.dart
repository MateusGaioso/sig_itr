import 'package:app_itr/etc/PolygonGenerator.dart';
import 'package:app_itr/etc/DBColumnNames.dart';
import 'dart:convert';
import '../db.dart';


class ImovelRoute {
  int? _id;
  int? _idSistemaRoute;
  int? _idSistemaUser;
  int? _idSistemaMunicipio;
  int? _idSistemaImovel;
  String? _origem_consulta;
  String? _nome_imovel;
  LatLngWithAngle _coordenadas_sede = new LatLngWithAngle(0.0, 0.0);
  LatLngWithAngle _coordenadas_imovel = new LatLngWithAngle(0.0, 0.0);
  String? _geometry;

  int? _sincronizado;

  ImovelRoute();

  ImovelRoute.fromMap(Map map) {
    _id = map[idColumn];
    _idSistemaRoute = map[idSistemaRouteColumn];
    _idSistemaUser = map[idSistemaUserColumn];
    _idSistemaMunicipio = map[idSistemaMunicipioColumn];
    _idSistemaImovel = map[idSistemaImovelColumn];
    _origem_consulta = map[origem_consultaColumn];
    _nome_imovel = map[nome_imovelColumn];
    _coordenadas_sede = LatLngWithAngle(map[coordenadas_sedeLatColumn], map[coordenadas_sedeLngColumn]);
    _coordenadas_imovel = LatLngWithAngle(map[coordenadas_imovelLatColumn], map[coordenadas_imovelLngColumn]);
    _geometry = map[geometryColumn];
    _sincronizado = map[sincronizadoColumn];

  }

  Map<String, Object?> toMap() {
    Map<String, dynamic> map = {
      idSistemaRouteColumn: _idSistemaRoute,
      idSistemaUserColumn: _idSistemaUser,
      idSistemaMunicipioColumn: _idSistemaMunicipio,
      idSistemaImovelColumn: _idSistemaImovel,
      origem_consultaColumn: _origem_consulta,
      nome_imovelColumn: _nome_imovel,
      coordenadas_sedeLatColumn: _coordenadas_sede!.latitude,
      coordenadas_sedeLngColumn: _coordenadas_sede!.longitude,
      coordenadas_imovelLatColumn: _coordenadas_imovel!.latitude,
      coordenadas_imovelLngColumn: _coordenadas_imovel!.longitude,
      geometryColumn: _geometry,
      sincronizadoColumn: _sincronizado,
    };
    if (_id != null) {
      map[idColumn] = _id;
    }
    return map;
  }

  ImovelRoute.fromJson(Map<String, dynamic> json)
      : _idSistemaUser = int.parse(json['properties']["usuario"].toString()),
        _idSistemaRoute = int.parse(json['id'].toString()),
        _idSistemaMunicipio = int.parse(json['properties']["municipio"].toString()),
        _idSistemaImovel = int.parse(json['properties']["imovel_id"].toString()),
        _origem_consulta = utf8.decode(json['properties']["origem_consulta"].toString().runes.toList()),
        _nome_imovel = utf8.decode(json['properties']["nome_imovel"].toString().runes.toList());


  LatLngWithAngle get coordenadas_sede => _coordenadas_sede;

  set coordenadas_sede(LatLngWithAngle value) {
    _coordenadas_sede = value;
  }

  LatLngWithAngle get coordenadas_imovel => _coordenadas_imovel;

  set coordenadas_imovel(LatLngWithAngle value) {
    _coordenadas_imovel = value;
  }


  int? get id => _id;

  set id(int? value) {
    _id = value;
  }


  int? get idSistemaRoute => _idSistemaRoute;

  set idSistemaRoute(int? value) {
    _idSistemaRoute = value;
  }

  int? get idSistemaUser => _idSistemaUser;

  set idSistemaUser(int? value) {
    _idSistemaUser = value;
  }

  int? get idSistemaMunicipio => _idSistemaMunicipio;

  set idSistemaMunicipio(int? value) {
    _idSistemaMunicipio = value;
  }

  int? get idSistemaImovel => _idSistemaImovel;

  set idSistemaImovel(int? value) {
    _idSistemaImovel = value;
  }

  String? get origem_consulta => _origem_consulta;

  set origem_consulta(String? value) {
    _origem_consulta = value;
  }

  String? get nome_imovel => _nome_imovel;

  set nome_imovel(String? value) {
    _nome_imovel = value;
  }

  int? get sincronizado => _sincronizado;

  set sincronizado(int? value) {
    _sincronizado = value;
  }

  String? get geometry => _geometry;

  set geometry(String? value) {
    _geometry = value;

  }

  @override
  String toString() {
    if(sincronizado == 1){
      return 'Route{id: $id, idSistemaUser: $idSistemaUser, idSistemaMunicipio: $idSistemaMunicipio, idSistemaImovel: $idSistemaImovel, origem_consulta: $origem_consulta, nome_imovel: $nome_imovel, '
          'sincronizado: true}';
    } else{
      return 'Route{id: $id, idSistemaUser: $idSistemaUser, idSistemaMunicipio: $idSistemaMunicipio, idSistemaImovel: $idSistemaImovel, origem_consulta: $origem_consulta, nome_imovel: $nome_imovel, '
          'sincronizado: false}';
    }
  }


}
