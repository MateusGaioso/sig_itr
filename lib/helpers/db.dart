import 'dart:io';

import 'package:app_itr/etc/DBColumnNames.dart';
import 'package:app_itr/helpers/classes/EstradaPoint.dart';
import 'package:app_itr/helpers/classes/ImovelRoute.dart';
import 'package:app_itr/helpers/classes/ImovelGeoPoint.dart';
import 'package:app_itr/helpers/classes/Levantamento.dart';
import 'package:app_itr/helpers/classes/PontePoint.dart';
import 'package:app_itr/helpers/classes/RotaEscolarPoint.dart';
import 'package:app_itr/helpers/classes/imovel.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'classes/municipio.dart';
import 'classes/user.dart';

final int version = 67;

class DBHelper {
  static final DBHelper _instance = DBHelper.internal();

  factory DBHelper() => _instance;

  DBHelper.internal();

  Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "user.db");

    print('db location : ' + databasePath);

    var db = await openDatabase(path);

    if (await db.getVersion() < version) {
      db.close();

      //delete the old database so you can copy the new one
      await deleteDatabase(path);

      //open the newly created db
      db = await openDatabase(path, version: version, onCreate: (Database db, int newerVersion) async {
        await db.execute("CREATE TABLE $userTable("
            "$idColumn INTEGER PRIMARY KEY, "
            "$idSistemaColumn INTEGER UNIQUE, "
            "$userColumn TEXT,"
            "$passColumn TEXT,"
            "$nameColumn TEXT,"
            "$emailColumn TEXT,"
            "$cpfColumn TEXT,"
            "$rgColumn TEXT,"
            "$telefoneColumn TEXT,"
            "$imovelColumn TEXT,"
            "$municipiosColumn TEXT,"
            "$tokenColumn TEXT);");

        await db.execute("CREATE TABLE $municipioTable("
            "$idColumn INTEGER PRIMARY KEY,"
            "$idSistemaColumn INTEGER UNIQUE,"
            "$nomeMunicipioColumn TEXT,"
            "$slugColumn TEXT,"
            "$estadoColumn INTEGER,"
            "$sigla_ufColumn TEXT,"
            "$cod_ibge_mColumn TEXT,"
            "$latitudeColumn TEXT,"
            "$longitudeColumn TEXT);");

        await db.execute("CREATE TABLE $loggedUserTable("
            "$idColumn INTEGER PRIMARY KEY,"
            "$idSistemaColumn INTEGER UNIQUE);");

        await db.execute("CREATE TABLE $geoPointTable("
            "$idColumn INTEGER PRIMARY KEY,"
            "$idSistemaColumn INTEGER UNIQUE,"
            "$idLevantamentoColumn INTEGER,"
            "$idSistemaLevantamentoColumn INTEGER,"
            "$tipoColumn TEXT,"
            "$descricaoColumn TEXT,"
            "$cod_ibge_mColumn TEXT,"
            "$sincronizadoColumn INTEGER,"
            "$latColumn REAL,"
            "$lngColumn REAL);");

        await db.execute("CREATE TABLE $imovelTable("
            "$idImovelColumn INTEGER PRIMARY KEY,"
            "$idSistemaUserColumn INTEGER,"
            "$idSistemaMunicipioColumn INTEGER,"
            "$listGeoPointsColumn TEXT);");

        await db.execute("CREATE TABLE $routeTable("
            "$idColumn INTEGER PRIMARY KEY,"
            "$idSistemaRouteColumn INTEGER UNIQUE,"
            "$idSistemaUserColumn INTEGER,"
            "$idSistemaMunicipioColumn INTEGER,"
            "$idSistemaImovelColumn INTEGER,"
            "$origem_consultaColumn TEXT,"
            "$nome_imovelColumn TEXT,"
            "$sincronizadoColumn INTEGER,"
            "$geometryColumn TEXT,"
            "$coordenadas_imovelLatColumn REAL,"
            "$coordenadas_imovelLngColumn REAL,"
            "$coordenadas_sedeLatColumn REAL,"
            "$coordenadas_sedeLngColumn REAL);");

        await db.execute("CREATE TABLE $levantamentoTable("
            "$idColumn INTEGER PRIMARY KEY,"
            "$idSistemaColumn INTEGER UNIQUE,"
            "$idSistemaUserColumn INTEGER,"
            "$idSistemaMunicipioColumn INTEGER,"
            "$descricaoColumn TEXT,"
            "$sincronizadoColumn INTEGER,"
            "$statusColumn TEXT,"
            "$tipoLevantamentoColumn TEXT);");

        await db.execute("CREATE TABLE $estradaPointTable("
            "$idColumn INTEGER PRIMARY KEY,"
            "$idSistemaColumn INTEGER UNIQUE,"
            "$idLevantamentoColumn INTEGER,"
            "$idSistemaLevantamentoColumn INTEGER,"
            "$rodoviaColumn TEXT,"
            "$trechoColumn TEXT,"
            "$jurisdicaoColumn TEXT,"
            "$estadoConservacaoColumn TEXT,"
            "$larguraAproximadaColumn TEXT,"
            "$cod_ibge_mColumn TEXT,"
            "$sincronizadoColumn INTEGER,"
            "$latColumn REAL,"
            "$lngColumn REAL,"
            "$tipoPavimentacaoColumn TEXT);");

        await db.execute("CREATE TABLE $rotaEscolarPointTable("
            "$idColumn INTEGER PRIMARY KEY,"
            "$idSistemaColumn INTEGER UNIQUE,"
            "$idLevantamentoColumn INTEGER,"
            "$idSistemaLevantamentoColumn INTEGER,"
            "$rodoviaColumn TEXT,"
            "$trechoColumn TEXT,"
            "$jurisdicaoColumn TEXT,"
            "$estadoConservacaoColumn TEXT,"
            "$larguraAproximadaColumn TEXT,"
            "$cod_ibge_mColumn TEXT,"
            "$sincronizadoColumn INTEGER,"
            "$latColumn REAL,"
            "$lngColumn REAL,"
            "$tipoPavimentacaoColumn TEXT);");

        await db.execute("CREATE TABLE $pontePointTable("
            "$idColumn INTEGER PRIMARY KEY,"
            "$idSistemaColumn INTEGER UNIQUE,"
            "$idLevantamentoColumn INTEGER,"
            "$idSistemaLevantamentoColumn INTEGER,"
            "$descricaoColumn TEXT,"
            "$estadoConservacaoColumn TEXT,"
            "$materialColumn TEXT,"
            "$extensaoAproximadaColumn TEXT,"
            "$rioRiachoColumn TEXT,"
            "$cod_ibge_mColumn TEXT,"
            "$sincronizadoColumn INTEGER,"
            "$latColumn REAL,"
            "$lngColumn REAL);");

        await db.execute("CREATE TABLE $ponteImageTable("
            "$idColumn INTEGER PRIMARY KEY,"
            "$idSistemaColumn INTEGER UNIQUE,"
            "$idPonteColumn INTEGER,"
            "$idSistemaPonteColumn INTEGER,"
            "$ponteImagePathColumn TEXT,"
            "$sincronizadoColumn INTEGER);");
      });

      //set the new version to the copied db so you do not need to do it manually on your bundled database.db
      db.setVersion(version);
    }

    return db;
  }

  // ---------------- SAVES
  Future<User> saveUser(User user) async {
    Database dbUser = (await db)!;
    try {
      user.id = await dbUser.insert(userTable, user.toMap());
      return user;
    } catch (e) {
      //print("ERROR SAVE USER: $e");
      return updateUser(user);
    }
  }

  Future<LoggedUser> saveLoggedUser(LoggedUser loggedUser) async {
    Database dbLoggedUser = (await db)!;
    try {
      loggedUser.id = await dbLoggedUser.insert(loggedUserTable, loggedUser.toMap());
      print("LOGGED USER SAVED -> $loggedUser");
      return loggedUser;
    } catch (e) {
      print("ERROR SAVE LOGGED USER: $e");
      deleteLoggedUser();
      loggedUser.id = await dbLoggedUser.insert(loggedUserTable, loggedUser.toMap());
      return loggedUser;
    }
  }

  Future<Municipio?> saveMunicipio(Municipio m) async {
    Database dbMunicipio = (await db)!;

    try {
      m.id = await dbMunicipio.insert(municipioTable, m.toMap());
      return m;
    } catch (e) {
      //print("ERROR MUNICIPIO: $e");
      return getMunicipio(m.idSistema!);
    }
  }

  Future<ImovelGeoPoint?> saveGeoPoint(ImovelGeoPoint gp) async {
    Database dbGeo = (await db)!;

    try {
      gp.id = await dbGeo.insert(geoPointTable, gp.toMap());
      print("GEOPOINT SAVED: $gp");
      return gp;
    } catch (e) {
      //print("ERROR MUNICIPIO: $e");
      print("ERROR GEOPOINT: $e");
      return getGeoPoint(gp.id!);
    }
  }

  Future<Imovel?> saveImovel(Imovel imovel) async {
    Database dbImovel = (await db)!;

    try {
      imovel.id = await dbImovel.insert(imovelTable, imovel.toMap());
      print("IMOVEL SAVED: $imovel");
      return imovel;
    } catch (e) {
      //print("ERROR MUNICIPIO: $e");
      print("ERROR IMOVEL: $e");
      return getImovel(imovel.id!);
    }
  }

  Future<ImovelRoute?> saveImovelRoute(ImovelRoute route) async {
    Database dbRoute = (await db)!;

    try {
      route.id = await dbRoute.insert(routeTable, route.toMap());
      //print("ROUTE SAVED: $route");
      return route;
    } catch (e) {
      //print("ERROR MUNICIPIO: $e");
      //print("ERROR ROUTE: $e");
      if(route.id != null){
        //print("return value");
        return getImovelRoute(route.id!);
      } else{
        //print("return update");
        return updateImovelRoute(route);
      }

    }
  }

  Future<Levantamento?> saveLevantamento(Levantamento levantamento) async {
    Database dbLevantamento = (await db)!;

    try {
      levantamento.id = await dbLevantamento.insert(levantamentoTable, levantamento.toMap());
      //print("ROUTE SAVED: $route");
      return levantamento;
    } catch (e) {
      //print("ERROR MUNICIPIO: $e");
      //print("ERROR ROUTE: $e");
      if(levantamento.id != 0){
        //print("return value");
        return updateLevantamento(levantamento);
      } else{
        //print("return update");

      }

    }
  }

  Future<EstradaPoint?> saveEstradaPoint(EstradaPoint estradaPoint) async {
    Database dbEstradaPoint = (await db)!;

    try {
      estradaPoint.id = await dbEstradaPoint.insert(estradaPointTable, estradaPoint.toMap());
      //print("ROUTE SAVED: $route");
      return estradaPoint;
    } catch (e) {
      //print("ERROR MUNICIPIO: $e");
      //print("ERROR ROUTE: $e");
      if(estradaPoint.id != 0){
        //print("return value");
        return updateEstradaPoint(estradaPoint);
      } else{
        //print("return update");

      }

    }
  }

  Future<RotaEscolarPoint?> saveRotaEscolar(RotaEscolarPoint rotaEscolarPoint) async {
    Database dbRotaEscolar = (await db)!;

    try {
      rotaEscolarPoint.id = await dbRotaEscolar.insert(rotaEscolarPointTable, rotaEscolarPoint.toMap());
      //print("ROUTE SAVED: $route");
      return rotaEscolarPoint;
    } catch (e) {
      //print("ERROR MUNICIPIO: $e");
      //print("ERROR ROUTE: $e");
      if(rotaEscolarPoint.id != 0){
        //print("return value");
        return updateRotaEscolar(rotaEscolarPoint);
      } else{
        //print("return update");

      }

    }
  }

  Future<PontePoint?> savePonte(PontePoint pontePoint) async {
    Database dbPonte = (await db)!;

    try {
      pontePoint.id = await dbPonte.insert(pontePointTable, pontePoint.toMap());
      //print("ROUTE SAVED: $route");
      return pontePoint;
    } catch (e) {
      //print("ERROR MUNICIPIO: $e");
      //print("ERROR ROUTE: $e");
      if(pontePoint.id != 0){
        //print("return value");
        return updatePonte(pontePoint);
      } else{
        //print("return update");

      }

    }
  }

  Future<PonteImage?> savePonteImage(PonteImage ponteImage) async {
    Database dbPonte = (await db)!;

    try {
      ponteImage.id = await dbPonte.insert(ponteImageTable, ponteImage.toMap());
      //print("ROUTE SAVED: $route");
      return ponteImage;
    } catch (e) {
      //print("ERROR MUNICIPIO: $e");
      //print("ERROR ROUTE: $e");
      if(ponteImage.id != 0){
        //print("return value");
        return updatePonteImage(ponteImage);
      } else{
        //print("return update");

      }

    }
  }

  // -------------- GET

  Future<User?> getUser(int id) async {
    Database dbUser = (await db)!;
    List<Map> maps = await dbUser.query(userTable,
        columns: [
          idColumn,
          idSistemaColumn,
          userColumn,
          passColumn,
          nameColumn,
          emailColumn,
          cpfColumn,
          rgColumn,
          telefoneColumn,
          imovelColumn,
          municipiosColumn,
          tokenColumn,
        ],
        where: "$idSistemaColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<User?> getLoggedUser() async {
    Database dbLoggedUser = (await db)!;
    List<Map> maps = await dbLoggedUser.query(loggedUserTable, columns: [
      idColumn,
      idSistemaColumn,
    ]);
    if (maps.length > 0) {
      return getUser(LoggedUser.fromMap(maps.first).idSistema);
    } else {
      return null;
    }
  }

  Future<Municipio?> getMunicipio(int id) async {
    Database dbMunicipior = (await db)!;
    List<Map> maps = await dbMunicipior.query(municipioTable,
        columns: [
          idColumn,
          idSistemaColumn,
          nomeMunicipioColumn,
          slugColumn,
          estadoColumn,
          sigla_ufColumn,
          cod_ibge_mColumn,
          latitudeColumn,
          longitudeColumn,
        ],
        where: "$idSistemaColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Municipio.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<ImovelGeoPoint?> getGeoPoint(int id) async {
      Database dbGeo = (await db)!;
      List<Map> maps = await dbGeo.query(geoPointTable,
          columns: [
            idColumn,
            idSistemaColumn,
            idLevantamentoColumn,
            idSistemaLevantamentoColumn,
            tipoColumn,
            descricaoColumn,
            cod_ibge_mColumn,
            sincronizadoColumn,
            latColumn,
            lngColumn,
          ],
          where: "$idColumn = ?",
          whereArgs: [id]);
      if (maps.length > 0) {
        return ImovelGeoPoint.fromMap(maps.first);
      } else {
        return null;
      }
  }

  Future<Imovel?> getImovel(int id) async {
    Database dbImovel = (await db)!;
    List<Map> maps = await dbImovel.query(imovelTable,
        columns: [
          idImovelColumn,
          idSistemaUserColumn,
          idSistemaMunicipioColumn,
          listGeoPointsColumn,
        ],
        where: "$idImovelColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Imovel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<ImovelRoute?> getImovelRoute(int id) async {
    Database dbRoute = (await db)!;
    List<Map> maps = await dbRoute.query(routeTable,
        columns: [
          idColumn,
          idSistemaRouteColumn,
          idSistemaUserColumn,
          idSistemaMunicipioColumn,
          idSistemaImovelColumn,
          origem_consultaColumn,
          nome_imovelColumn,
          sincronizadoColumn,
          geometryColumn,
          coordenadas_imovelLatColumn,
          coordenadas_imovelLngColumn,
          coordenadas_sedeLatColumn,
          coordenadas_sedeLngColumn,
        ],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return ImovelRoute.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<Levantamento?> getLevantamento(int id) async {
    Database dbLevantamento = (await db)!;
    List<Map> maps = await dbLevantamento.query(levantamentoTable,
        columns: [
          idColumn,
          idSistemaColumn,
          idSistemaUserColumn,
          idSistemaMunicipioColumn,
          tipoLevantamentoColumn,
          descricaoColumn,
          statusColumn,
          sincronizadoColumn,
        ],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Levantamento.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<EstradaPoint?> getEstradaPoint(int id) async {
    Database dbEstradaPoint = (await db)!;
    List<Map> maps = await dbEstradaPoint.query(estradaPointTable,
        columns: [
          idColumn,
          idSistemaColumn,
          idLevantamentoColumn,
          idSistemaLevantamentoColumn,
          rodoviaColumn,
          trechoColumn,
          jurisdicaoColumn,
          estadoConservacaoColumn,
          tipoPavimentacaoColumn,
          larguraAproximadaColumn,
          cod_ibge_mColumn,
          sincronizadoColumn,
          latColumn,
          lngColumn,
        ],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return EstradaPoint.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<RotaEscolarPoint?> getRotaEscolar(int id) async {
    Database dbRotaEscolar = (await db)!;
    List<Map> maps = await dbRotaEscolar.query(rotaEscolarPointTable,
        columns: [
          idColumn,
          idSistemaColumn,
          idLevantamentoColumn,
          idSistemaLevantamentoColumn,
          rodoviaColumn,
          trechoColumn,
          jurisdicaoColumn,
          estadoConservacaoColumn,
          tipoPavimentacaoColumn,
          larguraAproximadaColumn,
          cod_ibge_mColumn,
          sincronizadoColumn,
          latColumn,
          lngColumn,
        ],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return RotaEscolarPoint.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<PontePoint?> getPonte(int id) async {
    Database dbPonte = (await db)!;
    List<Map> maps = await dbPonte.query(pontePointTable,
        columns: [
          idColumn,
          idSistemaColumn,
          idLevantamentoColumn,
          idSistemaLevantamentoColumn,
          descricaoColumn,
          estadoConservacaoColumn,
          materialColumn,
          extensaoAproximadaColumn,
          rioRiachoColumn,
          cod_ibge_mColumn,
          sincronizadoColumn,
          latColumn,
          lngColumn,
        ],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return PontePoint.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<PonteImage?> getPonteImage(int id) async {
    Database dbPonte = (await db)!;
    List<Map> maps = await dbPonte.query(ponteImageTable,
        columns: [
          idColumn,
          idSistemaColumn,
          idPonteColumn,
          idSistemaPonteColumn,
          ponteImagePathColumn,
          sincronizadoColumn,
        ],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return PonteImage.fromMap(maps.first);
    } else {
      return null;
    }
  }


  // ----------------- DELETES

  Future<int> deleteLoggedUser() async {
    Database dbLoggedUser = (await db)!;
    return await dbLoggedUser.delete(loggedUserTable);
  }

  Future<int> deleteAllPointsFromLevantamento(LoginDataStore store) async {
    Database dbEstradaPoints = (await db)!;
    return await dbEstradaPoints.delete(estradaPointTable, where:  "$idLevantamentoColumn = ?", whereArgs: [store.selectedLevantamento.id]);
  }

  Future<int> deleteAllRotaPointsFromLevantamento(LoginDataStore store) async {
    Database dbRotaEscolar = (await db)!;
    return await dbRotaEscolar.delete(rotaEscolarPointTable, where:  "$idLevantamentoColumn = ?", whereArgs: [store.selectedLevantamento.id]);
  }

  Future<void> deleteImagePonte(LoginDataStore store) async {
    print("delete image ${store.selectedPonteImage}");
    Database dbPonte = (await db)!;
    store.selectedPonteImage!.imageFile!.delete();
    await dbPonte.delete(ponteImageTable, where:  "$idColumn = ?", whereArgs: [store.selectedPonteImage!.id]).then((value){
      getAllPonteImagesByPontePoint(store.selectedPontePoint!, store);

    });

  }

  // ----------------- UPDATES

  Future<User> updateUser(User user) async {
    Database dbUser = (await db)!;
    try {
      user.id = await dbUser
          .update(userTable, user.toMap(), where: "$idSistemaColumn = ?", whereArgs: [user.idSistema]);
      return user;
    } catch (e) {
      print("ERROR UPDATE USER: $e");
      return user;
    }
  }

  Future<Municipio> updateMunicipio(Municipio m) async {
    Database dbUser = (await db)!;
    try {
      m.id = await dbUser
          .update(municipioTable, m.toMap(), where: "$idSistemaColumn = ?", whereArgs: [m.idSistema]);
      return m;
    } catch (e) {
      print("ERROR UPDATE MUNI: $e");
      return m;
    }
  }

  Future<ImovelGeoPoint> updateGeoPoint(ImovelGeoPoint geoPoint) async {
    Database dbGeoPoint = (await db)!;
    try {
      geoPoint.id = await dbGeoPoint
          .update(geoPointTable, geoPoint.toMap(), where: "$idColumn = ?", whereArgs: [geoPoint.id]);
      return geoPoint;
    } catch (e) {
      print("ERROR UPDATE GEOPOINT: $e");
      return geoPoint;
    }
  }

  Future<Imovel> updateImovel(Imovel imovel) async {
    Database dbImovel = (await db)!;
    try {
      imovel.id = await dbImovel
          .update(imovelTable, imovel.toMap(), where: "$idColumn = ?", whereArgs: [imovel.id]);
      return imovel;
    } catch (e) {
      print("ERROR UPDATE IMOVEL: $e");
      return imovel;
    }
  }

  Future<ImovelRoute> updateImovelRoute(ImovelRoute imovelRoute) async {
    Database dbImovelRoute = (await db)!;
    try {
      imovelRoute.id = await dbImovelRoute
          .update(routeTable, imovelRoute.toMap(), where: "$idSistemaRouteColumn = ?", whereArgs: [imovelRoute.idSistemaRoute]);
      return imovelRoute;
    } catch (e) {
      print("ERROR UPDATE IMOVEL ROUTE: $e");
      return imovelRoute;
    }
  }

  Future<Levantamento> updateLevantamento(Levantamento levantamento) async {
    Database dbLevantamento = (await db)!;
    try {
      levantamento.id = await dbLevantamento
          .update(levantamentoTable, levantamento.toMap(), where: "$idColumn = ?", whereArgs: [levantamento.id]);
      return levantamento;
    } catch (e) {
      print("ERROR UPDATE LEVANTAMENTO: $e");
      return levantamento;
    }
  }

  Future<EstradaPoint> updateEstradaPoint(EstradaPoint estradaPoint) async {
    Database dbEstradaPoint = (await db)!;
    try {
      estradaPoint.id = await dbEstradaPoint
          .update(estradaPointTable, estradaPoint.toMap(), where: "$idColumn = ?", whereArgs: [estradaPoint.id]);
      return estradaPoint;
    } catch (e) {
      print("ERROR UPDATE ESTRADA: $e");
      return estradaPoint;
    }
  }

  Future<RotaEscolarPoint> updateRotaEscolar(RotaEscolarPoint rotaEscolarPoint) async {
    Database dbRotaEscolar = (await db)!;
    try {
      rotaEscolarPoint.id = await dbRotaEscolar
          .update(rotaEscolarPointTable, rotaEscolarPoint.toMap(), where: "$idColumn = ?", whereArgs: [rotaEscolarPoint.id]);
      return rotaEscolarPoint;
    } catch (e) {
      print("ERROR UPDATE ROTA ESCOLAR: $e");
      return rotaEscolarPoint;
    }
  }

  Future<PontePoint> updatePonte(PontePoint pontePoint) async {
    Database dbPonte = (await db)!;
    try {
      pontePoint.id = await dbPonte
          .update(pontePointTable, pontePoint.toMap(), where: "$idColumn = ?", whereArgs: [pontePoint.id]);
      return pontePoint;
    } catch (e) {
      print("ERROR UPDATE PONTE: $e");
      return pontePoint;
    }
  }

  Future<PonteImage> updatePonteImage(PonteImage ponteImage) async {
    Database dbPonte = (await db)!;
    try {
      ponteImage.id = await dbPonte
          .update(ponteImageTable, ponteImage.toMap(), where: "$idColumn = ?", whereArgs: [ponteImage.id]);
      return ponteImage;
    } catch (e) {
      print("ERROR UPDATE PONTE IMAGE: $e");
      return ponteImage;
    }
  }


  // -------------------- GET LISTS

  Future<List> getAllMunicipiosByUserList(LoginDataStore store) async {
    List municipiosUserList = store.u.municipios.split(",");
    Database dbMunicipio = (await db)!;
    List listMap = await dbMunicipio.rawQuery("SELECT * FROM $municipioTable");
    List listMunicipio = [];
    print("LISTA USER = $municipiosUserList");
    store.clearMunicipioList();
    Municipio aux = new Municipio();
    aux.idSistema = 0;
    aux.nome = "- - - -";
    aux.sigla_uf = "";
    store.addMunicipioList(aux);
    for (Map m in listMap) {
      print("Map m -> $m");
      Municipio mun = Municipio.fromMap(m);
      if (municipiosUserList.contains(mun.idSistema.toString())) {
        print("REACHED -> $m");
        listMunicipio.add(Municipio.fromMap(m));
        store.addMunicipioList(Municipio.fromMap(m));
      } else {}
    }
    store.setMunicipio(aux);
    return listMunicipio;
  }


  Future<List> getAllAsyncGeoPoints(LoginDataStore store) async {
    Database dbGeoPoint = (await db)!;
    int idSistemaUser = store.u.idSistema;
    int idSistemaMunicipio = store.m.idSistema!;
    List listMap = await dbGeoPoint.rawQuery("SELECT * FROM $geoPointTable WHERE $idSistemaUserColumn "
        "= $idSistemaUser AND $idSistemaMunicipioColumn = $idSistemaMunicipio AND $sincronizadoColumn = 0;");
    List<ImovelGeoPoint> listGeoPoints = [];
    int aux = 0;

    for (Map m in listMap) {
      print("Map m -> $m");
      ImovelGeoPoint g = ImovelGeoPoint.fromMap(m);
      print("REACHED -> $g");
      if (g.sincronizado == 0) {
        aux++;
      }
      listGeoPoints.add(g);
    }

    print("QTD DESSINCRONIZADO => $aux");

    if (aux > 0) {
      store.setAllSincronized(false);
    } else {
      store.setAllSincronized(true);
    }

    return listGeoPoints;
  }

  Future<List> getAllImoveis(LoginDataStore store) async {
    Database dbImovel = (await db)!;
    int idSistemaUser = store.u.idSistema;
    int idSistemaMunicipio = store.m.idSistema!;
    List listMap = await dbImovel.rawQuery("SELECT * FROM $imovelTable WHERE $idSistemaUserColumn "
        "= $idSistemaUser AND $idSistemaMunicipioColumn = $idSistemaMunicipio");
    List<Imovel> listImovel = [];
    int aux = 0;

    for (Map m in listMap) {
      print("Map m -> $m");
      Imovel i = Imovel.fromMap(m);
      print("REACHED -> $i");
      listImovel.add(i);
    }

    print("QTD IMOVEIS => " + listImovel.length.toString());

    return listImovel;
  }

  Future getAllImovelRoutes(LoginDataStore store) async {
    Database? dbImovelRoute = (await db)!;
    int idSistemaUser = store.u.idSistema;
    int idSistemaMunicipio = store.m.idSistema!;
    List listMap = await dbImovelRoute.rawQuery("SELECT * FROM $routeTable WHERE $idSistemaUserColumn "
        "= ? AND $idSistemaMunicipioColumn = ?", ['$idSistemaUser', '$idSistemaMunicipio']);

    print("LIST-MAP here -> $listMap");
    store.clearImovelRoute();

    for (Map m in listMap) {
      print("Map m -> $m");
      ImovelRoute r = ImovelRoute.fromMap(m);
      print("REACHED -> $r");
      store.addImovelRoute(r);
    }

    print("QTD Rotas =>  ${store.imovelRouteList.length}");

  }

  Future getAllLevantamentos(LoginDataStore store) async {
    Database? dbLevantamentos = (await db)!;
    int idSistemaUser = store.u.idSistema;
    int idSistemaMunicipio = store.m.idSistema!;
    List listMap = await dbLevantamentos.rawQuery("SELECT * FROM $levantamentoTable WHERE $idSistemaUserColumn "
        "= ? AND $idSistemaMunicipioColumn = ?", ['$idSistemaUser', '$idSistemaMunicipio']);

    print("LIST-MAP here -> $listMap");
    store.clearLevantamentosList();

    for (Map m in listMap) {
      print("Map m -> $m");
      Levantamento l = Levantamento.fromMap(m);
      print("REACHED -> $l");
      store.addLevantamentosList(l);
    }

    print("QTD Levantamentos =>  ${store.levantamentosList.length}");

  }

  Future getAllAsyncLevantamentos(LoginDataStore store) async {
    Database? dbLevantamentos = (await db)!;
    int idSistemaUser = store.u.idSistema;
    int idSistemaMunicipio = store.m.idSistema!;
    List listMap = await dbLevantamentos.rawQuery("SELECT * FROM $levantamentoTable WHERE $idSistemaUserColumn "
        "= ? AND $idSistemaMunicipioColumn = ? AND $sincronizadoColumn = ? AND $statusColumn = ?", ['$idSistemaUser', '$idSistemaMunicipio', '0', 'finalizado']);

    print("LIST-MAP here -> $listMap");
    store.clearLevantamentosAsyncList();

    for (Map m in listMap) {
      print("Map m -> $m");
      Levantamento l = Levantamento.fromMap(m);
      print("REACHED -> $l");
      store.addLevantamentosAsyncList(l);
    }

    print("QTD Levantamentos Async =>  ${store.levantamentosListAsync.length}");

  }


  Future getAllEstradaPointsByLevantamento(Levantamento l, LoginDataStore store) async {
    Database? dbEstradaPoint = (await db)!;
    List listMap = await dbEstradaPoint.rawQuery("SELECT * FROM $estradaPointTable WHERE $idLevantamentoColumn "
        "= ?", ['${l.id}']);

    print("LIST-MAP here -> $listMap");
    store.clearEstradaPointList();

    for (Map m in listMap) {
      print("Map m -> $m");
      EstradaPoint e = EstradaPoint.fromMap(m);
      print("REACHED -> $e");
      store.addEstradaPointList(e);
    }

    print("QTD Estrada Points =>  ${store.estradaPointList.length}");

  }

  Future getAllAsyncEstradaPointsByLevantamento(Levantamento l, LoginDataStore store) async {
    Database? dbEstradaPoint = (await db)!;
    List listMap = await dbEstradaPoint.rawQuery("SELECT * FROM $estradaPointTable WHERE $idLevantamentoColumn "
        "= ?", ['${l.id}']);

    print("LIST-MAP here -> $listMap");
    store.clearEstradaPointAsyncList();

    for (Map m in listMap) {
      print("Map m -> $m");
      EstradaPoint e = EstradaPoint.fromMap(m);
      print("REACHED -> $e");
      store.addEstradaPointAsyncList(e);
    }

    print("QTD Estrada Points =>  ${store.estradaPointListAsync.length}");

  }

  Future getAllRotaEscolarPointsByLevantamento(Levantamento l, LoginDataStore store) async {
    Database? dbRotaEscolar = (await db)!;
    List listMap = await dbRotaEscolar.rawQuery("SELECT * FROM $rotaEscolarPointTable WHERE $idLevantamentoColumn "
        "= ?", ['${l.id}']);

    print("LIST-MAP here -> $listMap");
    store.clearRotaEscolarPointList();

    for (Map m in listMap) {
      print("Map m -> $m");
      RotaEscolarPoint r = RotaEscolarPoint.fromMap(m);
      print("REACHED -> $r");
      store.addRotaEscolarPointList(r);
    }

    print("QTD Rota Escolar Points =>  ${store.rotaEscolarPointList.length}");

  }

  Future getAllAsyncRotaEscolarPointsByLevantamento(Levantamento l, LoginDataStore store) async {
    Database? dbRotaEscolar = (await db)!;
    List listMap = await dbRotaEscolar.rawQuery("SELECT * FROM $rotaEscolarPointTable WHERE $idLevantamentoColumn "
        "= ?", ['${l.id}']);

    print("LIST-MAP here -> $listMap");
    store.clearRotaEscolarPointAsyncList();

    for (Map m in listMap) {
      print("Map m -> $m");
      RotaEscolarPoint r = RotaEscolarPoint.fromMap(m);
      print("REACHED -> $r");
      store.addRotaEscolarPointAsyncList(r);
    }

    print("QTD Rota Escolar Points =>  ${store.rotaEscolarPointListAsync.length}");

  }

  Future getAllGeoPointsByLevantamento(Levantamento l, LoginDataStore store) async {
    Database? dbImovelGeoPoint = (await db)!;
    List listMap = await dbImovelGeoPoint.rawQuery("SELECT * FROM $geoPointTable WHERE $idLevantamentoColumn"
        "= ?", ['${l.id}']);

    print("LIST-MAP here -> $listMap");
    store.clearImovelGeoPointList();

    for (Map m in listMap) {
      print("Map m -> $m");
      ImovelGeoPoint i = ImovelGeoPoint.fromMap(m);
      print("REACHED -> $i");
      store.addImovelGeoPointList(i);
    }

    print("QTD IMOVEL Points =>  ${store.imovelGeoPointList.length}");

  }

  Future getAllAsyncGeoPointsByLevantamento(Levantamento l, LoginDataStore store) async {
    Database? dbImovelGeoPoint = (await db)!;
    List listMap = await dbImovelGeoPoint.rawQuery("SELECT * FROM $geoPointTable WHERE $idLevantamentoColumn "
        "= ?", ['${l.id}']);

    print("LIST-MAP here -> $listMap");
    store.clearImovelGeoPointAsyncList();

    for (Map m in listMap) {
      print("Map m -> $m");
      ImovelGeoPoint i = ImovelGeoPoint.fromMap(m);
      print("REACHED -> $i");
      store.addImovelGeoPointAsyncList(i);
    }

    print("QTD IMOVEL ASYNC Points =>  ${store.imovelGeoPointListAsync.length}");

  }


  Future getAllPontesByLevantamento(Levantamento l, LoginDataStore store) async {
    Database? dbPonte = (await db)!;
    List listMap = await dbPonte.rawQuery("SELECT * FROM $pontePointTable WHERE $idLevantamentoColumn"
        "= ?", ['${l.id}']);

    print("LIST-MAP here -> $listMap");
    store.clearPonteList();

    for (Map m in listMap) {
      print("Map m -> $m");
      PontePoint i = PontePoint.fromMap(m);
      print("REACHED -> $i");
      store.addPonteList(i);
    }

    print("QTD PONTE Points =>  ${store.ponteList.length}");

  }

  Future getAllAsyncPontesByLevantamento(Levantamento l, LoginDataStore store) async {
    Database? dbPonte = (await db)!;
    List listMap = await dbPonte.rawQuery("SELECT * FROM $pontePointTable WHERE $idLevantamentoColumn "
        "= ?", ['${l.id}']);

    print("LIST-MAP here -> $listMap");
    store.clearPonteAsyncList();

    for (Map m in listMap) {
      print("Map m -> $m");
      PontePoint i = PontePoint.fromMap(m);
      print("REACHED -> $i");
      store.addPonteAsyncList(i);
    }

    print("QTD PONTE ASYNC Points =>  ${store.ponteListAsync.length}");

  }

  Future getAllPonteImagesByPontePoint(PontePoint pp, LoginDataStore store) async {
    Database? dbPonte = (await db)!;
    List listMap = await dbPonte.rawQuery("SELECT * FROM $ponteImageTable WHERE $idPonteColumn "
        "= ?", ['${pp.id}']);

    print("LIST-MAP here -> $listMap");
    store.clearPonteImages();

    for (Map m in listMap) {
      print("Map m -> $m");
      PonteImage i = PonteImage.fromMap(m);
      i.imageFile = File(i.imagePath!);
      print("REACHED -> $i");
      store.addPonteImagesList(i);
    }
    store.addPonteImageLastPosition();
    print("QTD PONTE IMAGES =>  ${store.ponteImages.length}");

  }


}
