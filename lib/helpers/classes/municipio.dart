import 'package:app_itr/etc/DBColumnNames.dart';
import 'dart:convert';
import '../db.dart';

class Municipio {
  int?  id;
  int? idSistema;
  String? nome;
  String? slug;
  int? estado;
  String? sigla_uf;
  String? cod_ibge_m;
  String? latitude;
  String? longitude;

  Municipio.fromJson(Map<String, dynamic> json)
      : idSistema = int.parse(json['id'].toString()),
        nome = utf8.decode(json['nome'].toString().runes.toList()),
        slug = utf8.decode(json['slug'].toString().runes.toList()),
        estado = int.parse(utf8.decode(json['estado'].toString().runes.toList())),
        sigla_uf = utf8.decode(json['sigla_uf'].toString().runes.toList()),
        cod_ibge_m = utf8.decode(json['cod_ibge_m'].toString().runes.toList()),
        latitude = utf8.decode(json['lat_sede'].toString().runes.toList()),
        longitude = utf8.decode(json['lng_sede'].toString().runes.toList());

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'nome': nome,
        'slug': slug,
        'estado': estado,
        'sigla_uf': sigla_uf,
        'cod_ibge_m': cod_ibge_m,
        'latitude': latitude,
        'longitude': longitude,
      };

  Municipio();

  String municipio_plus_uf() {
    return "$nome - $sigla_uf";
  }

  Municipio.fromMap(Map map) {
    id = map[idColumn];
    idSistema = map[idSistemaColumn];
    nome = map[nomeMunicipioColumn];
    slug = map[slugColumn];
    estado = map[estadoColumn];
    sigla_uf = map[sigla_ufColumn];
    cod_ibge_m = map[cod_ibge_mColumn];
    latitude = map[latitudeColumn];
    longitude = map[longitudeColumn];
  }

  Map<String, Object?> toMap() {
    Map<String, dynamic> map = {
      idSistemaColumn: idSistema,
      nomeMunicipioColumn: nome,
      slugColumn: slug,
      estadoColumn: estado,
      sigla_ufColumn: sigla_uf,
      cod_ibge_mColumn: cod_ibge_m,
      latitudeColumn: latitude,
      longitudeColumn: longitude,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Município(id: $id, idSistema: $idSistema, name: $nome, slug: $slug, estado: $estado, sigla_uf: "
        "$sigla_uf, cod_ibge_m: $cod_ibge_m, latitude: $latitude, longitude: $longitude)";
  }

}
