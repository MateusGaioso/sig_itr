import 'dart:io';

import 'package:app_itr/etc/PolygonGenerator.dart';
import 'package:app_itr/etc/DBColumnNames.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../db.dart';


class PontePoint {
  int? _id;
  int? _idSistema;
  int? _idLevantamento;
  int? _idSistemaLevantamento;
  String? _descricao;
  String? _estadoConservacao;
  String? _material;
  String? _extensaoAproximada;
  String? _nomeRioRiacho;
  String? _cod_ibge_m;
  LatLngWithAngle? _geom;
  int? _sincronizado;

  PontePoint();

  PontePoint.fromMap(Map map) {
    _id = map[idColumn];
    _idSistema = map[idSistemaColumn];
    _idLevantamento = map[idLevantamentoColumn];
    _idSistemaLevantamento = map[idSistemaLevantamentoColumn];
    _descricao = map[descricaoColumn];
    _estadoConservacao = map[estadoConservacaoColumn];
    _material = map[materialColumn];
    _extensaoAproximada = map[extensaoAproximadaColumn];
    _nomeRioRiacho = map[rioRiachoColumn];
    _cod_ibge_m = map[cod_ibge_mColumn];
    _geom = LatLngWithAngle(map[latColumn], map[lngColumn]);
    _sincronizado = map[sincronizadoColumn];

  }

  Map<String, Object?> toMap() {
    Map<String, dynamic> map = {
      idSistemaColumn: _idSistema,
      idLevantamentoColumn: _idLevantamento,
      idSistemaLevantamentoColumn: _idSistemaLevantamento,
      descricaoColumn: _descricao,
      estadoConservacaoColumn: _estadoConservacao,
      materialColumn: _material,
      extensaoAproximadaColumn: _extensaoAproximada,
      rioRiachoColumn: _nomeRioRiacho,
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
        "estado_conservacao": _estadoConservacao,
        "material": _material,
        "extensao_aproximada": _extensaoAproximada,
        "nome_rio_riacho": _nomeRioRiacho,
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

  String? get nomeRioRiacho => _nomeRioRiacho;

  set nomeRioRiacho(String? value) {
    _nomeRioRiacho = value;
  }

  String? get extensaoAproximada => _extensaoAproximada;

  set extensaoAproximada(String? value) {
    _extensaoAproximada = value;
  }

  String? get material => _material;

  set material(String? value) {
    _material = value;
  }

  String? get estadoConservacao => _estadoConservacao;

  set estadoConservacao(String? value) {
    _estadoConservacao = value;
  }

  String? get descricao => _descricao;

  set descricao(String? value) {
    _descricao = value;
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
    return 'PontePoint{_id: $_id, _idSistema: $_idSistema, _idLevantamento: $_idLevantamento, _idSistemaLevantamento: $_idSistemaLevantamento, _descricao: $_descricao, _estadoConservacao: $_estadoConservacao, _material: $_material, _extensaoAproximada: $_extensaoAproximada, _nomeRioRiacho: $_nomeRioRiacho, _cod_ibge_m: $_cod_ibge_m, _geom: $_geom, _sincronizado: $_sincronizado}';
  }
}

class PonteImage {
  int? _id;
  int? _idSistema;
  int? _idPonte;
  int? _idSistemaPonte;
  String? _imagePath;
  File? _imageFile;
  int? _sincronizado;

  PonteImage();

  PonteImage.fromMap(Map map) {
    _id = map[idColumn];
    _idSistema = map[idSistemaColumn];
    _idPonte = map[idPonteColumn];
    _idSistemaPonte = map[idSistemaPonteColumn];
    _imagePath = map[ponteImagePathColumn];
    _sincronizado = map[sincronizadoColumn];

  }

  Map<String, Object?> toMap() {
    Map<String, dynamic> map = {
      idSistemaColumn: _idSistema,
      idPonteColumn: _idPonte,
      idSistemaPonteColumn: _idSistemaPonte,
      ponteImagePathColumn: _imagePath,
      sincronizadoColumn: _sincronizado,
    };
    if (_id != null) {
      map[idColumn] = _id;
    }
    return map;
  }


  Future<Map<String, dynamic>> toJson() async =>
      {
        'ponte': _idSistemaPonte,
        'foto': await MultipartFile.fromFile('$_imagePath',filename: 'ponte-$_idSistemaPonte-$_id')
      };


  int? get sincronizado => _sincronizado;

  set sincronizado(int? value) {
    _sincronizado = value;
  }

  File? get imageFile => _imageFile;

  set imageFile(File? value) {

    _imageFile = value;
  }

  String? get imagePath => _imagePath;

  set imagePath(String? value) {
    _imagePath = value;
  }

  int? get idSistemaPonte => _idSistemaPonte;

  set idSistemaPonte(int? value) {
    _idSistemaPonte = value;
  }

  int? get idPonte => _idPonte;

  set idPonte(int? value) {
    _idPonte = value;
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
    return 'PonteImage{_id: $_id, _idSistema: $_idSistema, _idPonte: $_idPonte, _idSistemaPonte: $_idSistemaPonte, _imagePath: $_imagePath, _sincronizado: $_sincronizado}';
  }

}