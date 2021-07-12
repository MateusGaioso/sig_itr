import 'package:app_itr/etc/DBColumnNames.dart';
import 'dart:convert';
import '../db.dart';

class Municipio {
  int?  _id;
  int? _idSistema;
  String? _nome;
  String? _slug;
  int? _estado;
  String? _sigla_uf;
  String? _cod_ibge_m;
  String? _latitude;
  String? _longitude;
  int? _allImoveisDownloaded = 0;

  Municipio.fromJson(Map<String, dynamic> json)
      : _idSistema = int.parse(json['id'].toString()),
        _nome = utf8.decode(json['nome'].toString().runes.toList()),
        _slug = utf8.decode(json['slug'].toString().runes.toList()),
        _estado = int.parse(utf8.decode(json['estado'].toString().runes.toList())),
        _sigla_uf = utf8.decode(json['sigla_uf'].toString().runes.toList()),
        _cod_ibge_m = utf8.decode(json['cod_ibge_m'].toString().runes.toList()),
        _latitude = utf8.decode(json['lat_sede'].toString().runes.toList()),
        _longitude = utf8.decode(json['lng_sede'].toString().runes.toList());

  Map<String, dynamic> toJson() =>
      {
        'id': _id,
        'nome': _nome,
        'slug': _slug,
        'estado': _estado,
        'sigla_uf': _sigla_uf,
        'cod_ibge_m': _cod_ibge_m,
        'latitude': _latitude,
        'longitude': _longitude,
      };

  Municipio();

  String municipio_plus_uf() {
    return "$_nome - $_sigla_uf";
  }

  Municipio.fromMap(Map map) {
    _id = map[idColumn];
    _idSistema = map[idSistemaColumn];
    _nome = map[nomeMunicipioColumn];
    _slug = map[slugColumn];
    _estado = map[estadoColumn];
    _sigla_uf = map[sigla_ufColumn];
    _cod_ibge_m = map[cod_ibge_mColumn];
    _latitude = map[latitudeColumn];
    _longitude = map[longitudeColumn];
    _allImoveisDownloaded = map[allDownloadedColumn];
  }

  Map<String, Object?> toMap() {
    Map<String, dynamic> map = {
      idSistemaColumn: _idSistema,
      nomeMunicipioColumn: _nome,
      slugColumn: _slug,
      estadoColumn: _estado,
      sigla_ufColumn: _sigla_uf,
      cod_ibge_mColumn: _cod_ibge_m,
      latitudeColumn: _latitude,
      longitudeColumn: _longitude,
      allDownloadedColumn: _allImoveisDownloaded,
    };
    if (_id != null) {
      map[idColumn] = _id;
    }
    return map;
  }

  String? get longitude => _longitude;

  set longitude(String? value) {
    _longitude = value;
  }

  String? get latitude => _latitude;

  set latitude(String? value) {
    _latitude = value;
  }

  String? get cod_ibge_m => _cod_ibge_m;

  set cod_ibge_m(String? value) {
    _cod_ibge_m = value;
  }

  String? get sigla_uf => _sigla_uf;

  set sigla_uf(String? value) {
    _sigla_uf = value;
  }

  int? get estado => _estado;

  set estado(int? value) {
    _estado = value;
  }

  String? get slug => _slug;

  set slug(String? value) {
    _slug = value;
  }

  String? get nome => _nome;

  set nome(String? value) {
    _nome = value;
  }

  int? get idSistema => _idSistema;

  set idSistema(int? value) {
    _idSistema = value;
  }

  int? get id => _id;

  set id(int? value) {
    _id = value;
  }
  
  int? get allImoveisDownloaded => _allImoveisDownloaded;

  set allImoveisDownloaded(int? value) {
    _allImoveisDownloaded = value;
  }

  @override
  String toString() {
    return 'Municipio{_id: $_id, _idSistema: $_idSistema, _nome: $_nome, _slug: $_slug, _estado: $_estado, _sigla_uf: $_sigla_uf, _cod_ibge_m: $_cod_ibge_m, _latitude: $_latitude, _longitude: $_longitude, _allImoveisDownloaded: $_allImoveisDownloaded}';
  }
}
