import 'package:app_itr/etc/PolygonGenerator.dart';
import 'package:app_itr/etc/DBColumnNames.dart';
import 'package:app_itr/helpers/classes/RegiaoAdministrativa.dart';
import '../db.dart';


class ImovelDadosAbertos {
  int? _id;
  int? _idSistema;
  int? _idSistemaBaseConsolidada;
  String? _nome_imovel;
  String? _cod_imovel;
  String? _num_certif;
  String? _car;
  String? _reg_adm;
  String? _cod_ibge_m;
  LatLngWithAngle? _geom;
  String? _geomMultipolygon;
  LatLngWithAngle _coordenadas_sede = new LatLngWithAngle(0.0, 0.0);
  LatLngWithAngle _coordenadas_imovel = new LatLngWithAngle(0.0, 0.0);
  String? _geomRota;
  int? _sincronizado;

  ImovelDadosAbertos();

  ImovelDadosAbertos.fromMap(Map map) {
    _id = map[idColumn];
    _idSistema = map[idSistemaColumn];
    _idSistemaBaseConsolidada = map[idSistemaBaseConsolidadaColumn];
    _nome_imovel = map[nomeImovelColumn];
    _cod_imovel = map[codImovelColumn];
    _num_certif = map[numCertifColumn];
    _car = map[carColumn];
    _reg_adm = map[regAdmColumn];
    _cod_ibge_m = map[cod_ibge_mColumn];
    _geom = LatLngWithAngle(map[latColumn], map[lngColumn]);
    _geomMultipolygon = map[geomMultipolygonColumn];
    _coordenadas_sede = LatLngWithAngle(map[coordenadas_sedeLatColumn], map[coordenadas_sedeLngColumn]);
    _coordenadas_imovel = LatLngWithAngle(map[coordenadas_imovelLatColumn], map[coordenadas_imovelLngColumn]);
    _geomRota = map[geomRotaColumn];
    _sincronizado = map[sincronizadoColumn];

  }

  Map<String, Object?> toMap() {
    Map<String, dynamic> map = {
      idSistemaColumn: _idSistema,
      idSistemaBaseConsolidadaColumn: _idSistemaBaseConsolidada,
      nomeImovelColumn: _nome_imovel,
      codImovelColumn: _cod_imovel,
      numCertifColumn: _num_certif,
      carColumn: _car,
      regAdmColumn: _reg_adm,
      cod_ibge_mColumn: _cod_ibge_m,
      latColumn: _geom!.latitude,
      lngColumn: _geom!.longitude,
      geomMultipolygonColumn: _geomMultipolygon,
      coordenadas_sedeLatColumn: _coordenadas_sede.latitude,
      coordenadas_sedeLngColumn: _coordenadas_sede.longitude,
      coordenadas_imovelLatColumn: _coordenadas_imovel.latitude,
      coordenadas_imovelLngColumn: _coordenadas_imovel.longitude,
      geomRotaColumn: _geomRota,
      sincronizadoColumn: _sincronizado,
    };
    if (_id != null) {
      map[idColumn] = _id;
    }
    return map;
  }

  Future<String?> getRegNome() async{
    DBHelper helper = new DBHelper();
    RegiaoAdministrativa? reg = await helper.getRegiaoAdministrativa(int.parse(_reg_adm!));
    return reg!.nome;
  }



  String getGeom(){
    return 'POINT(' + _geom!.longitude.toString() + ' ' + _geom!.latitude.toString() + ')';
  }

  int? get sincronizado => _sincronizado;

  set sincronizado(int? value) {
    _sincronizado = value;
  }

  String? get geomMultipolygon => _geomMultipolygon;

  set geomMultipolygon(String? value) {
    _geomMultipolygon = value;
  }

  LatLngWithAngle? get geom => _geom;

  set geom(LatLngWithAngle? value) {
    _geom = value;
  }

  String? get cod_ibge_m => _cod_ibge_m;

  set cod_ibge_m(String? value) {
    _cod_ibge_m = value;
  }

  String? get reg_adm => _reg_adm;

  set reg_adm(String? value) {
    _reg_adm = value;
  }

  String? get car => _car;

  set car(String? value) {
    _car = value;
  }

  String? get num_certif => _num_certif;

  set num_certif(String? value) {
    _num_certif = value;
  }

  String? get cod_imovel => _cod_imovel;

  set cod_imovel(String? value) {
    _cod_imovel = value;
  }

  String? get nome_imovel => _nome_imovel;

  set nome_imovel(String? value) {
    _nome_imovel = value;
  }

  int? get idSistemaBaseConsolidada => _idSistemaBaseConsolidada;

  set idSistemaBaseConsolidada(int? value) {
    _idSistemaBaseConsolidada = value;
  }

  int? get idSistema => _idSistema;

  set idSistema(int? value) {
    _idSistema = value;
  }

  int? get id => _id;

  set id(int? value) {
    _id = value;
  }

  String? get geomRota => _geomRota;

  set geomRota(String? value) {
    _geomRota = value;
  }

  LatLngWithAngle get coordenadas_imovel => _coordenadas_imovel;

  set coordenadas_imovel(LatLngWithAngle value) {
    _coordenadas_imovel = value;
  }

  LatLngWithAngle get coordenadas_sede => _coordenadas_sede;

  set coordenadas_sede(LatLngWithAngle value) {
    _coordenadas_sede = value;
  }

  @override
  String toString() {
    return 'ImovelDadosAbertos{_id: $_id, _idSistema: $_idSistema, _idSistemaBaseConsolidada: $_idSistemaBaseConsolidada, _nome_imovel: $_nome_imovel, _cod_imovel: $_cod_imovel, _num_certif: $_num_certif, _car: $_car, _reg_adm: $_reg_adm, _cod_ibge_m: $_cod_ibge_m, _geom: $_geom, _coordenadas_sede: $_coordenadas_sede, _coordenadas_imovel: $_coordenadas_imovel, _sincronizado: $_sincronizado}';
  }
}
