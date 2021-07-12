import 'package:app_itr/etc/DBColumnNames.dart';
import 'dart:convert';
import '../db.dart';

class AppData {
  int? _id;
  int? _idPushMessage;
  String? _pushMessage;
  int?  _isMunicipiosListByUFLoaded;
  String? _cod_ibge_m;
  int?  _isImoveisListByUFLoaded;

  AppData();

  AppData.fromMap(Map map) {
    _id = map[idColumn];
    _idPushMessage = map[idPushMessageColumn];
    _pushMessage = map[pushMessageColumn];
    _isMunicipiosListByUFLoaded = map[isMunicipiosListByUFLoadedColumn];
    _cod_ibge_m = map[cod_ibge_mColumn];
    _isImoveisListByUFLoaded = map[isImoveisListByUFLoadedColumn];

  }

  Map<String, Object?> toMap() {
    Map<String, dynamic> map = {
      idPushMessageColumn: _idPushMessage,
      pushMessageColumn: _pushMessage,
      isMunicipiosListByUFLoadedColumn: _isMunicipiosListByUFLoaded,
      cod_ibge_mColumn: _cod_ibge_m,
      isImoveisListByUFLoadedColumn: _isImoveisListByUFLoaded,
    };
    if (_id != null) {
      map[idColumn] = _id;
    }
    return map;
  }

  int? get isImoveisListByUFLoaded => _isImoveisListByUFLoaded;

  set isImoveisListByUFLoaded(int? value) {
    _isImoveisListByUFLoaded = value;
  }

  int? get isMunicipiosListByUFLoaded => _isMunicipiosListByUFLoaded;

  set isMunicipiosListByUFLoaded(int? value) {
    _isMunicipiosListByUFLoaded = value;
  }

  String? get pushMessage => _pushMessage;

  set pushMessage(String? value) {
    _pushMessage = value;
  }

  int? get idPushMessage => _idPushMessage;

  set idPushMessage(int? value) {
    _idPushMessage = value;
  }

  int? get id => _id;

  set id(int? value) {
    _id = value;
  }


  String? get cod_ibge_m => _cod_ibge_m;

  set cod_ibge_m(String? value) {
    _cod_ibge_m = value;
  }

  @override
  String toString() {
    return 'AppData{_id: $_id, _idPushMessage: $_idPushMessage, _pushMessage: $_pushMessage, _isMunicipiosListByUFLoaded: $_isMunicipiosListByUFLoaded, _cod_ibge_m: $_cod_ibge_m, _isImoveisListByUFLoaded: $_isImoveisListByUFLoaded}';
  }
}
