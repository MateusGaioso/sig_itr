import 'package:app_itr/etc/DBColumnNames.dart';
import 'dart:convert';
import '../db.dart';

class Estado {
  int?  _id;
  int? _idSistema;
  String? _nome;
  String? _sigla_uf;

  Estado.fromJson(Map<String, dynamic> json)
      : _idSistema = int.parse(json['id'].toString()),
        _nome = utf8.decode(json['nome'].toString().runes.toList()),
        _sigla_uf = utf8.decode(json['abreviacao'].toString().runes.toList());

  Map<String, dynamic> toJson() =>
      {
        'id': _idSistema,
        'nome': _nome,
        'abreviacao': _sigla_uf,
      };

  Estado();


  Estado.fromMap(Map map) {
    _id = map[idColumn];
    _idSistema = map[idSistemaColumn];
    _nome = map[nomeEstadoColumn];
    _sigla_uf = map[sigla_ufColumn];
  }

  Map<String, Object?> toMap() {
    Map<String, dynamic> map = {
      idSistemaColumn: _idSistema,
      nomeEstadoColumn: _nome,
      sigla_ufColumn: _sigla_uf,
    };
    if (_id != null) {
      map[idColumn] = _id;
    }
    return map;
  }

  String? get sigla_uf => _sigla_uf;

  set sigla_uf(String? value) {
    _sigla_uf = value;
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

  @override
  String toString() {
    return 'Estado{_id: $_id, _idSistema: $_idSistema, _nome: $_nome, _sigla_uf: $_sigla_uf}';
  }
}
