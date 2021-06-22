import 'package:app_itr/etc/DBColumnNames.dart';
import 'package:app_itr/etc/PolygonGenerator.dart';

class RotaEscolarPoint {
  int? _id;
  int? _idSistema;
  int? _idLevantamento;
  int? _idSistemaLevantamento;
  String? _rodovia;
  String? _trecho;
  String? _jurisdicao;
  String? _estado_conservacao;
  String? _tipo_pavimentacao;
  String? _largura_aproximada;
  String? _cod_ibge_m;
  int?_sincronizado;
  LatLngWithAngle? _geom;

  RotaEscolarPoint();

  RotaEscolarPoint.fromMap(Map map) {
    _id = map[idColumn];
    _idSistema = map[idSistemaColumn];
    _idLevantamento = map[idLevantamentoColumn];
    _idSistemaLevantamento = map[idSistemaLevantamentoColumn];
    _rodovia = map[rodoviaColumn];
    _trecho = map[trechoColumn];
    _jurisdicao = map[jurisdicaoColumn];
    _estado_conservacao = map[estadoConservacaoColumn];
    _tipo_pavimentacao = map[tipoPavimentacaoColumn];
    _largura_aproximada = map[larguraAproximadaColumn];
    _cod_ibge_m = map[cod_ibge_mColumn];
    _sincronizado = map[sincronizadoColumn];
    _geom = LatLngWithAngle(map[latColumn], map[lngColumn]);

  }


  Map<String, Object?> toMap() {
    Map<String, dynamic> map = {
      idSistemaColumn: _idSistema,
      idLevantamentoColumn: _idLevantamento,
      idSistemaLevantamentoColumn: _idSistemaLevantamento,
      rodoviaColumn: _rodovia,
      trechoColumn: _trecho,
      jurisdicaoColumn: _jurisdicao,
      estadoConservacaoColumn: _estado_conservacao,
      tipoPavimentacaoColumn: _tipo_pavimentacao,
      larguraAproximadaColumn: _largura_aproximada,
      cod_ibge_mColumn: _cod_ibge_m,
      sincronizadoColumn: _sincronizado,
      latColumn: _geom!.latitude,
      lngColumn: _geom!.longitude,
    };
    if (_id != null) {
      map[idColumn] = _id;
    }
    return map;
  }

  Map<String, dynamic> toJson() =>
      {
        "levantamento": _idSistemaLevantamento,
        "rodovia": _rodovia,
        "trecho": _trecho,
        "jurisdicao": _jurisdicao,
        "estado_conservacao": _estado_conservacao,
        "tipo_pavimentacao": _tipo_pavimentacao,
        "largura_aproximada": _largura_aproximada,
        "cod_ibge_m": _cod_ibge_m,
        "geom": getGeom()
      };


  String getGeom(){
    return 'POINT(' + _geom!.longitude.toString() + ' ' + _geom!.latitude.toString() + ')';
  }

  int? get sincronizado => _sincronizado;

  set sincronizado(int? value) {
    _sincronizado = value;
  }

  String? get cod_ibge_m => _cod_ibge_m;

  set cod_ibge_m(String? value) {
    _cod_ibge_m = value;
  }

  String? get largura_aproximada => _largura_aproximada;

  set largura_aproximada(String? value) {
    _largura_aproximada = value;
  }

  String? get tipo_pavimentacao => _tipo_pavimentacao;

  set tipo_pavimentacao(String? value) {
    _tipo_pavimentacao = value;
  }

  String? get estado_conservacao => _estado_conservacao;

  set estado_conservacao(String? value) {
    _estado_conservacao = value;
  }

  int? get idSistemaLevantamento => _idSistemaLevantamento;

  set idSistemaLevantamento(int? value) {
    _idSistemaLevantamento = value;
  }

  int? get idLevantamento => _idLevantamento;

  set idLevantamento(int? value) {
    _idLevantamento = value;
  }

  int? get idSistema => _idSistema;

  set idSistema(int? value) {
    _idSistema = value;
  }

  int? get id => _id;

  set id(int? value) {
    _id = value;
  }

  LatLngWithAngle? get geom => _geom;

  set geom(LatLngWithAngle? value) {
    _geom = value;
  }


  String? get rodovia => _rodovia;

  set rodovia(String? value) {
    _rodovia = value;
  }

  String? get trecho => _trecho;

  set trecho(String? value) {
    _trecho = value;
  }

  String? get jurisdicao => _jurisdicao;

  set jurisdicao(String? value) {
    _jurisdicao = value;
  }

  @override
  String toString() {
    return 'RotaEscolarPoint{_id: $_id, _idSistema: $_idSistema, _idLevantamento: $_idLevantamento, _idSistemaLevantamento: $_idSistemaLevantamento, _rodovia: $_rodovia, _trecho: $_trecho, _jurisdicao: $_jurisdicao, _estado_conservacao: $_estado_conservacao, _tipo_pavimentacao: $_tipo_pavimentacao, _largura_aproximada: $_largura_aproximada, _cod_ibge_m: $_cod_ibge_m, _sincronizado: $_sincronizado, _geom: $_geom}';
  }
}

