import 'package:app_itr/etc/DBColumnNames.dart';

class Levantamento {
  int? _id;
  int? _idSistema;
  String? _descricao;
  String? _tipoLevantamento;
  int? _idSistemaUser;
  int? _idSistemaMunicipio;
  String? _status;
  int?_sincronizado;

  Levantamento();

  Levantamento.fromMap(Map map) {
    _id = map[idColumn];
    _idSistema = map[idSistemaColumn];
    _idSistemaUser = map[idSistemaUserColumn];
    _idSistemaMunicipio = map[idSistemaMunicipioColumn];
    _descricao = map[descricaoColumn];
    _tipoLevantamento = map[tipoLevantamentoColumn];
    _status = map[statusColumn];
    _sincronizado = map[sincronizadoColumn];

  }

  Map<String, Object?> toMap() {
    Map<String, dynamic> map = {
      idSistemaColumn: _idSistema,
      idSistemaUserColumn: _idSistemaUser,
      idSistemaMunicipioColumn: _idSistemaMunicipio,
      tipoLevantamentoColumn: _tipoLevantamento,
      descricaoColumn: _descricao,
      statusColumn: _status,
      sincronizadoColumn: _sincronizado,
    };
    if (_id != null) {
      map[idColumn] = _id;
    }
    return map;
  }

  Map<String, dynamic> toJson() =>
      {
        "descricao": _descricao,
        "tipo": _tipoLevantamento,
        "usuario": _idSistemaUser,
        "municipio": _idSistemaMunicipio
      };


int? get sincronizado => _sincronizado;

  set sincronizado(int? value) {
    _sincronizado = value;
  }

  int? get idSistemaMunicipio => _idSistemaMunicipio;

  set idSistemaMunicipio(int? value) {
    _idSistemaMunicipio = value;
  }

  int? get idSistemaUser => _idSistemaUser;

  set idSistemaUser(int? value) {
    _idSistemaUser = value;
  }

  String? get tipoLevantamento => _tipoLevantamento;

  set tipoLevantamento(String? value) {
    _tipoLevantamento = value;
  }

  String? get descricao => _descricao;

  set descricao(String? value) {
    _descricao = value;
  }

  int? get idSistema => _idSistema;

  set idSistema(int? value) {
    _idSistema = value;
  }

  int? get id => _id;

  set id(int? value) {
    _id = value;
  }

  String? get status => _status;

  set status(String? value) {
    _status = value;
  }

  bool isSincronizado(){
    if(_sincronizado == 0){
      return false;
    } else{
      return true;
    }
  }

  @override
  String toString() {
    return 'Levantamento{_id: $_id, _idSistema: $_idSistema, _descricao: $_descricao, _tipoLevantamento: $_tipoLevantamento, _idSistemaUser: $_idSistemaUser, _idSistemaMunicipio: $_idSistemaMunicipio, _status: $_status, _sincronizado: $_sincronizado}';
  }
}

