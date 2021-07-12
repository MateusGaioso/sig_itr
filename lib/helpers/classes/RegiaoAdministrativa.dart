import 'package:app_itr/etc/DBColumnNames.dart';
import 'dart:convert';
import '../db.dart';

class RegiaoAdministrativa {
  int?  _id;
  int? _idSistema;
  int? _idSistemaMunicipio;
  String? _nome;
  String? _cod_ibge_m;

  RegiaoAdministrativa.fromJson(Map<String, dynamic> json)
      : _idSistema = int.parse(json['id'].toString()),
        _idSistemaMunicipio = int.parse(json['municipio'].toString()),
        _nome = utf8.decode(json['nome'].toString().runes.toList()),
        _cod_ibge_m = utf8.decode(json['cod_ibge_m'].toString().runes.toList());

  Map<String, dynamic> toJson() =>
      {
        'id': _id,
        'nome': _nome,
        'municipio': _idSistemaMunicipio,
        'cod_ibge_m': _cod_ibge_m,
      };

  RegiaoAdministrativa();

  RegiaoAdministrativa.fromMap(Map map) {
    _id = map[idColumn];
    _idSistema = map[idSistemaColumn];
    _idSistemaMunicipio = map[idSistemaMunicipioColumn];
    _nome = map[nomeRegAdmColumn];
    _cod_ibge_m = map[cod_ibge_mColumn];
  }

  Map<String, Object?> toMap() {
    Map<String, dynamic> map = {
      idSistemaColumn: _idSistema,
      idSistemaMunicipioColumn: _idSistemaMunicipio,
      nomeRegAdmColumn: _nome,
      cod_ibge_mColumn: _cod_ibge_m,
    };
    if (_id != null) {
      map[idColumn] = _id;
    }
    return map;
  }

  String? get cod_ibge_m => _cod_ibge_m;

  set cod_ibge_m(String? value) {
    _cod_ibge_m = value;
  }

  String? get nome => _nome;

  set nome(String? value) {
    _nome = value;
  }

  int? get idSistema => _idSistema;

  set idSistema(int? value) {
    _idSistema = value;
  }

  int? get idSistemaMunicipio => _idSistemaMunicipio;

  set idSistemaMunicipio(int? value) {
    _idSistemaMunicipio = value;
  }

  int? get id => _id;

  set id(int? value) {
    _id = value;
  }

  @override
  String toString() {
    return 'RegiaoAdministrativa{_id: $_id, _idSistema: $_idSistema, _idSistemaMunicipio: $_idSistemaMunicipio, _nome: $_nome, _cod_ibge_m: $_cod_ibge_m}';
  }
}
