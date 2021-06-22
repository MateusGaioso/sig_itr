import 'package:app_itr/etc/PolygonGenerator.dart';
import 'package:app_itr/etc/DBColumnNames.dart';
import '../db.dart';


class ImovelGeoPoint {
  int? _id;
  int? _idSistema;
  int? _idLevantamento;
  int? _idSistemaLevantamento;
  String? _tipo;
  String? _descricao;
  String? _cod_ibge_m;
  LatLngWithAngle? _geom;
  int? _sincronizado;

  ImovelGeoPoint();

  ImovelGeoPoint.fromMap(Map map) {
    _id = map[idColumn];
    _idSistema = map[idSistemaColumn];
    _idLevantamento = map[idLevantamentoColumn];
    _idSistemaLevantamento = map[idSistemaLevantamentoColumn];
    _tipo = map[tipoColumn];
    _descricao = map[descricaoColumn];
    _cod_ibge_m = map[cod_ibge_mColumn];
    _geom = LatLngWithAngle(map[latColumn], map[lngColumn]);
    _sincronizado = map[sincronizadoColumn];

  }

  Map<String, Object?> toMap() {
    Map<String, dynamic> map = {
      idSistemaColumn: _idSistema,
      idLevantamentoColumn: _idLevantamento,
      idSistemaLevantamentoColumn: _idSistemaLevantamento,
      tipoColumn: _tipo,
      descricaoColumn: _descricao,
      cod_ibge_mColumn: _cod_ibge_m,
      latColumn: _geom!.latitude,
      lngColumn: _geom!.longitude,
      sincronizadoColumn: _sincronizado,
    };
    if (_id != null) {
      map[idColumn] = _id;
    }
    return map;
  }

  String getGeom(){
    return 'POINT(' + _geom!.longitude.toString() + ' ' + _geom!.latitude.toString() + ')';
  }


  Map<String, dynamic> toJson() =>
      {
        "levantamento": _idSistemaLevantamento,
        "descricao": _descricao,
        'tipo': _tipo,
        "cod_ibge_m": _cod_ibge_m,
        "geom": getGeom()
      };

  int? get sincronizado => _sincronizado;

  set sincronizado(int? value) {
    _sincronizado = value;
  }

  LatLngWithAngle? get geom => _geom;

  set geom(LatLngWithAngle? value) {
    _geom = value;
  }

  String? get cod_ibge_m => _cod_ibge_m;

  set cod_ibge_m(String? value) {
    _cod_ibge_m = value;
  }

  String? get descricao => _descricao;

  set descricao(String? value) {
    _descricao = value;
  }

  String? get tipo => _tipo;

  set tipo(String? value) {
    _tipo = value;
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

  @override
  String toString() {
    return 'ImovelGeoPoint{_id: $_id, _idSistema: $_idSistema, _idLevantamento: $_idLevantamento, _idSistemaLevantamento: $_idSistemaLevantamento, _tipo: $_tipo, _descricao: $_descricao, _cod_ibge_m: $_cod_ibge_m, _geom: $_geom, _sincronizado: $_sincronizado}';
  }
}
